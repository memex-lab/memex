import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

typedef SuperAgentSessionFetcher = Future<Result<List<Map<String, dynamic>>>>
    Function();

@visibleForTesting
String? resolveLatestSuperAgentSessionId({
  required String? cachedSessionId,
  required List<Map<String, dynamic>> sessions,
}) {
  bool isHomeCompatible(Map<String, dynamic> session) {
    final scene = session['scene']?.toString().trim();
    return scene == null ||
        scene.isEmpty ||
        scene == 'assistant' ||
        scene == 'super_agent_home';
  }

  final normalizedCachedSessionId = cachedSessionId?.trim();
  if (normalizedCachedSessionId != null &&
      normalizedCachedSessionId.isNotEmpty) {
    for (final session in sessions) {
      if (session['session_id']?.toString() == normalizedCachedSessionId &&
          isHomeCompatible(session)) {
        return normalizedCachedSessionId;
      }
    }
  }

  for (final session in sessions) {
    if (session['scene'] == 'super_agent_home') {
      return session['session_id']?.toString();
    }
  }

  // Sessions created before the unified Super Agent entry used the default
  // assistant scene. They remain valid home conversations after reinstall.
  for (final session in sessions) {
    if (isHomeCompatible(session)) {
      return session['session_id']?.toString();
    }
  }
  return null;
}

Future<String?> latestSuperAgentSessionId({
  SuperAgentSessionFetcher? fetchSessions,
}) async {
  final cachedSessionId = await UserStorage.getLatestSuperAgentHomeSessionId();

  try {
    final result = await (fetchSessions?.call() ??
        MemexRouter().fetchChatSessions(agentName: 'memex_agent'));
    final sessionId = result.when(
      onOk: (sessions) => resolveLatestSuperAgentSessionId(
        cachedSessionId: cachedSessionId,
        sessions: sessions,
      ),
      // A transient storage error should not discard a potentially valid
      // pointer. ChatService validates it again before writing a new turn.
      onError: (_, __) => cachedSessionId,
    );
    if (sessionId == null || sessionId.isEmpty) {
      await UserStorage.clearLatestSuperAgentHomeSessionId();
      return null;
    }
    await UserStorage.setLatestSuperAgentHomeSessionId(sessionId);
    return sessionId;
  } catch (_) {
    return null;
  }
}

void openSuperAgentDialog(
  BuildContext context, {
  String? initialDraftText,
  List<XFile> initialImages = const [],
  Map<String, String> initialImageOriginalFilenames = const {},
  String? sceneId,
  List<Map<String, String>>? initialRefs,
  VoidCallback? onOpenScheduleTab,
}) {
  final sessionIdFuture = latestSuperAgentSessionId();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) {
      return buildSuperAgentDialogSessionGate(
        sessionIdFuture: sessionIdFuture,
        sceneId: sceneId,
        initialRefs: initialRefs,
        initialDraftText: initialDraftText,
        initialImages: initialImages,
        initialImageOriginalFilenames: initialImageOriginalFilenames,
        onOpenScheduleTab: onOpenScheduleTab,
      );
    },
  );
}

@visibleForTesting
Widget buildSuperAgentDialogSessionGate({
  required Future<String?> sessionIdFuture,
  String? initialDraftText,
  List<XFile> initialImages = const [],
  Map<String, String> initialImageOriginalFilenames = const {},
  String? sceneId,
  List<Map<String, String>>? initialRefs,
  VoidCallback? onOpenScheduleTab,
}) {
  return FutureBuilder<String?>(
    future: sessionIdFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const SizedBox.shrink();
      }

      final sessionId = snapshot.data;
      return AgentChatDialog(
        key: ValueKey(sessionId ?? 'super_agent_new_session'),
        initialSessionId: sessionId,
        sceneId: sceneId,
        initialRefs: initialRefs,
        initialDraftText: initialDraftText,
        initialImages: initialImages,
        initialImageOriginalFilenames: initialImageOriginalFilenames,
        onOpenScheduleTab: onOpenScheduleTab,
      );
    },
  );
}
