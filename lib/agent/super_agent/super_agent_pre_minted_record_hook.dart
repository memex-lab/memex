import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logging/logging.dart';
import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/timeline_card_event_publisher.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/utils/logger.dart';

const _factIdMetadataKey = 'super_agent_pre_minted_record_fact_id';
const _turnIdMetadataKey = 'super_agent_pre_minted_record_turn_id';
const _userMessageTimestampMetadataKey =
    'super_agent_pre_minted_record_user_message_timestamp';

class SuperAgentPreMintedRecordHook extends AgentHook {
  SuperAgentPreMintedRecordHook({
    required this.userId,
    required this.turnId,
  });

  @visibleForTesting
  SuperAgentPreMintedRecordHook.forTesting({
    required this.userId,
    required this.turnId,
    required String factId,
  }) : _factId = factId;

  static final Logger _logger = getLogger('SuperAgentPreMintedRecordHook');

  @visibleForTesting
  static const factIdMetadataKey = _factIdMetadataKey;

  @visibleForTesting
  static const turnIdMetadataKey = _turnIdMetadataKey;

  @visibleForTesting
  static const userMessageTimestampMetadataKey =
      _userMessageTimestampMetadataKey;

  final String userId;
  final String turnId;
  String? _factId;
  int? _userMessageTimestamp;

  Future<void> preallocate(AgentState state) async {
    _loadFromState(state);
    final factId = _factId?.trim();
    if (factId != null && factId.isNotEmpty) return;

    await _clearDifferentTurnPlaceholderIfNeeded(state);
    _factId = await FileSystemService.instance.allocateCardFactId(userId);
    _writeToState(state);
    final placeholder = await FileSystemService.instance.readCardFile(
      userId,
      _factId!,
    );
    if (placeholder != null) {
      await emitTimelineCardAdded(
        userId: userId,
        cardId: _factId!,
        cardData: placeholder,
      );
    }
  }

  @visibleForTesting
  String? get factIdForTesting => _factId;

  @override
  BeforeRunHookResult beforeRun(BeforeRunHookContext context) {
    _loadFromState(context.state);
    _userMessageTimestamp ??= _firstUserMessageTimestamp(context.input);
    _writeToState(context.state);
    return BeforeRunHookResult.proceed(context.input);
  }

  @override
  ModelCallHookResult beforeModelCall(ModelCallHookContext context) {
    _loadFromState(context.state);
    final factId = _factId?.trim();
    final userMessageTimestamp = _userMessageTimestamp;
    if (factId == null || factId.isEmpty || userMessageTimestamp == null) {
      return ModelCallHookResult.proceed(request: context.request);
    }

    final nextRequestMessages = annotatePreMintedRecordFactIdReminder(
      context.request.requestMessages,
      factId,
      userMessageTimestamp: userMessageTimestamp,
    );
    return ModelCallHookResult.proceed(
      request: context.request.copyWith(requestMessages: nextRequestMessages),
      changed: !identical(
        nextRequestMessages,
        context.request.requestMessages,
      ),
    );
  }

  @override
  Future<void> afterRun(AfterRunHookContext context) async {
    _loadFromState(context.state);
    final factId = _factId?.trim();
    if (factId == null || factId.isEmpty) return;
    if (context.error != null && context.state.isRunning) {
      return;
    }

    try {
      final card =
          await FileSystemService.instance.readCardFile(userId, factId);
      if (isUnusedPreallocatedRecordPlaceholder(card, factId)) {
        await FileSystemService.instance.deleteCard(userId, factId);
        return;
      }
      final userMessageTimestamp = _userMessageTimestamp;
      if (card != null && userMessageTimestamp != null) {
        final annotated = annotateUserMessageSystemReminder(
          context.state.history.messages,
          userMessageTimestamp: userMessageTimestamp,
          reminder: 'Newly minted record fact_id was used this turn: $factId.',
        );
        if (!identical(annotated, context.state.history.messages)) {
          context.state.history.messages = annotated;
        }
      }
    } catch (e) {
      _logger.warning(
        'Failed to clean up pre-minted record fact_id $factId: $e',
      );
    } finally {
      _factId = null;
      _userMessageTimestamp = null;
      _clearState(context.state);
    }
  }

  void _loadFromState(AgentState state) {
    final metadataTurnId = _metadataString(state, _turnIdMetadataKey);
    if (metadataTurnId != turnId) return;

    _factId ??= _metadataString(state, _factIdMetadataKey);
    _userMessageTimestamp ??=
        _metadataInt(state, _userMessageTimestampMetadataKey);
  }

  void _writeToState(AgentState state) {
    final factId = _factId?.trim();
    if (factId == null || factId.isEmpty) return;

    state.metadata[_factIdMetadataKey] = factId;
    state.metadata[_turnIdMetadataKey] = turnId;
    final userMessageTimestamp = _userMessageTimestamp;
    if (userMessageTimestamp != null) {
      state.metadata[_userMessageTimestampMetadataKey] = userMessageTimestamp;
    }
  }

  void _clearState(AgentState state) {
    state.metadata.remove(_factIdMetadataKey);
    state.metadata.remove(_turnIdMetadataKey);
    state.metadata.remove(_userMessageTimestampMetadataKey);
  }

  Future<void> _clearDifferentTurnPlaceholderIfNeeded(AgentState state) async {
    final metadataTurnId = _metadataString(state, _turnIdMetadataKey);
    final metadataFactId = _metadataString(state, _factIdMetadataKey);
    if (metadataFactId == null) return;
    if (metadataTurnId == turnId) return;

    try {
      final card =
          await FileSystemService.instance.readCardFile(userId, metadataFactId);
      if (isUnusedPreallocatedRecordPlaceholder(card, metadataFactId)) {
        await FileSystemService.instance.deleteCard(userId, metadataFactId);
      }
    } catch (e) {
      _logger.warning(
        'Failed to clean up stale pre-minted record fact_id '
        '$metadataFactId: $e',
      );
    } finally {
      _clearState(state);
    }
  }
}

@visibleForTesting
List<LLMMessage> annotatePreMintedRecordFactIdReminder(
  List<LLMMessage> messages,
  String? factId, {
  required int? userMessageTimestamp,
}) {
  final id = factId?.trim();
  if (id == null || id.isEmpty || userMessageTimestamp == null) {
    return messages;
  }
  final reminder =
      'Newly minted record fact_id: $id. If creating a new record, use this id directly; mint more only if needed.';
  return annotateUserMessageSystemReminder(
    messages,
    userMessageTimestamp: userMessageTimestamp,
    reminder: reminder,
  );
}

@visibleForTesting
bool isUnusedPreallocatedRecordPlaceholder(CardData? card, String factId) {
  if (card == null) return false;
  if (card.factId != factId) return false;
  if (card.status != 'processing') return false;
  if ((card.title ?? '').trim().isNotEmpty) return false;
  if ((card.fact ?? '').trim().isNotEmpty) return false;
  if (card.assets.isNotEmpty) return false;
  if (card.tags.isNotEmpty) return false;
  if (card.comments.isNotEmpty) return false;
  if (card.insight != null) return false;
  if (card.uiConfigs.length != 1) return false;
  final config = card.uiConfigs.single;
  if (config.templateId != 'classic_card') return false;
  return (config.data['content']?.toString() ?? '').trim().isEmpty;
}

@visibleForTesting
List<LLMMessage> annotateUserMessageSystemReminder(
  List<LLMMessage> messages, {
  required int userMessageTimestamp,
  required String reminder,
}) {
  final rewritten = List<LLMMessage>.from(messages);
  for (var i = rewritten.length - 1; i >= 0; i -= 1) {
    final message = rewritten[i];
    if (message is! UserMessage) continue;
    if (message.timestamp != userMessageTimestamp) continue;

    final contents = List<UserContentPart>.from(message.contents);
    for (var j = 0; j < contents.length; j += 1) {
      final part = contents[j];
      if (part is! TextPart) continue;
      if (!part.text.contains('<system-reminder>')) continue;
      if (part.text.contains(reminder)) return messages;

      final updatedText = part.text.contains('</system-reminder>')
          ? part.text.replaceFirst(
              '</system-reminder>',
              '\n\n$reminder\n</system-reminder>',
            )
          : '${part.text}\n\n$reminder';
      contents[j] = TextPart(updatedText);
      rewritten[i] = UserMessage(
        contents,
        timestamp: message.timestamp,
        metadata: message.metadata,
      );
      return rewritten;
    }
  }
  return messages;
}

int? _firstUserMessageTimestamp(List<LLMMessage> messages) {
  for (final message in messages) {
    if (message is UserMessage) return message.timestamp;
  }
  return null;
}

String? _metadataString(AgentState state, String key) {
  final value = state.metadata[key]?.toString().trim();
  return value == null || value.isEmpty ? null : value;
}

int? _metadataInt(AgentState state, String key) {
  final value = state.metadata[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
