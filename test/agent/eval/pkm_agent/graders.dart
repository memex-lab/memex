import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:dart_agent_core/eval.dart';

/// Outcome schema produced by the pkm_agent harness. Keys match what
/// `_PkmAgentSession` writes into `Outcome.environmentState`.
abstract class _OutcomeKeys {
  static const isComplete = 'is_complete';
  static const wrotePara = 'wrote_para';
  static const updatedInsight = 'updated_insight';
  static const skippedPkm = 'skipped_pkm';
  static const successfulMutation = 'successful_pkm_mutation';
  static const missingRequirements = 'missing_requirements';

  static const writtenFiles =
      'written_files'; // List<String> rel paths under PKM/
  static const editedFiles = 'edited_files'; // List<String>
  static const readFiles = 'read_files'; // List<String> in transcript order
  static const writeOrder = 'write_order'; // List<String> in transcript order
  static const fileContents = 'file_contents'; // Map<String, String> rel → body
}

/// Verifies the trial reached one of the two acceptable terminal states:
///   1. persist:  wrote a PARA file (with fact_id) AND called update_timeline_card_insight
///   2. skip:     called skip_pkm_organization AND made no successful PKM mutation
///
/// Maps `PkmRunCompletionEvidence.isComplete` plus its constituent flags
/// into 5 assertions so a failure tells you which branch went wrong.
class PkmCompletionGrader extends CodeGrader {
  PkmCompletionGrader();

  @override
  String get name => 'pkm_completion';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final isComplete = s[_OutcomeKeys.isComplete] == true;
    final wrotePara = s[_OutcomeKeys.wrotePara] == true;
    final updatedInsight = s[_OutcomeKeys.updatedInsight] == true;
    final skippedPkm = s[_OutcomeKeys.skippedPkm] == true;
    final successfulMutation = s[_OutcomeKeys.successfulMutation] == true;
    final missing =
        (s[_OutcomeKeys.missingRequirements] as List?)?.cast<String>() ??
            const [];

    return [
      Assertion(
        description: 'reached a complete terminal state (persist OR skip)',
        passed: isComplete,
        actual: 'is_complete=$isComplete',
        expected: 'is_complete=true',
      ),
      Assertion(
        description: 'persist branch: wrote a PARA file with fact_id',
        passed: wrotePara || skippedPkm,
        actual: 'wrote_para=$wrotePara skipped=$skippedPkm',
        expected: 'wrote_para=true OR skipped=true',
      ),
      Assertion(
        description: 'persist branch: called update_timeline_card_insight',
        passed: updatedInsight || skippedPkm,
        actual: 'updated_insight=$updatedInsight skipped=$skippedPkm',
        expected: 'updated_insight=true OR skipped=true',
      ),
      Assertion(
        description: 'skip branch (when taken) is clean: no PKM mutation',
        passed: !skippedPkm || !successfulMutation,
        actual: 'skipped=$skippedPkm successful_mutation=$successfulMutation',
        expected: 'skip=>no_mutation',
      ),
      Assertion(
        description: 'no missing requirements',
        passed: missing.isEmpty,
        actual: 'missing=$missing',
        expected: 'missing=[]',
      ),
    ];
  }
}

/// Verifies that on the persist path, the agent routed the new fact into
/// the right place. Two layers of strictness:
///
/// * `expectedBuckets` — coarse PARA top-level (e.g. `Areas/Health/`).
///   Always required.
/// * `expectedFiles` — optional list of specific files that already exist
///   in the fixture and are the "right" target (e.g.
///   `Areas/Health/Sleep.md`). When supplied, the grader gives **partial
///   credit** so eval signal can distinguish "got the area right" from
///   "actually picked the right existing file":
///
///   - 1.0  agent wrote/edited one of `expectedFiles`
///   - 0.5  agent stayed inside `expectedBuckets` but missed every
///          `expectedFiles` entry (e.g. created a sibling new file)
///   - 0.0  none of the writes/edits landed in `expectedBuckets`
///
/// When `expectedFiles` is empty, behaviour collapses to bucket-only
/// (1.0 / 0.0). Anthropic Step 5: "build in partial credit ... a [trial]
/// that correctly identifies [the area] ... but fails to [hit the right
/// existing file] is meaningfully better than one that fails immediately".
///
/// Skipped (returns null score) when the trial took the skip branch — that
/// task wasn't supposed to write anything, so this grader doesn't apply.
class PkmRoutedCorrectlyGrader implements Grader {
  final List<String> expectedBuckets;
  final List<String> expectedFiles;

  PkmRoutedCorrectlyGrader({
    required this.expectedBuckets,
    this.expectedFiles = const [],
  });

  @override
  String get name => 'pkm_routed_correctly';

  @override
  GraderKind get kind => GraderKind.code;

  @override
  double get passThreshold => 0.5;

  @override
  Future<Score> grade({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final skipped = s[_OutcomeKeys.skippedPkm] == true;

    if (skipped) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'agent took the skip branch; routing grader does not apply',
      );
    }

    final written =
        (s[_OutcomeKeys.writtenFiles] as List?)?.cast<String>() ?? const [];
    final edited =
        (s[_OutcomeKeys.editedFiles] as List?)?.cast<String>() ?? const [];
    final all = {...written, ...edited}.map(_normPath).toList();
    final expectedFilesNorm = expectedFiles.map(_normPath).toList();
    final expectedBucketsNorm = expectedBuckets.map(_normPath).toList();

    String? specificHit;
    if (expectedFilesNorm.isNotEmpty) {
      for (final p in all) {
        if (expectedFilesNorm.any((f) => f == p)) {
          specificHit = p;
          break;
        }
      }
    }

    String? bucketHit;
    for (final p in all) {
      if (expectedBucketsNorm.any((b) => p.startsWith(b))) {
        bucketHit = p;
        break;
      }
    }

    final double value;
    final bool passed;
    final String rationale;
    if (specificHit != null) {
      value = 1.0;
      passed = true;
      rationale = 'matched expected file: $specificHit';
    } else if (bucketHit != null) {
      if (expectedFilesNorm.isEmpty) {
        // No file pin; bucket match is a full pass.
        value = 1.0;
        passed = true;
        rationale = 'matched expected bucket: $bucketHit';
      } else {
        // Right area, wrong file — partial credit.
        value = 0.5;
        passed = true;
        rationale = 'wrote into expected bucket ($bucketHit) but missed '
            'specific file(s) $expectedFiles';
      }
    } else {
      value = 0.0;
      passed = false;
      rationale = all.isEmpty
          ? 'agent made no writes/edits'
          : 'wrote/edited $all but none under expected buckets '
              '$expectedBuckets';
    }

    return Score(
      graderName: name,
      value: value,
      passed: passed,
      assertions: [
        if (expectedFiles.isNotEmpty)
          Assertion(
            description: 'wrote/edited one of $expectedFiles',
            passed: specificHit != null,
            actual: '$all',
            expected: 'one of $expectedFiles',
          ),
        Assertion(
          description: 'wrote/edited under one of $expectedBuckets',
          passed: bucketHit != null || specificHit != null,
          actual: '$all',
          expected: 'starts with one of $expectedBuckets',
        ),
      ],
      rationale: rationale,
    );
  }

  /// Normalize a path for comparison: strip leading `/`, collapse the
  /// first segment to title-case so case-only deviations from the agent
  /// don't fail the match. Bucket prefixes ("Areas/", "Projects/") are
  /// case-sensitive in the prompt and on disk, but agents occasionally
  /// lower-case them.
  String _normPath(String relPath) {
    final p = relPath.startsWith('/') ? relPath.substring(1) : relPath;
    final i = p.indexOf('/');
    if (i <= 0) return p;
    final head = p.substring(0, 1).toUpperCase() + p.substring(1, i);
    return '$head${p.substring(i)}';
  }
}

/// Verifies that when a task's fixture pre-seeds an existing PARA file the
/// agent might want to extend, the agent reads that file before writing —
/// so it's appending / merging rather than blindly overwriting.
///
/// Scoped by [requiredReadPath]: a relative path under PKM/ that must
/// appear in the read tool history at some point before the first
/// Write/Edit call. Returns null score when no Write/Edit happened
/// (e.g. trial errored out).
class PkmReadBeforeWriteGrader extends CodeGrader {
  final String requiredReadPath;

  PkmReadBeforeWriteGrader({required this.requiredReadPath});

  @override
  String get name => 'pkm_read_before_write';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final s = outcome.environmentState;
    final reads =
        (s[_OutcomeKeys.readFiles] as List?)?.cast<String>() ?? const [];
    final writes =
        (s[_OutcomeKeys.writeOrder] as List?)?.cast<String>() ?? const [];

    bool norm(String a, String b) =>
        _trimSlash(a).toLowerCase() == _trimSlash(b).toLowerCase();

    final readIdx = reads.indexWhere((r) => norm(r, requiredReadPath));
    final firstWriteIdx = writes.indexWhere((_) => true);

    final readBeforeWrite =
        readIdx >= 0 && (firstWriteIdx < 0 || readIdx <= firstWriteIdx);
    return [
      Assertion(
        description: 'read "$requiredReadPath" before first write/edit',
        passed: readBeforeWrite,
        actual: 'reads=$reads writes=$writes',
        expected: 'read("$requiredReadPath") before first write',
      ),
    ];
  }

  String _trimSlash(String p) => p.startsWith('/') ? p.substring(1) : p;
}

/// Verifies the agent did NOT obliterate fixture content during an append
/// task. Looks for [seedMarker] **anywhere** under PKM/ — the agent is
/// allowed to consolidate fixture files into a different file (e.g. merge
/// three near-duplicate health logs into one well-named file), as long
/// as the original content survives.
///
/// (An earlier version pinned the marker to a specific `relPath`; that
/// punished agents that chose to merge near-duplicate files into one
/// well-named file, which Anthropic Step 2 calls out as "ambiguity in
/// the task spec becomes noise in the metrics".)
class PkmNoOverwriteGrader extends CodeGrader {
  final String seedMarker;

  PkmNoOverwriteGrader({required this.seedMarker});

  @override
  String get name => 'pkm_no_overwrite';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final contents =
        (outcome.environmentState[_OutcomeKeys.fileContents] as Map?)
                ?.cast<String, String>() ??
            const {};
    String? where;
    for (final entry in contents.entries) {
      if (entry.value.contains(seedMarker)) {
        where = entry.key;
        break;
      }
    }
    final preserved = where != null;
    return [
      Assertion(
        description:
            'fixture marker "$seedMarker" survives somewhere under PKM/',
        passed: preserved,
        actual: where == null
            ? 'not found in any of ${contents.keys.toList()}'
            : 'found in $where',
        expected: 'found in some file under PKM/',
      ),
    ];
  }
}

/// Outcome keys produced by the harness for LLM graders. Kept private to
/// the graders module so the harness contract stays in one place.
abstract class _LlmKeys {
  static const insightText = 'insight_text';
  static const fileEdits = 'file_edits'; // List<Map<file_path/old/new>>
  static const fileWrites = 'file_writes'; // List<Map<file_path/content>>
  static const fileContents = 'file_contents';
  static const taskInputContent = 'task_input_content';
  static const skippedPkm = 'skipped_pkm';
  static const writtenFiles = 'written_files';
  static const editedFiles = 'edited_files';
}

/// LLM-as-judge grader for the `update_timeline_card_insight` payload.
///
/// Code graders can only check that the tool was called. They can't tell
/// whether the agent's insight is genuinely useful or just paraphrases the
/// fact. This grader rates the insight text on three dimensions, each in
/// [0, 1], averaged to a final score.
///
/// 1. **groundedness** — does it actually reference what's in the user's
///    PKM, or is it generic life-coach advice?
/// 2. **non-redundancy** — does it add an observation beyond restating
///    the fact?
/// 3. **brevity** — short, scannable, ≤ ~200 chars (the tool's own
///    contract).
///
/// Anthropic Step 5: rubric must include an "Unknown" escape hatch so the
/// judge can return null instead of fabricating a score. We return
/// `Score(value: null)` for skip-branch trials (no insight to judge), for
/// trials where the insight tool was never called, and when the judge
/// itself cannot decide.
class PkmInsightQualityGrader implements Grader {
  PkmInsightQualityGrader({
    LLMClient? overrideClient,
    ModelConfig? overrideModel,
  })  : _overrideClient = overrideClient,
        _overrideModel = overrideModel;

  /// When set (used for unit tests), the grader uses these instead of the
  /// judge resources from `EvalContext`.
  final LLMClient? _overrideClient;
  final ModelConfig? _overrideModel;

  @override
  String get name => 'pkm_insight_quality';

  @override
  GraderKind get kind => GraderKind.model;

  @override
  double get passThreshold => 0.6;

  static const _rubric = '''
You are grading the QUALITY of a single "insight" written by an automated
PKM agent. The insight is a one-paragraph reflection (target ≤ 200 chars)
that ties a new user-facing fact into the user's broader knowledge base.

You will receive:
- USER_FACT       — the new fact the user just published
- INSIGHT_TEXT    — the agent's insight (the thing you are grading)
- TARGET_FILES    — list of PKM files the agent wrote/edited (context only)

Score the insight on three dimensions, each in [0.0, 1.0]:

1. groundedness    — does the insight reference the user's actual context
                     (specific files, prior history, named projects), or
                     does it read like generic self-help advice that would
                     apply to anyone?
2. non_redundancy  — does it add an observation beyond restating the
                     fact text, or is it just a paraphrase?
3. brevity         — is it appropriately short (≤ ~200 chars, single
                     coherent thought)? Long, multi-paragraph insights
                     score lower here.

If the insight is empty, malformed, missing, or you genuinely cannot tell
(e.g. the rubric doesn't apply), return "unknown" for that dimension.

Respond with EXACTLY this JSON shape, no extra prose:

{
  "groundedness":   <number in [0,1] or "unknown">,
  "non_redundancy": <number in [0,1] or "unknown">,
  "brevity":        <number in [0,1] or "unknown">,
  "rationale":      "<= 200 chars summarizing why"
}
''';

  @override
  Future<Score> grade({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final state = outcome.environmentState;
    if (state[_LlmKeys.skippedPkm] == true) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'agent took the skip branch; no insight to grade',
      );
    }

    final insight = (state[_LlmKeys.insightText] as String? ?? '').trim();
    if (insight.isEmpty) {
      return Score(
        graderName: name,
        value: 0.0,
        passed: false,
        rationale: 'no insight_text captured (insight tool likely not called)',
      );
    }

    final factText = (state[_LlmKeys.taskInputContent] as String? ?? '').trim();
    final targets = <String>{
      ...((state[_LlmKeys.writtenFiles] as List?)?.cast<String>() ?? const []),
      ...((state[_LlmKeys.editedFiles] as List?)?.cast<String>() ?? const []),
    }.toList();

    final judge = _resolveJudge(context);
    if (judge == null) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'no judge LLM resources in EvalContext',
      );
    }

    final prompt =
        '$_rubric\n\nUSER_FACT:\n$factText\n\nINSIGHT_TEXT:\n$insight\n\n'
        'TARGET_FILES:\n${targets.join("\n")}';

    final reply = await _judgeOnce(judge, prompt);
    final parsed = _parseJudge(reply);
    if (parsed == null) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'judge returned unparseable response: '
            '${reply.length > 120 ? reply.substring(0, 120) : reply}',
        metadata: {'raw_reply': reply},
      );
    }

    final dims = <String, double?>{
      'groundedness': parsed.groundedness,
      'non_redundancy': parsed.nonRedundancy,
      'brevity': parsed.brevity,
    };
    final present = dims.values.where((v) => v != null).cast<double>().toList();
    final avg = present.isEmpty
        ? null
        : present.reduce((a, b) => a + b) / present.length;

    final assertions = [
      for (final entry in dims.entries)
        Assertion(
          description: '${entry.key} ≥ 0.6',
          passed: (entry.value ?? 0) >= 0.6,
          actual: entry.value?.toStringAsFixed(2) ?? 'unknown',
          expected: '≥ 0.60',
        ),
    ];

    return Score(
      graderName: name,
      value: avg,
      passed: avg != null ? avg >= passThreshold : null,
      assertions: assertions,
      rationale: parsed.rationale ?? 'judge did not provide a rationale',
      metadata: {
        'groundedness': parsed.groundedness,
        'non_redundancy': parsed.nonRedundancy,
        'brevity': parsed.brevity,
        'raw_reply': reply,
      },
    );
  }

  JudgeResources? _resolveJudge(EvalContext ctx) {
    if (_overrideClient != null && _overrideModel != null) {
      return JudgeResources(_overrideClient, _overrideModel);
    }
    return ctx.servicesMap[JudgeResources] as JudgeResources?;
  }

  Future<String> _judgeOnce(JudgeResources j, String prompt) async {
    final reply = await j.client.generate(
      [UserMessage.text(prompt)],
      modelConfig: j.modelConfig,
      jsonOutput: true,
    );
    return reply.textOutput ?? '';
  }
}

/// LLM-as-judge grader for whether the agent's edits / writes blend with
/// the existing voice of the targeted PKM file.
///
/// Code graders can verify "the file got modified". They cannot tell
/// whether the agent appended a tasteful one-line entry or pasted the
/// raw fact text verbatim into a polished file.
///
/// Skipped (null score) when:
///   - trial took the skip branch
///   - agent only created brand-new files (nothing to "blend" into)
///   - judge returns "unknown"
class PkmAppendCoherenceGrader implements Grader {
  PkmAppendCoherenceGrader({
    LLMClient? overrideClient,
    ModelConfig? overrideModel,
  })  : _overrideClient = overrideClient,
        _overrideModel = overrideModel;

  final LLMClient? _overrideClient;
  final ModelConfig? _overrideModel;

  @override
  String get name => 'pkm_append_coherence';

  @override
  GraderKind get kind => GraderKind.model;

  @override
  double get passThreshold => 0.6;

  static const _rubric = '''
You are grading whether an automated PKM agent appended new content to an
existing markdown file in a stylistically coherent way. You will receive:

- ORIGINAL_FILE   — the file as it was before the agent edited it
- NEW_CONTENT     — the new chunk the agent added (Edit's `new_string` or
                    Write's full body)
- USER_FACT       — the original raw fact the agent was meant to log

Score on a single dimension `coherence` in [0.0, 1.0]:

  1.0 — The append matches the file's existing voice, formatting, and
        section structure (e.g. follows the same `## YYYY-MM-DD` heading
        pattern, similar tone, similar terseness).
  0.5 — Acceptable but has clear minor mismatches (extra blank lines,
        slightly different heading style, slightly verbose).
  0.0 — Crude paste of the raw fact text, broken structure, totally
        different tone, or duplicates content already in the file.

If the rubric doesn't apply (e.g. ORIGINAL_FILE is empty — the file is
brand new — so there's no voice to match), return "unknown".

Respond with EXACTLY this JSON shape, no extra prose:

{
  "coherence": <number in [0,1] or "unknown">,
  "rationale": "<= 200 chars"
}
''';

  @override
  Future<Score> grade({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final state = outcome.environmentState;
    if (state[_LlmKeys.skippedPkm] == true) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'agent took the skip branch; nothing to evaluate',
      );
    }

    // Prefer an Edit (we have explicit before+after). Fall back to a
    // Write only if there's no Edit (then we evaluate against the
    // pre-existing file content, if any).
    final edits = ((state[_LlmKeys.fileEdits] as List?) ?? const [])
        .cast<Map>()
        .map((e) => e.cast<String, String>())
        .toList();
    final writes = ((state[_LlmKeys.fileWrites] as List?) ?? const [])
        .cast<Map>()
        .map((e) => e.cast<String, String>())
        .toList();

    Map<String, String>? sample;
    String? originalFile;
    String? newContent;
    if (edits.isNotEmpty) {
      sample = edits.first;
      // We don't have the file's original content captured at edit time,
      // but the surviving final contents include the new chunk. The
      // agent's "old_string" is verbatim what it found in the file at
      // edit time, so use that as the "original-style sample" for
      // coherence judging.
      originalFile = sample['old_string'];
      newContent = sample['new_string'];
    } else if (writes.isNotEmpty) {
      sample = writes.first;
      // For a Write, we look up whether a file existed under that path
      // before. If yes (rare for a Write, but possible), use that as
      // original; otherwise return "unknown".
      final contents =
          (state[_LlmKeys.fileContents] as Map?)?.cast<String, String>() ??
              const {};
      final fp = sample['file_path'] ?? '';
      originalFile = contents[_relPathFromAbsolute(fp)] ?? '';
      newContent = sample['content'];
    }

    if (newContent == null || newContent.isEmpty) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'no Edit/Write recorded — coherence rubric does not apply',
      );
    }
    if ((originalFile ?? '').trim().isEmpty) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'no pre-existing voice to blend with (new file)',
      );
    }

    final judge = _resolveJudge(context);
    if (judge == null) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'no judge LLM resources in EvalContext',
      );
    }

    final factText = (state[_LlmKeys.taskInputContent] as String? ?? '').trim();
    final prompt = '$_rubric\n\nORIGINAL_FILE:\n$originalFile\n\n'
        'NEW_CONTENT:\n$newContent\n\nUSER_FACT:\n$factText';

    final reply = await _judgeOnce(judge, prompt);
    final parsed = _parseCoherence(reply);
    if (parsed == null) {
      return Score(
        graderName: name,
        value: null,
        passed: null,
        rationale: 'judge returned unparseable response: '
            '${reply.length > 120 ? reply.substring(0, 120) : reply}',
        metadata: {'raw_reply': reply},
      );
    }

    return Score(
      graderName: name,
      value: parsed.coherence,
      passed:
          parsed.coherence != null ? parsed.coherence! >= passThreshold : null,
      assertions: [
        Assertion(
          description: 'coherence ≥ 0.6',
          passed: (parsed.coherence ?? 0) >= 0.6,
          actual: parsed.coherence?.toStringAsFixed(2) ?? 'unknown',
          expected: '≥ 0.60',
        ),
      ],
      rationale: parsed.rationale ?? 'judge did not provide a rationale',
      metadata: {
        'coherence': parsed.coherence,
        'sample_file': sample?['file_path'],
        'raw_reply': reply,
      },
    );
  }

  String _relPathFromAbsolute(String p) {
    final i = p.indexOf('/PKM/');
    if (i >= 0) return p.substring(i + '/PKM/'.length);
    return p.startsWith('/') ? p.substring(1) : p;
  }

  JudgeResources? _resolveJudge(EvalContext ctx) {
    if (_overrideClient != null && _overrideModel != null) {
      return JudgeResources(_overrideClient, _overrideModel);
    }
    return ctx.servicesMap[JudgeResources] as JudgeResources?;
  }

  Future<String> _judgeOnce(JudgeResources j, String prompt) async {
    final reply = await j.client.generate(
      [UserMessage.text(prompt)],
      modelConfig: j.modelConfig,
      jsonOutput: true,
    );
    return reply.textOutput ?? '';
  }
}

/// Parsed multi-dim insight rubric reply.
class _ParsedInsight {
  final double? groundedness;
  final double? nonRedundancy;
  final double? brevity;
  final String? rationale;
  _ParsedInsight(
      this.groundedness, this.nonRedundancy, this.brevity, this.rationale);
}

class _ParsedCoherence {
  final double? coherence;
  final String? rationale;
  _ParsedCoherence(this.coherence, this.rationale);
}

double? _readMaybeNumber(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble().clamp(0.0, 1.0);
  if (v is String) {
    if (v.trim().toLowerCase() == 'unknown') return null;
    final n = double.tryParse(v.trim());
    return n?.clamp(0.0, 1.0);
  }
  return null;
}

_ParsedInsight? _parseJudge(String reply) {
  final json = _extractJson(reply);
  if (json == null) return null;
  try {
    final obj = jsonDecode(json) as Map<String, dynamic>;
    return _ParsedInsight(
      _readMaybeNumber(obj['groundedness']),
      _readMaybeNumber(obj['non_redundancy']),
      _readMaybeNumber(obj['brevity']),
      obj['rationale'] as String?,
    );
  } catch (_) {
    return null;
  }
}

_ParsedCoherence? _parseCoherence(String reply) {
  final json = _extractJson(reply);
  if (json == null) return null;
  try {
    final obj = jsonDecode(json) as Map<String, dynamic>;
    return _ParsedCoherence(
      _readMaybeNumber(obj['coherence']),
      obj['rationale'] as String?,
    );
  } catch (_) {
    return null;
  }
}

/// Pull the first {...} JSON object out of [text]. Tolerant of leading
/// markdown fences ("```json ... ```") and trailing prose, both of which
/// LLM judges sometimes emit even with `jsonOutput: true`.
String? _extractJson(String text) {
  if (text.isEmpty) return null;
  final fenceStart = text.indexOf('```');
  String s = text;
  if (fenceStart >= 0) {
    final after = text.substring(fenceStart + 3);
    final lf = after.indexOf('\n');
    final body = lf >= 0 ? after.substring(lf + 1) : after;
    final fenceEnd = body.indexOf('```');
    s = fenceEnd >= 0 ? body.substring(0, fenceEnd) : body;
  }
  final lo = s.indexOf('{');
  final hi = s.lastIndexOf('}');
  if (lo < 0 || hi <= lo) return null;
  return s.substring(lo, hi + 1);
}

/// Tiny duck-typed accessor so the grader doesn't need a hard dependency on
/// the environment.dart `JudgeLLMResources` class — keeps this file usable
/// from unit tests that build their own fixtures.
class JudgeResources {
  final LLMClient client;
  final ModelConfig modelConfig;
  const JudgeResources(this.client, this.modelConfig);
}
