import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/settings/widgets/agent_state_viewer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'user_id': 'state-user'});
  });

  testWidgets('renders parent state with linked child state ids',
      (tester) async {
    final parentState = _stateJson({
      'sessionId': 'memex_agent_parent',
      'metadata': {
        'userId': 'state-user',
        'scene': 'super_agent_home',
      },
      'activeSkills': ['manage_timeline_card'],
      'isRunning': false,
      'totalLoopCount': 2,
      'currentLoopCount': 0,
      'usages': [
        {
          'promptTokens': 100,
          'completionTokens': 25,
          'cachedToken': 10,
          'totalTokens': 125,
          'timestamp': 1782093600000000,
        }
      ],
      'history': {
        'messages': [
          {
            'role': 'user',
            'timestamp': 1782093600000000,
            'contents': [
              {'type': 'text', 'text': 'Record dinner.'},
            ],
          },
          {
            'role': 'assistant',
            'model': 'memex-default',
            'timestamp': 1782093601000000,
            'functionCalls': [
              {
                'id': 'call_delegate',
                'name': 'delegate_to_subagent',
                'arguments': jsonEncode({
                  'agent_type': 'timeline_card',
                  'task_brief': 'Record dinner as a card.',
                }),
              },
            ],
            'stopReason': 'tool_calls',
          },
          {
            'role': 'tool',
            'timestamp': 1782093602000000,
            'results': [
              {
                'id': 'call_delegate',
                'name': 'delegate_to_subagent',
                'isError': false,
                'arguments': '{}',
                'content': [
                  {
                    'type': 'text',
                    'text': '[timeline_card_child] status=completed\nsaved',
                  },
                ],
                'metadata': {
                  'child_result': {
                    'child': 'timeline_card_child',
                    'status': 'completed',
                    'summary': 'saved',
                    'child_session_id': 'manage_card_child_1',
                  },
                },
              },
            ],
          },
          {
            'role': 'assistant',
            'model': 'memex-default',
            'timestamp': 1782093603000000,
            'textOutput': 'Done.',
          },
        ],
        'episodicMemories': [],
      },
    });

    final childState = _stateJson({
      'sessionId': 'manage_card_child_1',
      'metadata': {
        'userId': 'state-user',
        'sub_agent_mode': true,
        'child_name': 'manage_card_child',
        'parent_session_id': 'memex_agent_parent',
      },
      'isRunning': false,
      'history': {
        'messages': [
          {
            'role': 'assistant',
            'model': 'memex-default',
            'timestamp': 1782093602000000,
            'functionCalls': [
              {
                'id': 'call_save',
                'name': 'save_timeline_card',
                'arguments': '{"title":"Dinner"}',
              },
            ],
          },
        ],
        'episodicMemories': [],
      },
    });

    await tester.pumpWidget(
      MaterialApp(
        home: AgentStateViewerPage(
          enableTextSelection: false,
          stateEntriesForTesting: [
            AgentStateViewerEntry(
              path: '/state/memex_agent_parent.json',
              sessionId: 'memex_agent_parent',
              title: 'memex_agent_parent',
              subtitle: 'super_agent_home | 4 messages',
              modified: DateTime(2026, 6, 22, 10),
              readContent: () async => parentState,
              metadata: const {
                'userId': 'state-user',
                'scene': 'super_agent_home',
              },
              messageCount: 4,
            ),
            AgentStateViewerEntry(
              path: '/state/manage_card_child_1.json',
              sessionId: 'manage_card_child_1',
              title: 'manage_card_child',
              subtitle: 'child of memex_agent_parent | 1 messages',
              modified: DateTime(2026, 6, 22, 9),
              readContent: () async => childState,
              metadata: const {
                'userId': 'state-user',
                'sub_agent_mode': true,
                'child_name': 'manage_card_child',
                'parent_session_id': 'memex_agent_parent',
              },
              messageCount: 1,
            ),
          ],
          userIdForTesting: 'state-user',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Agent States'), findsOneWidget);
    expect(find.text('memex_agent_parent'), findsOneWidget);
    expect(find.textContaining('Linked Child States'), findsOneWidget);
    expect(find.textContaining('manage_card_child_1'), findsOneWidget);
    expect(find.textContaining('delegate_to_subagent'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Linked child state');
    await tester.pump();

    expect(
      find.textContaining('Linked child state: `manage_card_child_1`'),
      findsOneWidget,
    );
    expect(find.textContaining('Record dinner.'), findsNothing);
  });

  testWidgets('scrolls state content to bottom and top', (tester) async {
    final longState = _stateJson({
      'sessionId': 'memex_agent_long_state',
      'metadata': {
        'userId': 'state-user',
        'scene': 'super_agent_home',
      },
      'history': {
        'messages': [
          {
            'role': 'user',
            'timestamp': 1782093600000000,
            'contents': [
              {
                'type': 'text',
                'text': List.generate(240, (i) => 'state line $i').join('\n'),
              },
            ],
          },
        ],
        'episodicMemories': [],
      },
    });

    await tester.pumpWidget(
      MaterialApp(
        home: AgentStateViewerPage(
          enableTextSelection: false,
          stateEntriesForTesting: [
            AgentStateViewerEntry(
              path: '/state/memex_agent_long_state.json',
              sessionId: 'memex_agent_long_state',
              title: 'memex_agent_long_state',
              subtitle: 'super_agent_home | 1 messages',
              modified: DateTime(2026, 6, 22, 10),
              readContent: () async => longState,
              metadata: const {
                'userId': 'state-user',
                'scene': 'super_agent_home',
              },
              messageCount: 1,
            ),
          ],
          userIdForTesting: 'state-user',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('agent_state_content_scroll')),
    );
    final position = scrollView.controller!.position;
    expect(position.maxScrollExtent, greaterThan(0));
    expect(position.pixels, 0);

    await tester.tap(find.byTooltip('Bottom'));
    await tester.pumpAndSettle();

    expect(position.pixels, moreOrLessEquals(position.maxScrollExtent));

    await tester.tap(find.byTooltip('Top'));
    await tester.pumpAndSettle();

    expect(position.pixels, 0);
  });
}

String _stateJson(Map<String, dynamic> json) => jsonEncode({
      'systemReminders': <String, String>{},
      'plan': null,
      'currentLoopUsages': [],
      'lastError': null,
      'systemPromptHistory': [],
      'toolsHistory': [],
      ...json,
      'metadata': json['metadata'] ?? <String, dynamic>{},
      'activeSkills': json['activeSkills'] ?? [],
      'totalLoopCount': json['totalLoopCount'] ?? 0,
      'currentLoopCount': json['currentLoopCount'] ?? 0,
      'usages': json['usages'] ?? [],
    });
