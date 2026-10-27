import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memex/agent/run_mode/agent_action_approval_service.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/l10n/app_localizations.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await initializeDateFormatting('en');
    await UserStorage.initL10n();
  });

  testWidgets(
      'streamed tokens update the reply without restarting scroll '
      'until the 250ms boundary', (tester) async {
    final chat = await _ChatHarness.pump(tester);
    await chat.showHistory(tester);

    await chat.emit(tester, ChatResponseChunkEvent('turn', 'First'));
    expect(chat.controller.position.isScrollingNotifier.value, isTrue);
    await tester.pumpAndSettle();
    expect(
        find.text('First', findRichText: true).hitTestable(), findsOneWidget);

    // Simulate interrupting auto-scroll to read older messages. A token inside
    // the throttle window must not start another scroll animation.
    await chat.showHistory(tester);
    chat.elapsed = const Duration(milliseconds: 249);
    await chat.emit(tester, ChatResponseChunkEvent('turn', ' second'));
    expect(chat.controller.position.isScrollingNotifier.value, isFalse);
    expect(chat.controller.offset, greaterThan(0));

    chat.elapsed = const Duration(milliseconds: 250);
    await chat.emit(tester, ChatResponseChunkEvent('turn', ' third'));
    expect(chat.controller.position.isScrollingNotifier.value, isTrue);
    await tester.pumpAndSettle();
    expect(chat.controller.offset, closeTo(0, 0.01));
    expect(
      find.text('First second third', findRichText: true).hitTestable(),
      findsOneWidget,
    );
  });

  final terminalEvents = <String, ChatEvent Function()>{
    'completed reply': () =>
        ChatResponseChunkEvent('turn', ' done', isDone: true),
    'agent stop': () => ChatAgentStoppedEvent('turn'),
    'error': () => ChatErrorEvent('turn', 'Unable to finish'),
  };
  for (final entry in terminalEvents.entries) {
    testWidgets('${entry.key} scrolls immediately inside the throttle window',
        (tester) async {
      final chat = await _ChatHarness.pump(tester);
      await chat.emit(tester, ChatResponseChunkEvent('turn', 'Answer'));
      await tester.pumpAndSettle();
      await chat.showHistory(tester);

      chat.elapsed = const Duration(milliseconds: 100);
      await chat.emit(tester, entry.value());
      expect(chat.controller.position.isScrollingNotifier.value, isTrue);
      await tester.pumpAndSettle();
      expect(chat.controller.offset, closeTo(0, 0.01));
      final visibleText = entry.key == 'error'
          ? 'Unable to finish'
          : entry.key == 'completed reply'
              ? 'Answer done'
              : 'Answer';
      expect(
        find.text(visibleText, findRichText: true).hitTestable(),
        findsOneWidget,
      );
    });
  }

  testWidgets('approval requests remain visible inside the throttle window',
      (tester) async {
    final chat = await _ChatHarness.pump(tester);
    await chat.emit(tester, ChatSessionCreatedEvent('scroll-approval-session'));
    await tester.pumpAndSettle();
    await chat.showHistory(tester);
    chat.elapsed = const Duration(milliseconds: 100);

    final approval = AgentActionApprovalService.instance.requestApproval(
      sessionId: 'scroll-approval-session',
      toolName: 'manage_pkm',
      summary: 'Save this knowledge note?',
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(chat.controller.offset, closeTo(0, 0.01));
    expect(
        find.text('Save this knowledge note?').hitTestable(), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(await approval, isFalse);
  });

  testWidgets('full-screen action still scrolls inside the throttle window',
      (tester) async {
    final chat = await _ChatHarness.pump(tester);
    await chat.emit(tester, ChatResponseChunkEvent('turn', 'Newest answer'));
    await tester.pumpAndSettle();
    await chat.showHistory(tester);
    chat.elapsed = const Duration(milliseconds: 100);

    await tester
        .tap(find.byKey(const ValueKey('agent_chat_fullscreen_toggle')));
    await tester.pumpAndSettle();

    expect(chat.controller.offset, closeTo(0, 0.01));
    expect(
      find.text('Newest answer', findRichText: true).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('disposing with a buffered token cancels pending UI work',
      (tester) async {
    final chat = await _ChatHarness.pump(tester);
    chat.events.add(ChatResponseChunkEvent('turn', 'Pending'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}

class _ChatHarness {
  final events = StreamController<ChatEvent>();
  Duration elapsed = Duration.zero;
  late ScrollController controller;

  static Future<_ChatHarness> pump(WidgetTester tester) async {
    final chat = _ChatHarness();
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(chat.events.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AgentChatDialog(
          initialItems: [
            for (var i = 0; i < 30; i++)
              UserMessageItem('History message $i with enough text to wrap '
                  'onto multiple lines in the conversation.'),
          ],
          chatEventsForTesting: chat.events.stream,
          scrollClockForTesting: () =>
              DateTime.utc(2026, 9, 16).add(chat.elapsed),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final transcript = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.reverse,
    );
    expect(transcript, findsOneWidget);
    chat.controller = tester.widget<ListView>(transcript).controller!;
    expect(chat.controller.position.maxScrollExtent, greaterThan(600));
    return chat;
  }

  Future<void> showHistory(WidgetTester tester) async {
    controller.jumpTo(600);
    await tester.pump();
    expect(controller.offset, greaterThan(0));
    expect(controller.position.isScrollingNotifier.value, isFalse);
  }

  Future<void> emit(WidgetTester tester, ChatEvent event) async {
    events.add(event);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
  }
}
