import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/character_model.dart';
import 'package:memex/domain/models/persona_chat.dart';
import 'package:memex/ui/character/view_models/persona_avatar_viewmodel.dart';
import 'package:memex/ui/character/widgets/persona_avatar_button.dart';
import 'package:memex/ui/core/widgets/character_avatar.dart';
import 'package:memex/utils/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('loads the companion after the first frame', (tester) async {
    final character = CharacterModel(
      id: 'friend',
      name: '小安',
      tags: const [],
      persona: '温柔的朋友',
      enabled: true,
    );
    final router = _FakeMemexRouter(PersonaAvatarSummary(
      character: character,
      unreadCount: 1,
    ));
    final viewModel = PersonaAvatarViewModel(router: router);
    addTearDown(viewModel.dispose);

    expect(router.loadCount, 0);
    expect(viewModel.character, isNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PersonaAvatarButton(
            viewModel: viewModel,
            onTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(router.loadCount, 1);
    expect(find.byType(CharacterAvatar), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('renders an empty slot when no companion is available',
      (tester) async {
    final viewModel = PersonaAvatarViewModel(
      router: _FakeMemexRouter(const PersonaAvatarSummary(
        character: null,
        unreadCount: 0,
      )),
    );
    await viewModel.refresh();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PersonaAvatarButton(
            viewModel: viewModel,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(CharacterAvatar), findsNothing);
  });

  testWidgets('renders unread count and delegates taps', (tester) async {
    final character = CharacterModel(
      id: 'friend',
      name: '小安',
      tags: const [],
      persona: '温柔的朋友',
      enabled: true,
    );
    final viewModel = PersonaAvatarViewModel(
      router: _FakeMemexRouter(PersonaAvatarSummary(
        character: character,
        unreadCount: 3,
      )),
    );
    await viewModel.refresh();
    CharacterModel? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: PersonaAvatarButton(
            viewModel: viewModel,
            onTap: (value) => tapped = value,
          ),
        ),
      ),
    );

    expect(find.byType(CharacterAvatar), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.byType(PersonaAvatarButton));
    expect(tapped?.id, 'friend');
  });
}

class _FakeMemexRouter implements MemexRouter {
  _FakeMemexRouter(this.summary);

  final PersonaAvatarSummary summary;
  int loadCount = 0;

  @override
  Future<Result<PersonaAvatarSummary>> loadPersonaAvatarSummary() async {
    loadCount += 1;
    return Ok(summary);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
