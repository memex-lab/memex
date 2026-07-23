import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/event_bus_message.dart';

void main() {
  test('parses profile update messages from event payloads', () {
    final parsed = EventBusMessage.fromJson({
      'type': 'profile_updated',
      'data': {
        'user_id': 'user-1',
        'avatar': 'workspace/_user/_System/media/avatar.heic',
      },
    });

    expect(parsed, isA<ProfileUpdatedMessage>());
    final message = parsed as ProfileUpdatedMessage;
    expect(message.type, EventBusMessageType.profileUpdated);
    expect(message.userId, 'user-1');
    expect(message.avatar, 'workspace/_user/_System/media/avatar.heic');
  });

  test('parses character update messages from event payloads', () {
    final parsed = EventBusMessage.fromJson({
      'type': 'character_updated',
      'data': {
        'user_id': 'user-1',
        'character_id': 'mentor',
      },
    });

    expect(parsed, isA<CharacterUpdatedMessage>());
    final message = parsed as CharacterUpdatedMessage;
    expect(message.type, EventBusMessageType.characterUpdated);
    expect(message.userId, 'user-1');
    expect(message.characterId, 'mentor');
  });

  test('parses persona chat unread change messages', () {
    final parsed = EventBusMessage.fromJson({
      'type': 'persona_chat_unread_changed',
      'data': {'character_id': 'mentor'},
    });

    expect(parsed, isA<PersonaChatUnreadChangedMessage>());
    final message = parsed as PersonaChatUnreadChangedMessage;
    expect(message.type, EventBusMessageType.personaChatUnreadChanged);
    expect(message.characterId, 'mentor');
  });

  test('parses backup snapshot change messages from event payloads', () {
    final parsed = EventBusMessage.fromJson({
      'type': 'backup_snapshots_changed',
      'data': {
        'reason': 'created',
        'snapshot_id': 'memex_auto_2026.memex',
      },
    });

    expect(parsed, isA<BackupSnapshotsChangedMessage>());
    final message = parsed as BackupSnapshotsChangedMessage;
    expect(message.type, EventBusMessageType.backupSnapshotsChanged);
    expect(message.reason, 'created');
    expect(message.snapshotId, 'memex_auto_2026.memex');
  });

  test('parses backup restored messages from event payloads', () {
    final parsed = EventBusMessage.fromJson({
      'type': 'backup_restored',
      'data': {
        'user_id': 'user-1',
        'source_path': '/tmp/memex_backup.memex',
      },
    });

    expect(parsed, isA<BackupRestoredMessage>());
    final message = parsed as BackupRestoredMessage;
    expect(message.type, EventBusMessageType.backupRestored);
    expect(message.userId, 'user-1');
    expect(message.sourcePath, '/tmp/memex_backup.memex');
  });
}
