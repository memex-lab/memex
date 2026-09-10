import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';

void main() {
  test('throttles chat scroll unless forced', () {
    final start = DateTime.utc(2026, 9, 10, 12);
    const gap = Duration(milliseconds: 250);

    expect(
      shouldScrollChatToBottom(
        now: start,
        lastScrollAt: null,
        minInterval: gap,
        force: false,
      ),
      isTrue,
    );
    expect(
      shouldScrollChatToBottom(
        now: start.add(const Duration(milliseconds: 100)),
        lastScrollAt: start,
        minInterval: gap,
        force: false,
      ),
      isFalse,
    );
    expect(
      shouldScrollChatToBottom(
        now: start.add(const Duration(milliseconds: 100)),
        lastScrollAt: start,
        minInterval: gap,
        force: true,
      ),
      isTrue,
    );
    expect(
      shouldScrollChatToBottom(
        now: start.add(gap),
        lastScrollAt: start,
        minInterval: gap,
        force: false,
      ),
      isTrue,
    );
  });
}
