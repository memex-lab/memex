# Integrating Gemma 4 On-Device Inference into a Flutter Local-First App: Lessons Learned

I spent the past few days integrating Gemma 4 on-device inference into [Memex](https://github.com/memex-lab/memex), a local-first personal knowledge management app built with Flutter. Here's what actually happened — the crashes, the architecture decisions, and an honest assessment of where Gemma 4 E2B holds up in a real multi-agent system.

PR with all changes: [github.com/memex-lab/memex/pull/4](https://github.com/memex-lab/memex/pull/4)

---

## Context

Memex keeps all data on-device. Users bring their own LLM provider (Gemini, Claude, OpenAI, etc.). The goal was to add a fully offline option — zero cloud dependency. Gemma 4 E2B/E4B checked the boxes: multimodal (text + image + audio), function calling, and runs on Android via Google's LiteRT-LM runtime. The code supports both E2B and E4B; in practice I've been using E4B.

---

## Attempt 1: flutter_gemma — Immediate Crashes

Started with `flutter_gemma`, a Flutter plugin wrapping LiteRT-LM. The problems were severe — beyond just app crashes, it would occasionally cause the entire phone to reboot. Not just the app process dying, the whole device going black and restarting.

The exact cause is still unclear. For comparison, Google's own Edge Gallery app — which also uses LiteRT-LM — ran the same model on the same device without issues. The difference: Edge Gallery calls the Kotlin API directly, while `flutter_gemma` adds a Flutter plugin layer on top.

Given the severity (phone reboots are unacceptable), I decided to bypass `flutter_gemma` entirely and call the official LiteRT-LM Kotlin API directly via Platform Channels.

---

## The Architecture That Works

**Kotlin side** — `LiteRtLmPlugin.kt`:
- `MethodChannel` for control (init engine, close engine, start inference, cancel)
- Reverse `MethodChannel` callback (`onInferenceEvent`) to push tokens back to Dart, keyed by `requestId` UUID
- Inference queue: requests processed one at a time via Kotlin coroutine channel

**Dart side** — `GemmaLocalClient`:
- Implements the same `LLMClient` interface as cloud providers
- Each `stream()` call generates a unique `requestId`, sends it to Kotlin, listens for events
- Global mutex (promise chain) serializes all calls

**The Engine singleton pattern** is the critical design decision:

```kotlin
// Initialize once — loads 2.6GB model into GPU memory
val engine = Engine(EngineConfig(
    modelPath = modelPath,
    backend = Backend.GPU(),
    maxNumTokens = 10000,
    cacheDir = context.cacheDir.absolutePath,
))
engine.initialize()

// Each inference: lightweight Conversation, closed when done
engine.createConversation(config).use { conversation ->
    conversation.sendMessageAsync(contents)
        .collect { message -> /* stream tokens back to Dart */ }
}
```

This matches how Edge Gallery works. Engine creation is expensive (seconds). Conversation creation is cheap (milliseconds).

---

## Concurrency: The Hard Part

Memex runs multiple agents in parallel — card agent, PKM agent, asset analysis — all potentially calling the LLM at the same time. LiteRT-LM has a hard constraint: **one Conversation per Engine at a time**. Violating this causes `FAILED_PRECONDITION` errors or native crashes.

The solution is a Dart-side global mutex using a promise chain:

```dart
static Future<void> _lockChain = Future.value();

static Future<Completer<void>> _acquireLock() async {
  final completer = Completer<void>();
  final prev = _lockChain;
  _lockChain = completer.future;
  await prev;
  return completer;
}
```

The lock is acquired before `ensureEngineReady()` and released when the stream closes. This is important: **Engine initialization must also be inside the lock**. Image analysis needs `visionBackend`, audio needs `audioBackend` — if two requests concurrently trigger Engine reinitialization with different backend configs, the native layer crashes. Once initialization is inside the lock, on-demand backend switching works correctly.

---

## Multimodal: Images and Audio

### Images

Three undocumented constraints discovered through crashes:

1. **Format:** LiteRT-LM rejects WebP. Only JPEG and PNG work. Passing WebP bytes gives `INVALID_ARGUMENT: Failed to decode image. Reason: unknown image type`.

2. **Size:** The model has a 2520 image patch limit. A 2400×1080 image produces ~2475 patches — too close. Exceeding the limit causes SIGSEGV during prefill. Cap the longest side at 896px.

3. **Backend:** On MediaTek chipsets, the GPU vision backend crashes at a fixed address during decode. Using `Backend.CPU()` for `visionBackend` is stable. The main text inference backend can still use GPU.

### Audio

LiteRT-LM's miniaudio decoder only supports WAV/PCM. M4A, AAC, MP3 all fail with `Failed to initialize miniaudio decoder, error code: -10`.

Fix: transcode on the Kotlin side using Android's `MediaExtractor + MediaCodec`, resample to 16kHz mono 16-bit PCM (Gemma 4's requirement), wrap in a WAV header, pass as `Content.AudioBytes`.

### Thinking Mode + Multimodal

Gemma 4 supports thinking mode via the `<|think|>` control token and `Channel("thought", ...)` in `ConversationConfig`. However, thinking mode combined with vision input crashes on some devices. The workaround: auto-detect multimodal content in the message and disable thinking for those requests.

Also important: when disabling thinking, pass `channels = null` (use model defaults), not `channels = emptyList()`. An empty list **disables all channels** including internal ones the vision pipeline depends on.

---

## Honest Assessment of Gemma 4 E4B in Production

After running it in a real multi-agent app:

### What works well
- **Image description:** Reliably describes scene content, reads text in images, identifies UI elements. Sufficient for the asset analysis use case.
- **Audio transcription:** Mandarin Chinese recognition is usable for short voice notes. Not Whisper-level, but functional.
- **Unstructured text generation:** Summaries, insights, narrative text — reasonable quality for a 2B model.
- **Thinking mode:** Improves reasoning quality for text-only tasks.

### Significant limitations
- **Function calling is unreliable.** The model frequently generates malformed JSON — missing quotes, wrong nesting, invalid structure. LiteRT-LM's built-in parser throws on these, killing the inference stream. Workaround: catch the parse error in the Kotlin `Flow.catch` block, extract raw text from the exception message, return it to Dart so the agent can retry.

- **Structured ID fields are frequently hallucinated.** A field like `fact_id: "2026/04/07.md#ts_1"` gets generated as `"0202/6/04/07.md#ts_4"` or just wrong. Never trust model output for ID fields — always fall back to ground truth from agent state.

- **Occasional empty responses.** The model sometimes produces no output. Needs retry logic at the agent level.

- **Complex JSON schemas are error-prone.** Nested arrays of objects in tool parameters cause frequent errors. Simpler, flatter schemas work better.

- **OpenCL sampler warning spam.** On some devices, the log is flooded with `OpenCL sampler not available, falling back to statically linked C API`. Doesn't affect functionality but makes debugging harder.

- **Thermal throttling.** On-device inference generates significant heat. After sustained use, the phone detects elevated shell and chipset temperatures and triggers system-level thermal throttling, automatically reducing CPU/GPU frequency and further degrading inference speed.

### Workarounds implemented
- Tool call parse failures: extract raw text from error, return to agent for retry
- ID fields: always use `state.metadata['factId']` as fallback, ignore model-provided values
- Tool descriptions: serialize with Gson instead of string concatenation to properly escape special characters
- Empty responses: agent-level retry with max 3 attempts

---

## Performance

Tested on Redmi Pad (Dimensity 8100):
- Text inference: ~15-20 tokens/sec (GPU backend)
- Image analysis: 5-8 seconds per image (CPU vision backend)
- Audio transcription: ~0.3x realtime (CPU audio backend)
- Engine initialization: ~8-10 seconds (first load, cached after)
- Model used: Gemma 4 E4B (~3.7GB)

For a fully offline use case, this is acceptable.

---

## Key Takeaways

1. **Use the official Kotlin API directly.** Don't rely on third-party Flutter wrappers for on-device LLM inference. The abstraction layer hides bugs and makes debugging nearly impossible.

2. **Engine singleton, Conversation per-request.** This is the correct LiteRT-LM usage pattern. Loading a multi-GB model is expensive. Creating a Conversation is cheap.

3. **Serialize everything behind a global lock.** Engine initialization and inference must both be serialized. The lock must be held from before `ensureEngineReady()` until the inference stream closes.

4. **Build fallbacks for structured output.** Unlike cloud-hosted large models, on-device small models will hallucinate field values. For anything that needs to be correct (IDs, paths, structured references), validate and fall back to ground truth.

5. **Multimodal has undocumented constraints.** JPEG/PNG only for images, WAV/PCM only for audio, patch count limits for image size, thinking mode conflicts with vision. Test each modality independently before combining.

---

The full implementation is open source: [github.com/memex-lab/memex](https://github.com/memex-lab/memex)

Integration PR: [github.com/memex-lab/memex/pull/4](https://github.com/memex-lab/memex/pull/4)

Happy to answer questions about any specific part of this.

---

Overall, this integration gave me a glimpse of what's possible with on-device LLMs — fully offline, data never leaves the device, multimodal input works. But honestly, it's not quite ready for mainstream use yet: thermal throttling during sustained inference, unreliable structured output, multimodal compatibility issues across devices. The foundation is there though. Looking forward to seeing on-device models get faster and more capable.
