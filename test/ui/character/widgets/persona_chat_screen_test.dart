import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/character/widgets/persona_chat_screen.dart';

void main() {
  Widget buildSubject({
    required TextEditingController controller,
    required bool isStreaming,
    required VoidCallback onSend,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PersonaChatInputBar(
          controller: controller,
          isStreaming: isStreaming,
          onSend: onSend,
          hintText: 'Message...',
        ),
      ),
    );
  }

  testWidgets('send button is disabled until the user enters text',
      (tester) async {
    final controller = TextEditingController();
    var sends = 0;
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildSubject(
      controller: controller,
      isStreaming: false,
      onSend: () => sends++,
    ));

    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pump();
    expect(sends, 0);

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pump();
    expect(sends, 1);
  });

  testWidgets('streaming state disables text entry and sending',
      (tester) async {
    final controller = TextEditingController(text: 'hello');
    var sends = 0;
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildSubject(
      controller: controller,
      isStreaming: true,
      onSend: () => sends++,
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);

    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pump();
    expect(sends, 0);
  });

  test('reversed chat list reserves index zero for streaming content', () {
    expect(
      personaChatMessageIndexForReversedList(
        listIndex: 1,
        extraItems: 1,
      ),
      0,
    );
    expect(
      personaChatMessageIndexForReversedList(
        listIndex: 0,
        extraItems: 0,
      ),
      0,
    );
  });
}
