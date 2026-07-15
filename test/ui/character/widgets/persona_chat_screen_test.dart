import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/character/widgets/persona_chat_screen.dart';

void main() {
  test('loading older chat does not request an automatic bottom scroll', () {
    expect(
      shouldAutoScrollPersonaChat(
        previousCharacterId: 'yaoyao',
        currentCharacterId: 'yaoyao',
        previousNewestMessageId: 9,
        currentNewestMessageId: 9,
      ),
      isFalse,
    );
    expect(
      shouldAutoScrollPersonaChat(
        previousCharacterId: 'yaoyao',
        currentCharacterId: 'yaoyao',
        previousNewestMessageId: 9,
        currentNewestMessageId: 10,
      ),
      isTrue,
    );
  });

  Widget buildSubject({
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onSend,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PersonaChatInputBar(
          controller: controller,
          focusNode: focusNode,
          onSend: onSend,
          hintText: 'Message...',
        ),
      ),
    );
  }

  testWidgets('send button is disabled until the user enters text',
      (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var sends = 0;
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(buildSubject(
      controller: controller,
      focusNode: focusNode,
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

  testWidgets('input remains enabled for consecutive sends', (tester) async {
    final controller = TextEditingController(text: 'hello');
    final focusNode = FocusNode();
    var sends = 0;
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(buildSubject(
      controller: controller,
      focusNode: focusNode,
      onSend: () => sends++,
    ));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isNot(false));

    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pump();
    expect(sends, 1);

    await tester.enterText(find.byType(TextField), 'another message');
    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pump();
    expect(sends, 2);
  });

  testWidgets('sending keeps the input focused for the next message',
      (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var sends = 0;
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(buildSubject(
      controller: controller,
      focusNode: focusNode,
      onSend: () {
        sends++;
        controller.clear();
      },
    ));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.bySemanticsLabel('Send message'));
    await tester.pump();

    expect(sends, 1);
    expect(controller.text, isEmpty);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('tapping the message area dismisses the input focus',
      (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(
                controller: controller,
                focusNode: focusNode,
              ),
              Expanded(
                child: PersonaChatKeyboardDismissRegion(
                  focusNode: focusNode,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.byType(PersonaChatKeyboardDismissRegion));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });

  test('reversed chat list reserves index zero for the typing indicator', () {
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
