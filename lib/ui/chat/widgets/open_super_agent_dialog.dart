import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

Future<String?> latestSuperAgentSessionId() async {
  final cachedSessionId = await UserStorage.getLatestSuperAgentHomeSessionId();
  if (cachedSessionId != null) return cachedSessionId;

  try {
    final result = await MemexRouter().fetchChatSessions(
      agentName: 'memex_agent',
      limit: 30,
    );
    final sessionId = result.when(
      onOk: (sessions) {
        for (final session in sessions) {
          if (session['scene'] == 'super_agent_home') {
            return session['session_id']?.toString();
          }
        }
        return null;
      },
      onError: (_, __) => null,
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
      );
    },
  );
}
