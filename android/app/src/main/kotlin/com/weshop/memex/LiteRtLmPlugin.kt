package com.memexlab.memex

import android.content.Context
import android.util.Log
import com.google.ai.edge.litertlm.*
import com.google.gson.Gson
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel as KChannel
import kotlinx.coroutines.flow.catch
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.util.concurrent.TimeUnit
import java.util.concurrent.ConcurrentHashMap

/**
 * Flutter Platform Channel plugin wrapping the official LiteRT-LM Kotlin API.
 *
 * Inference uses a queue-based approach to support multiple concurrent Dart callers:
 *   - Dart calls "startInference" with a unique requestId → queued
 *   - Kotlin processes one inference at a time (LiteRT-LM limitation)
 *   - Tokens are pushed back to Dart via "onInferenceEvent" reverse MethodChannel call
 *   - Dart can call "cancelInference" to abort a queued/running request
 */
class LiteRtLmPlugin(
    private val context: Context,
    private val messenger: BinaryMessenger,
) : MethodCallHandler {

    companion object {
        private const val TAG = "LiteRtLmPlugin"
        private const val METHOD_CHANNEL = "com.memexlab.memex/litert_lm"
        private const val DOWNLOAD_EVENT_CHANNEL = "com.memexlab.memex/litert_lm_download"
    }

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val downloadEventChannel = EventChannel(messenger, DOWNLOAD_EVENT_CHANNEL)
    private val gson = Gson()

    private val httpClient = OkHttpClient.Builder()
        .followRedirects(true)
        .followSslRedirects(true)
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(0, TimeUnit.SECONDS)
        .build()

    private var engine: Engine? = null
    private var engineModelPath: String? = null
    private val engineLock = Any()

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    // Inference queue: requests are processed one at a time
    private val inferenceQueue = KChannel<InferenceRequest>(KChannel.UNLIMITED)
    private val cancelledRequests = ConcurrentHashMap.newKeySet<String>()
    private var queueProcessorJob: Job? = null

    init {
        methodChannel.setMethodCallHandler(this)
        downloadEventChannel.setStreamHandler(DownloadStreamHandler())
        startQueueProcessor()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isModelInstalled" -> {
                val filename = call.argument<String>("filename")
                    ?: return result.error("INVALID_ARG", "filename required", null)
                val expectedSize = call.argument<Long>("expectedSize") ?: 0L
                val file = File(context.filesDir, filename)
                val installed = if (expectedSize > 0) {
                    file.exists() && file.length() >= expectedSize
                } else {
                    file.exists() && file.length() > 100_000_000L
                }
                result.success(installed)
            }

            "initEngine" -> {
                val modelPath = call.argument<String>("modelPath")
                    ?: return result.error("INVALID_ARG", "modelPath required", null)
                val useGpu = call.argument<Boolean>("useGpu") ?: true
                val maxTokens = call.argument<Int>("maxTokens")
                val enableVision = call.argument<Boolean>("enableVision") ?: false
                val enableAudio = call.argument<Boolean>("enableAudio") ?: false
                scope.launch {
                    try {
                        initEngineInternal(modelPath, useGpu, maxTokens, enableVision, enableAudio)
                        withContext(Dispatchers.Main) { result.success(null) }
                    } catch (e: Exception) {
                        Log.e(TAG, "initEngine failed", e)
                        withContext(Dispatchers.Main) {
                            result.error("INIT_FAILED", e.message, null)
                        }
                    }
                }
            }

            "closeEngine" -> {
                scope.launch {
                    closeEngineInternal()
                    withContext(Dispatchers.Main) { result.success(null) }
                }
            }

            "getModelStorageDir" -> {
                result.success(context.filesDir.absolutePath)
            }

            "startInference" -> {
                val requestId = call.argument<String>("requestId")
                    ?: return result.error("INVALID_ARG", "requestId required", null)
                @Suppress("UNCHECKED_CAST")
                val args = call.argument<Map<String, Any?>>("args")
                    ?: return result.error("INVALID_ARG", "args required", null)

                // Enqueue and return immediately
                val req = InferenceRequest(requestId, args)
                scope.launch { inferenceQueue.send(req) }
                result.success(null)
            }

            "cancelInference" -> {
                val requestId = call.argument<String>("requestId")
                    ?: return result.error("INVALID_ARG", "requestId required", null)
                cancelledRequests.add(requestId)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    // --- Inference Queue Processor ---

    data class InferenceRequest(val requestId: String, val args: Map<String, Any?>)

    private fun startQueueProcessor() {
        queueProcessorJob = scope.launch {
            for (req in inferenceQueue) {
                if (cancelledRequests.remove(req.requestId)) {
                    Log.d(TAG, "Skipping cancelled request ${req.requestId}")
                    continue
                }
                processInference(req)
            }
        }
    }

    private suspend fun processInference(req: InferenceRequest) {
        val requestId = req.requestId
        val args = req.args
        var conversation: Conversation? = null

        try {
            Log.i(TAG, "[$requestId] Processing inference request")
            val currentEngine = synchronized(engineLock) { engine }
            if (currentEngine == null) {
                sendEvent(requestId, mapOf("type" to "error", "message" to "Engine not initialized"))
                return
            }

            val systemInstruction = args["systemInstruction"] as? String
            val enableThinking = args["enableThinking"] as? Boolean ?: true
            @Suppress("UNCHECKED_CAST")
            val messages = args["messages"] as? List<Map<String, Any?>> ?: emptyList()
            @Suppress("UNCHECKED_CAST")
            val toolDefs = args["tools"] as? List<Map<String, Any?>> ?: emptyList()

            // Thinking mode: disable when message contains image/audio (crashes on some devices)
            val hasMultimodal = messages.any { msg ->
                msg.containsKey("imageBase64") || msg.containsKey("imagePath") ||
                msg.containsKey("audioBase64") || msg.containsKey("audioPath")
            }
            val useThinking = enableThinking && !hasMultimodal

            val channels = if (useThinking) listOf(Channel("thought", "<|channel>", "<channel|>")) else null
            val effectiveSysInstr = if (useThinking) {
                if (systemInstruction != null) "<|think|>$systemInstruction" else "<|think|>"
            } else {
                systemInstruction
            }

            val convConfig = ConversationConfig(
                systemInstruction = effectiveSysInstr?.let { Contents.of(it) },
                initialMessages = buildInitialMessages(messages),
                tools = buildToolProviders(toolDefs),
                samplerConfig = buildSamplerConfig(args),
                automaticToolCalling = false,
                channels = channels,
            )

            conversation = currentEngine.createConversation(convConfig)
            Log.i(TAG, "[$requestId] Conversation created, sending message")
            val lastUserMsg = messages.lastOrNull { (it["role"] as? String) == "user" }
            val lastContents = if (lastUserMsg != null) buildContents(lastUserMsg) else Contents.of("")
            Log.i(TAG, "[$requestId] Contents built, hasImage=${lastUserMsg?.containsKey("imageBase64") == true || lastUserMsg?.containsKey("imagePath") == true}, hasAudio=${lastUserMsg?.containsKey("audioBase64") == true || lastUserMsg?.containsKey("audioPath") == true}")
            conversation.sendMessageAsync(lastContents)
                .catch { e ->
                    val msg = e.message ?: ""
                    if (msg.contains("Failed to parse tool calls")) {
                        Log.w(TAG, "[$requestId] Tool call parse failed, returning raw text")
                        val raw = msg.substringAfter("from response: ", "")
                            .substringBefore("code block:", "")
                            .trim()
                        if (raw.isNotEmpty()) {
                            sendEvent(requestId, mapOf("type" to "text", "token" to raw))
                        }
                    } else {
                        sendEvent(requestId, mapOf("type" to "error", "message" to (e.message ?: "Unknown error")))
                    }
                }
                .collect { message ->
                    if (cancelledRequests.remove(requestId)) return@collect

                    val toolCalls = message.toolCalls
                    if (toolCalls.isNotEmpty()) {
                        for (tc in toolCalls) {
                            sendEvent(requestId, mapOf(
                                "type" to "tool_call",
                                "name" to tc.name,
                                "arguments" to gson.toJson(tc.arguments),
                            ))
                        }
                    } else {
                        // Check for thinking content in channels
                        val channels = message.channels
                        val thought = channels?.get("thought")
                        if (thought != null && thought.isNotEmpty()) {
                            sendEvent(requestId, mapOf("type" to "thought", "content" to thought))
                        }

                        val token = message.toString()
                        if (token.isNotEmpty()) {
                            sendEvent(requestId, mapOf("type" to "text", "token" to token))
                        }
                    }
                }

            sendEvent(requestId, mapOf("type" to "done"))
        } catch (e: Exception) {
            Log.e(TAG, "[$requestId] Inference error", e)
            sendEvent(requestId, mapOf("type" to "error", "message" to (e.message ?: "Unknown error")))
        } finally {
            try { conversation?.close() } catch (_: Exception) {}
        }
    }

    /** Push an event back to Dart for a specific requestId */
    private suspend fun sendEvent(requestId: String, data: Map<String, Any?>) {
        val payload = HashMap(data)
        payload["requestId"] = requestId
        withContext(Dispatchers.Main) {
            methodChannel.invokeMethod("onInferenceEvent", payload)
        }
    }

    // --- Engine lifecycle ---

    private fun initEngineInternal(modelPath: String, useGpu: Boolean, maxTokens: Int?,
                                    enableVision: Boolean = false, enableAudio: Boolean = false) {
        synchronized(engineLock) {
            if (engine != null && engineModelPath == modelPath) {
                Log.d(TAG, "Engine already initialized for $modelPath, reusing")
                return
            }
            engine?.close()
            engine = null

            Log.i(TAG, "Initializing Engine: $modelPath, gpu=$useGpu, maxTokens=$maxTokens, vision=$enableVision, audio=$enableAudio")
            val backend = if (useGpu) Backend.GPU() else Backend.CPU()
            val config = EngineConfig(
                modelPath = modelPath,
                backend = backend,
                visionBackend = if (enableVision) Backend.CPU() else null, // CPU more stable for vision on MTK
                audioBackend = if (enableAudio) Backend.CPU() else null,
                maxNumTokens = maxTokens,
                cacheDir = context.cacheDir.absolutePath,
            )
            Log.i(TAG, "Engine config created, calling initialize()...")
            val e = Engine(config)
            e.initialize()
            engine = e
            engineModelPath = modelPath
            Log.i(TAG, "Engine ready")
        }
    }

    private fun closeEngineInternal() {
        synchronized(engineLock) {
            engine?.close()
            engine = null
            engineModelPath = null
            Log.i(TAG, "Engine closed")
        }
    }

    fun dispose() {
        queueProcessorJob?.cancel()
        inferenceQueue.close()
        scope.cancel()
        closeEngineInternal()
        httpClient.dispatcher.executorService.shutdown()
        methodChannel.setMethodCallHandler(null)
    }

    // --- Download ---

    inner class DownloadStreamHandler : EventChannel.StreamHandler {
        private var downloadJob: Job? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            @Suppress("UNCHECKED_CAST")
            val args = arguments as? Map<String, Any?> ?: run {
                events.error("INVALID_ARG", "arguments must be a Map", null)
                return
            }
            val url = args["url"] as? String ?: run {
                events.error("INVALID_ARG", "url required", null)
                return
            }
            val destPath = args["destPath"] as? String ?: run {
                events.error("INVALID_ARG", "destPath required", null)
                return
            }

            downloadJob = scope.launch {
                val tmpFile = File("$destPath.tmp")
                val destFile = File(destPath)
                try {
                    tmpFile.parentFile?.mkdirs()
                    if (tmpFile.exists()) tmpFile.delete()

                    val request = Request.Builder().url(url).build()
                    val response = httpClient.newCall(request).execute()

                    if (!response.isSuccessful) {
                        withContext(Dispatchers.Main) {
                            events.error("DOWNLOAD_FAILED", "HTTP ${response.code}", null)
                        }
                        return@launch
                    }

                    val body = response.body ?: run {
                        withContext(Dispatchers.Main) {
                            events.error("DOWNLOAD_FAILED", "Empty response body", null)
                        }
                        return@launch
                    }

                    val totalBytes = body.contentLength()
                    var receivedBytes = 0L
                    var lastReportedProgress = -1

                    tmpFile.outputStream().use { output ->
                        body.byteStream().use { input ->
                            val buffer = ByteArray(8192)
                            var bytesRead: Int
                            while (input.read(buffer).also { bytesRead = it } != -1) {
                                if (!isActive) break
                                output.write(buffer, 0, bytesRead)
                                receivedBytes += bytesRead
                                if (totalBytes > 0) {
                                    val progress = (receivedBytes * 100 / totalBytes).toInt().coerceIn(0, 100)
                                    if (progress != lastReportedProgress) {
                                        lastReportedProgress = progress
                                        withContext(Dispatchers.Main) {
                                            events.success(mapOf("progress" to progress))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if (!isActive) {
                        tmpFile.delete()
                        return@launch
                    }

                    if (destFile.exists()) destFile.delete()
                    tmpFile.renameTo(destFile)

                    withContext(Dispatchers.Main) {
                        events.success(mapOf("progress" to 100, "done" to true))
                        events.endOfStream()
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Download error", e)
                    tmpFile.delete()
                    withContext(Dispatchers.Main) {
                        events.error("DOWNLOAD_FAILED", e.message, null)
                    }
                }
            }
        }

        override fun onCancel(arguments: Any?) {
            downloadJob?.cancel()
            downloadJob = null
        }
    }

    // --- Helpers ---

    private fun buildInitialMessages(messages: List<Map<String, Any?>>): List<Message> {
        if (messages.size <= 1) return emptyList()
        return messages.dropLast(1).mapNotNull { msg -> buildMessage(msg) }
    }

    /** Build a single Message from a Dart map, supporting text + image + audio */
    private fun buildMessage(msg: Map<String, Any?>): Message? {
        val role = msg["role"] as? String ?: return null
        val contents = buildContents(msg)

        return when (role) {
            "user" -> Message.user(contents)
            "model", "assistant" -> Message.model(contents)
            "tool" -> {
                val toolName = msg["toolName"] as? String ?: "tool"
                val text = msg["text"] as? String ?: ""
                Message.tool(Contents.of(Content.ToolResponse(toolName, text)))
            }
            else -> null
        }
    }

    /** Build Contents from a message map: text + optional image/audio */
    private fun buildContents(msg: Map<String, Any?>): Contents {
        val parts = mutableListOf<Content>()

        // Text
        val text = msg["text"] as? String
        if (text != null && text.isNotEmpty()) {
            parts.add(Content.Text(text))
        }

        // Image (base64 bytes or file path)
        val imageBase64 = msg["imageBase64"] as? String
        val imagePath = msg["imagePath"] as? String
        if (imageBase64 != null) {
            try {
                val bytes = android.util.Base64.decode(imageBase64, android.util.Base64.DEFAULT)
                parts.add(Content.ImageBytes(bytes))
            } catch (e: Exception) {
                Log.w(TAG, "Failed to decode imageBase64", e)
            }
        } else if (imagePath != null) {
            parts.add(Content.ImageFile(imagePath))
        }

        // Audio (base64 bytes or file path)
        val audioBase64 = msg["audioBase64"] as? String
        val audioPath = msg["audioPath"] as? String
        if (audioBase64 != null) {
            try {
                val rawBytes = android.util.Base64.decode(audioBase64, android.util.Base64.DEFAULT)
                val wavBytes = convertToPcmWavIfNeeded(rawBytes)
                Log.d(TAG, "Audio converted: ${rawBytes.size} bytes → ${wavBytes.size} bytes WAV")
                parts.add(Content.AudioBytes(wavBytes))
            } catch (e: Exception) {
                Log.w(TAG, "Failed to process audio, skipping: ${e.message}")
            }
        } else if (audioPath != null) {
            try {
                val wavBytes = convertAudioFileToPcmWav(audioPath)
                Log.d(TAG, "Audio file converted: $audioPath → ${wavBytes.size} bytes WAV")
                parts.add(Content.AudioBytes(wavBytes))
            } catch (e: Exception) {
                Log.w(TAG, "Failed to convert audio file $audioPath, skipping: ${e.message}")
            }
        }

        return if (parts.isEmpty()) Contents.of("") else Contents.of(parts)
    }

    private fun buildToolProviders(toolDefs: List<Map<String, Any?>>): List<ToolProvider> {
        if (toolDefs.isEmpty()) return emptyList()
        return toolDefs.map { def ->
            val name = def["name"] as? String ?: ""
            val description = def["description"] as? String ?: ""
            val parametersJson = def["parametersJson"] as? String ?: "{}"
            tool(DartDefinedTool(name, description, parametersJson))
        }
    }

    /**
     * Convert audio bytes to PCM WAV if not already WAV.
     * LiteRT-LM's miniaudio only supports WAV/PCM format.
     */
    private fun convertToPcmWavIfNeeded(bytes: ByteArray): ByteArray {
        // Check WAV header: "RIFF" at offset 0
        if (bytes.size > 4 &&
            bytes[0] == 'R'.code.toByte() &&
            bytes[1] == 'I'.code.toByte() &&
            bytes[2] == 'F'.code.toByte() &&
            bytes[3] == 'F'.code.toByte()) {
            return bytes // Already WAV
        }
        // Write to temp file and convert
        val tmpInput = File.createTempFile("audio_in", ".tmp", context.cacheDir)
        tmpInput.writeBytes(bytes)
        return try {
            convertAudioFileToPcmWav(tmpInput.absolutePath)
        } finally {
            tmpInput.delete()
        }
    }

    /**
     * Decode any Android-supported audio format (M4A, AAC, MP3, etc.) to PCM WAV
     * using MediaExtractor + MediaCodec.
     * Output: 16kHz mono 16-bit PCM WAV (required by Gemma 4 audio model).
     */
    private fun convertAudioFileToPcmWav(inputPath: String): ByteArray {
        val TARGET_SAMPLE_RATE = 16000
        val TARGET_CHANNELS = 1

        val extractor = android.media.MediaExtractor()
        extractor.setDataSource(inputPath)

        // Find audio track
        var audioTrackIndex = -1
        var inputFormat: android.media.MediaFormat? = null
        for (i in 0 until extractor.trackCount) {
            val fmt = extractor.getTrackFormat(i)
            val mime = fmt.getString(android.media.MediaFormat.KEY_MIME) ?: continue
            if (mime.startsWith("audio/")) {
                audioTrackIndex = i
                inputFormat = fmt
                break
            }
        }
        if (audioTrackIndex < 0 || inputFormat == null) {
            extractor.release()
            throw Exception("No audio track found in $inputPath")
        }

        extractor.selectTrack(audioTrackIndex)
        val mime = inputFormat.getString(android.media.MediaFormat.KEY_MIME)!!
        val codec = android.media.MediaCodec.createDecoderByType(mime)
        codec.configure(inputFormat, null, null, 0)
        codec.start()

        val pcmBuffer = java.io.ByteArrayOutputStream()
        val bufferInfo = android.media.MediaCodec.BufferInfo()
        var inputDone = false
        var outputDone = false

        while (!outputDone) {
            if (!inputDone) {
                val inputIdx = codec.dequeueInputBuffer(10000)
                if (inputIdx >= 0) {
                    val buf = codec.getInputBuffer(inputIdx)!!
                    val sampleSize = extractor.readSampleData(buf, 0)
                    if (sampleSize < 0) {
                        codec.queueInputBuffer(inputIdx, 0, 0, 0,
                            android.media.MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                        inputDone = true
                    } else {
                        codec.queueInputBuffer(inputIdx, 0, sampleSize,
                            extractor.sampleTime, 0)
                        extractor.advance()
                    }
                }
            }

            val outputIdx = codec.dequeueOutputBuffer(bufferInfo, 10000)
            if (outputIdx >= 0) {
                val buf = codec.getOutputBuffer(outputIdx)!!
                val chunk = ByteArray(bufferInfo.size)
                buf.get(chunk)
                pcmBuffer.write(chunk)
                codec.releaseOutputBuffer(outputIdx, false)
                if (bufferInfo.flags and android.media.MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                    outputDone = true
                }
            }
        }

        codec.stop()
        codec.release()
        extractor.release()

        val rawPcm = pcmBuffer.toByteArray()

        // Get actual output sample rate and channels from codec output format
        val sampleRate = inputFormat.getInteger(android.media.MediaFormat.KEY_SAMPLE_RATE)
        val channels = inputFormat.getInteger(android.media.MediaFormat.KEY_CHANNEL_COUNT)
        Log.d(TAG, "Audio decoded: sampleRate=$sampleRate, channels=$channels, pcmSize=${rawPcm.size}")

        // Resample to 16kHz mono if needed
        val finalPcm = resamplePcm16(rawPcm, sampleRate, channels,
            TARGET_SAMPLE_RATE, TARGET_CHANNELS)
        Log.d(TAG, "Audio resampled: ${rawPcm.size} → ${finalPcm.size} bytes (${TARGET_SAMPLE_RATE}Hz mono)")

        return buildWavHeader(finalPcm, TARGET_SAMPLE_RATE, TARGET_CHANNELS) + finalPcm
    }

    /** Simple linear resampling for 16-bit PCM */
    private fun resamplePcm16(
        input: ByteArray, srcRate: Int, srcChannels: Int,
        dstRate: Int, dstChannels: Int
    ): ByteArray {
        if (srcRate == dstRate && srcChannels == dstChannels) return input

        val srcSamples = input.size / 2 / srcChannels
        val dstSamples = (srcSamples.toLong() * dstRate / srcRate).toInt()
        val out = java.io.ByteArrayOutputStream(dstSamples * 2)

        for (i in 0 until dstSamples) {
            val srcPos = (i.toLong() * srcRate / dstRate).toInt().coerceIn(0, srcSamples - 1)
            // Mix channels to mono
            var sum = 0L
            for (ch in 0 until srcChannels) {
                val byteIdx = (srcPos * srcChannels + ch) * 2
                val sample = (input[byteIdx].toInt() and 0xFF) or
                        (input[byteIdx + 1].toInt() shl 8)
                sum += sample.toShort()
            }
            val mono = (sum / srcChannels).toInt().coerceIn(-32768, 32767).toShort()
            out.write(mono.toInt() and 0xFF)
            out.write((mono.toInt() shr 8) and 0xFF)
        }
        return out.toByteArray()
    }

    /** Build a WAV file header for 16-bit PCM */
    private fun buildWavHeader(pcmData: ByteArray, sampleRate: Int, channels: Int): ByteArray {
        val dataSize = pcmData.size
        val byteRate = sampleRate * channels * 2
        val buf = java.nio.ByteBuffer.allocate(44).order(java.nio.ByteOrder.LITTLE_ENDIAN)
        buf.put("RIFF".toByteArray())
        buf.putInt(36 + dataSize)
        buf.put("WAVE".toByteArray())
        buf.put("fmt ".toByteArray())
        buf.putInt(16)          // PCM chunk size
        buf.putShort(1)         // PCM format
        buf.putShort(channels.toShort())
        buf.putInt(sampleRate)
        buf.putInt(byteRate)
        buf.putShort((channels * 2).toShort()) // block align
        buf.putShort(16)        // bits per sample
        buf.put("data".toByteArray())
        buf.putInt(dataSize)
        return buf.array()
    }

    private fun buildSamplerConfig(args: Map<String, Any?>): SamplerConfig {
        val temperature = (args["temperature"] as? Number)?.toDouble() ?: 1.0
        val topK = (args["topK"] as? Number)?.toInt() ?: 64
        val topP = (args["topP"] as? Number)?.toDouble() ?: 0.95
        return SamplerConfig(topK = topK, topP = topP, temperature = temperature)
    }
}

class DartDefinedTool(
    private val toolName: String,
    private val toolDescription: String,
    private val parametersJson: String,
) : OpenApiTool {
    override fun getToolDescriptionJsonString(): String {
        // Use Gson to properly escape special characters in name/description
        val gson = Gson()
        val map = linkedMapOf<String, Any?>(
            "name" to toolName,
            "description" to toolDescription,
        )
        // parametersJson is already a JSON string, parse it to avoid double-encoding
        try {
            val params = gson.fromJson(parametersJson, Any::class.java)
            map["parameters"] = params
        } catch (_: Exception) {
            map["parameters"] = emptyMap<String, Any>()
        }
        return gson.toJson(map)
    }
    override fun execute(paramsJsonString: String): String = "{}"
}
