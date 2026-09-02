import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/memory/view_models/memory_viewmodel.dart';
import 'package:memex/ui/memory/widgets/memory_screen.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMemoryViewModel extends MemoryViewModel {
  _FakeMemoryViewModel() : super(router: MemexRouter());

  @override
  Future<void> loadMemory() async {
    isLoading = false;
    memoryData = {
      'archived_memory': '',
      'recent_buffer': <Map<String, dynamic>>[],
    };
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'language': 'en'});
    await UserStorage.initL10n();
  });

  testWidgets('MemoryScreen shows localized title and empty states', (
    tester,
  ) async {
    final vm = _FakeMemoryViewModel();

    await tester.pumpWidget(
      MaterialApp(
        home: MemoryScreen(viewModel: vm),
      ),
    );
    await tester.pump();

    expect(find.text(UserStorage.l10n.memoryTitle), findsOneWidget);
    expect(find.text(UserStorage.l10n.longTermProfile), findsOneWidget);
    expect(find.text(UserStorage.l10n.recentBuffer), findsOneWidget);
    expect(find.text(UserStorage.l10n.memoryNoLongTermYet), findsOneWidget);
  });
}
