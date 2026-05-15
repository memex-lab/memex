// Copyright 2024 The Memex team. All rights reserved.
// Aligned with Compass: route path constants for go_router.

/// Route path constants for [GoRouter].
/// ViewModels are created in route builders and passed to screens.
abstract final class AppRoutes {
  AppRoutes._();

  /// Home (main screen with tabs).
  static const String home = '/';

  /// User setup (onboarding).
  static const String userSetup = '/user-setup';

  /// Personal center (settings).
  static const String personalCenter = '/personal-center';

  /// Timeline card detail; push as '/card/$cardId'.
  static const String timelineCardDetail = '/card';

  /// Calendar (push with extra: DateTime initialDate).
  static const String calendar = '/calendar';

  /// Chat history (push with extra: Map with agentName, title).
  static const String chatHistory = '/chat-history';

  /// Memory.
  static const String memory = '/memory';

  /// Character config.
  static const String characterConfig = '/character-config';

  /// Tavern character card import.
  static const String tavernImport = '/tavern-import';
}
