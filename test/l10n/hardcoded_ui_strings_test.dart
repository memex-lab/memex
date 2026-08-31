import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/card.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'language': 'zh'});
    await UserStorage.initL10n();
  });

  test('comment author labels resolve from l10n', () {
    expect(UserStorage.l10n.commentAuthorUser, '用户');
    expect(UserStorage.l10n.commentAuthorAi, 'AI');
    expect(UserStorage.l10n.authorizationCancelled, '授权已取消');
    expect(UserStorage.l10n.timelineWeekNumberLabel('12'), '第 12 周');
    expect(UserStorage.l10n.eventCardDefaultTitle, '事件');
    expect(UserStorage.l10n.memoryNoLongTermYet, '还没有长期记忆。');
  });

  test('replyDisplayNameFor falls back to localized AI label', () {
    final comment = Comment(
      id: 'c1',
      content: 'hello',
      timestamp: 1,
      isAi: true,
    );

    expect(
      replyDisplayNameFor(comment, UserStorage.l10n.commentAuthorUser),
      UserStorage.l10n.commentAuthorAi,
    );
  });
}
