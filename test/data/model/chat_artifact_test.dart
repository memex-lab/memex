import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_artifact.dart';

void main() {
  group('ChatArtifact schema v2', () {
    test('parses a timeline card artifact with target uri metadata', () {
      final artifact = ChatArtifact.fromToolMetadata({
        'artifact': ChatArtifact.timelineCard(
          cardId: '2026/06/10.md#ts_3',
          title: '跑步',
          summary: '今天跑了 5 公里',
          imagePaths: ['fs://a.jpg', 'fs://b.jpg'],
          tags: ['Health'],
          updated: false,
          createdAt: DateTime.utc(2026, 6, 10),
        ).toJson(),
      });

      expect(artifact, isNotNull);
      expect(artifact!.version, ChatArtifact.schemaVersion);
      expect(artifact.kind, ChatArtifact.kindTimelineCard);
      expect(artifact.operation, ChatArtifact.operationCreate);
      expect(artifact.timelineCardId, '2026/06/10.md#ts_3');
      expect(artifact.summary, '今天跑了 5 公里');
      expect(artifact.imagePaths, ['fs://a.jpg', 'fs://b.jpg']);
      expect(artifact.tags, ['Health']);
    });

    test('parses multiple artifacts and round-trips json', () {
      final artifacts = ChatArtifact.listFromToolMetadata({
        'artifacts': [
          ChatArtifact.knowledgeInsight(
            insightId: 'weekly-pattern',
            title: 'Weekly pattern',
            updated: false,
            createdAt: DateTime.utc(2026, 6, 10),
          ).toJson(),
          ChatArtifact.schedule(
            title: 'Schedule presentation',
            summary: 'Pending schedule items: 3',
            updated: true,
            createdAt: DateTime.utc(2026, 6, 10),
          ).toJson(),
        ],
      });

      expect(artifacts, hasLength(2));
      expect(artifacts.first.kind, ChatArtifact.kindKnowledgeInsight);
      expect(artifacts.last.kind, ChatArtifact.kindSchedule);
      expect(ChatArtifact.fromJson(artifacts.last.toJson())!.updated, isTrue);
    });

    test('normalizes knowledge file path for knowledge tab navigation', () {
      final artifact = ChatArtifact.knowledgeFile(
        path: '/PKM/Projects/memex.md',
        title: 'memex.md',
        updated: true,
      );

      expect(artifact.workspacePath, 'PKM/Projects/memex.md');
      expect(artifact.knowledgeFilePath, 'Projects/memex.md');
      expect(
        ChatArtifact.knowledgeFilePathFromWorkspacePath(
          r'\PKM\Areas\health.md',
        ),
        'Areas/health.md',
      );
      expect(
        ChatArtifact.knowledgeFilePathFromWorkspacePath(
          'Projects/memex.md',
        ),
        isNull,
      );
    });

    test('rejects missing, malformed, legacy, or unknown artifacts', () {
      expect(ChatArtifact.fromToolMetadata(null), isNull);
      expect(ChatArtifact.fromToolMetadata({}), isNull);
      expect(ChatArtifact.fromToolMetadata({'artifact': 'oops'}), isNull);
      expect(
        ChatArtifact.fromToolMetadata({
          'artifact': {'type': 'card', 'id': 'legacy'},
        }),
        isNull,
      );
      expect(
        ChatArtifact.fromToolMetadata({
          'artifact': {
            'version': ChatArtifact.schemaVersion,
            'artifact_id': 'x',
            'kind': 'alien',
            'operation': ChatArtifact.operationCreate,
          },
        }),
        isNull,
      );
    });
  });

  group('ChatTurnArtifactCollector', () {
    test('deduplicates by stable UI destination and adds source fields', () {
      final collector = ChatTurnArtifactCollector(sourceRunId: 'turn-1');

      final firstArtifacts = collector.addFromToolResult(
        sourceToolCallId: 'tool-1',
        metadata: {
          'artifact': ChatArtifact.timelineCard(
            cardId: '2026/06/10.md#ts_3',
            title: 'Draft',
            updated: false,
          ).toJson(),
        },
      );
      final secondArtifacts = collector.addFromToolResult(
        sourceToolCallId: 'tool-2',
        metadata: {
          'artifact': ChatArtifact.timelineCard(
            cardId: '2026/06/10.md#ts_3',
            title: 'Final',
            updated: true,
          ).toJson(),
        },
      );

      expect(firstArtifacts, hasLength(1));
      expect(secondArtifacts, isEmpty);
      expect(collector.artifacts, hasLength(1));
      expect(collector.artifacts.single.title, 'Final');
      expect(collector.artifacts.single.updated, isTrue);
      expect(collector.artifacts.single.sourceRunId, 'turn-1');
      expect(collector.artifacts.single.sourceToolCallId, 'tool-2');
    });
  });

  group('ChatArtifactSessionMigration', () {
    test('rewrites legacy session artifacts to schema v2 once', () {
      final session = <String, dynamic>{
        'messages': <dynamic>[
          {
            'role': 'ai',
            'turn_id': 'turn-legacy',
            'timestamp': '2026-06-10T12:00:00.000Z',
            'content': [
              {'type': 'text', 'text': 'done'},
            ],
            'artifacts': [
              {
                'type': 'file',
                'path': 'PKM/Projects/memex.md',
                'snippet': '# Memex',
                'updated': true,
              },
              {
                'type': 'schedule',
                'title': 'Schedule presentation',
                'updated': true,
              },
            ],
          },
        ],
      };

      final changed = ChatArtifactSessionMigration.migrateSessionData(session);

      expect(changed, isTrue);
      expect(
        session[ChatArtifactSessionMigration.schemaVersionKey],
        ChatArtifact.schemaVersion,
      );

      final message =
          (session['messages'] as List).single as Map<String, dynamic>;
      final artifacts = message['artifacts'] as List<dynamic>;
      expect(artifacts, hasLength(2));

      final fileArtifact = ChatArtifact.fromJson(
        Map<String, dynamic>.from(artifacts.first as Map),
      )!;
      expect(fileArtifact.kind, ChatArtifact.kindKnowledgeFile);
      expect(fileArtifact.workspacePath, 'PKM/Projects/memex.md');
      expect(fileArtifact.summary, '# Memex');
      expect(fileArtifact.sourceRunId, 'turn-legacy');

      final secondChanged =
          ChatArtifactSessionMigration.migrateSessionData(session);
      expect(secondChanged, isFalse);
    });
  });
}
