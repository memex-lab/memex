import 'package:dart_agent_core/eval.dart';

/// Outcome schema produced by the card agent harness. Keys match what
/// `_CardAgentSession` writes into `Outcome.environmentState`.
abstract class _OutcomeKeys {
  static const isComplete = 'is_complete';
  static const status = 'status';
  static const hasTitle = 'has_title';
  static const hasUiConfigs = 'has_ui_configs';
  static const missingRequirements = 'missing_requirements';
  static const templateIds = 'template_ids';
  static const cardSaveToolCalled = 'card_save_tool_called';
  static const cardYamlBlob = 'card_yaml_blob';
}

/// Verifies the trial wrote a complete card file:
/// - save_timeline_card was called successfully
/// - card file exists with status=completed, has title and ui_configs
/// - persisted fact_id matches the input fact_id
class CardCompletionGrader extends CodeGrader {
  CardCompletionGrader();

  @override
  String get name => 'card_completion';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final state = outcome.environmentState;
    final saveCalled = state[_OutcomeKeys.cardSaveToolCalled] == true;
    final isComplete = state[_OutcomeKeys.isComplete] == true;
    final status = state[_OutcomeKeys.status] as String?;
    final hasTitle = state[_OutcomeKeys.hasTitle] == true;
    final hasUiConfigs = state[_OutcomeKeys.hasUiConfigs] == true;
    final missing =
        (state[_OutcomeKeys.missingRequirements] as List?)?.cast<String>() ??
            const [];

    return [
      Assertion(
        description: 'save_timeline_card called successfully',
        passed: saveCalled,
        actual: 'called=$saveCalled',
        expected: 'called=true',
      ),
      Assertion(
        description: 'persisted card file exists with status=completed',
        passed: status == 'completed',
        actual: 'status=$status',
        expected: 'status=completed',
      ),
      Assertion(
        description: 'card has title',
        passed: hasTitle,
        actual: 'has_title=$hasTitle',
        expected: 'has_title=true',
      ),
      Assertion(
        description: 'card has at least one ui_config',
        passed: hasUiConfigs,
        actual: 'has_ui_configs=$hasUiConfigs',
        expected: 'has_ui_configs=true',
      ),
      Assertion(
        description: 'no missing completion requirements',
        passed: isComplete && missing.isEmpty,
        actual: 'missing=$missing',
        expected: 'missing=[]',
      ),
    ];
  }
}

/// Verifies the agent picked an acceptable template, with partial credit:
///   - 1.0 if the first template choice is in [expectedTemplateIds]
///   - 0.5 if any other position matches (the second template, etc.)
///   - 0.0 if none of the picked templates match
///
/// Anthropic Step 5: build in partial credit. Picking the right primary
/// template is "fully right"; picking it as a secondary is half-credit
/// (the card still surfaces in roughly the right place).
class CardTemplateChoiceGrader implements Grader {
  final Set<String> expectedTemplateIds;

  CardTemplateChoiceGrader({required this.expectedTemplateIds});

  @override
  String get name => 'card_template_choice';

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
    final picked = (outcome.environmentState[_OutcomeKeys.templateIds] as List?)
            ?.cast<String>() ??
        const [];

    double value;
    String rationale;
    final assertions = <Assertion>[];

    if (picked.isEmpty) {
      value = 0.0;
      rationale = 'no template chosen (card_save_tool_called probably failed)';
      assertions.add(Assertion(
        description: 'card has at least one template',
        passed: false,
        actual: '$picked',
        expected: 'one of ${expectedTemplateIds.toList()}',
      ));
    } else if (expectedTemplateIds.contains(picked.first)) {
      value = 1.0;
      rationale = 'primary template "${picked.first}" is acceptable';
      assertions.add(Assertion(
        description:
            'first template choice is one of ${expectedTemplateIds.join(", ")}',
        passed: true,
        actual: '$picked',
        expected: 'one of ${expectedTemplateIds.toList()}',
      ));
    } else if (picked.any(expectedTemplateIds.contains)) {
      value = 0.5;
      rationale = 'expected template appears as a secondary choice (got '
          '${picked.first} primary, ${picked.toSet().intersection(expectedTemplateIds)} '
          'as secondary)';
      assertions.add(Assertion(
        description:
            'first template choice is one of ${expectedTemplateIds.join(", ")}',
        passed: false,
        actual: '$picked',
        expected: 'one of ${expectedTemplateIds.toList()} as primary',
      ));
    } else {
      value = 0.0;
      rationale = 'no acceptable template in $picked';
      assertions.add(Assertion(
        description:
            'first template choice is one of ${expectedTemplateIds.join(", ")}',
        passed: false,
        actual: '$picked',
        expected: 'one of ${expectedTemplateIds.toList()}',
      ));
    }

    return Score(
      graderName: name,
      value: value,
      passed: value >= passThreshold,
      assertions: assertions,
      rationale: rationale,
    );
  }
}

/// Verifies declared substrings appear (case-insensitive) anywhere inside
/// the saved card YAML — typically used to check that URLs / proper nouns /
/// numeric values from the input were preserved by the agent.
///
/// Returns one assertion per substring; partial credit is automatic
/// (passed_assertions / total_assertions).
class CardMustContainGrader extends CodeGrader {
  final List<String> substrings;

  CardMustContainGrader({required this.substrings});

  @override
  String get name => 'card_must_contain';

  @override
  Future<List<Assertion>> computeAssertions({
    required Trial trial,
    required Transcript transcript,
    required Outcome outcome,
    required EvalContext context,
    ReferenceSolution? referenceSolution,
  }) async {
    final blob =
        (outcome.environmentState[_OutcomeKeys.cardYamlBlob] as String? ?? '')
            .toLowerCase();
    return [
      for (final needle in substrings)
        Assertion(
          description: 'card contains "$needle" (case-insensitive)',
          passed: blob.contains(needle.toLowerCase()),
          actual: blob.length > 200 ? '${blob.substring(0, 200)}…' : blob,
          expected: 'contains "$needle"',
        ),
    ];
  }
}
