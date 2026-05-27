import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/services/agent_activity_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/agent_activity/widgets/agent_activity_widget.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'user_id': 'agent-activity-test'});
    await UserStorage.initL10n();
    AgentActivityService.setInstance(LocalAgentActivityService.instance);
  });

  Widget buildHost({
    bool forceVisible = false,
    TaskActivitySnapshot initialTaskSnapshot =
        const TaskActivitySnapshot.empty(),
    Stream<TaskActivitySnapshot>? taskActivitySnapshotStream,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: AgentActivityWidget(
            forceVisible: forceVisible,
            initialTaskSnapshot: initialTaskSnapshot,
            taskActivitySnapshotStream:
                taskActivitySnapshotStream ??
                const Stream<TaskActivitySnapshot>.empty(),
          ),
        ),
      ),
    );
  }

  testWidgets('shows tappable processing affordance before task activity', (
    tester,
  ) async {
    await tester.pumpWidget(buildHost(forceVisible: true));
    await tester.pump();

    expect(find.text('AI is processing...'), findsOneWidget);

    await tester.tap(find.text('AI is processing...'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Activity Detail'), findsOneWidget);
    expect(find.text('Processing...'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('shows background task count before agent tool messages', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHost(
        initialTaskSnapshot: const TaskActivitySnapshot(
          pending: 1,
          processing: 0,
          retrying: 0,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('AI is processing...'), findsOneWidget);

    await tester.tap(find.text('AI is processing...'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.text(
        '1 background tasks are still processing. Insights may update after they finish.',
      ),
      findsWidgets,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('updates backlog count from task activity stream', (
    tester,
  ) async {
    final controller = StreamController<TaskActivitySnapshot>();
    await tester.pumpWidget(
      buildHost(taskActivitySnapshotStream: controller.stream),
    );
    await tester.pump();

    expect(find.text('AI is processing...'), findsNothing);

    controller.add(
      const TaskActivitySnapshot(pending: 2, processing: 1, retrying: 1),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('AI is processing...'), findsOneWidget);
    expect(
      find.text(
        '4 background tasks are still processing. Insights may update after they finish.',
      ),
      findsOneWidget,
    );

    controller.add(const TaskActivitySnapshot.empty());
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('AI is processing...'), findsNothing);

    await controller.close();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
