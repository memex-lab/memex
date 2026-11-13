import 'package:memex/data/services/file_system_service.dart';
import 'package:memex/data/services/local_task_executor.dart';
import 'package:memex/data/services/task_handlers/llm_error_utils.dart';
import 'package:memex/data/services/timeline_card_event_publisher.dart';
import 'package:memex/utils/network_reachability.dart';
import 'package:memex/utils/user_storage.dart';

/// Timeline card status while a capture is stored and waiting for connectivity.
const waitingForNetworkCardStatus = 'waiting_for_network';

/// Mark a pre-minted capture card failed, or waiting when [error] is offline.
Future<void> settleCaptureCardForError({
  required String userId,
  required String factId,
  required Object error,
}) async {
  final waiting = looksLikeNetworkError(error);
  final reason = waiting
      ? UserStorage.l10n.llmNetworkError
      : getLocalizedErrorMessage(classifyError(error), error);
  final updated = await FileSystemService.instance.updateCardFile(
    userId,
    factId,
    (card) {
      if (card.status != 'processing' &&
          card.status != waitingForNetworkCardStatus) {
        return card;
      }
      return card.copyWith(
        status: waiting ? waitingForNetworkCardStatus : 'failed',
        failureReason: reason,
      );
    },
  );
  if (updated != null &&
      (updated.status == waitingForNetworkCardStatus ||
          updated.status == 'failed')) {
    await emitTimelineCardUpdated(
      userId: userId,
      cardId: factId,
      cardData: updated,
    );
  }
}

/// Put the queued capture for [factId] back into the runnable queue and show
/// it as processing. Returns false when no saved turn references the card.
Future<bool> requeueCaptureCard(String factId) async {
  final queued = await LocalTaskExecutor.instance.requeueCaptureTask(factId);
  if (!queued) return false;
  final userId = await UserStorage.getUserId();
  if (userId == null || userId.isEmpty) return true;
  final updated = await FileSystemService.instance.updateCardFile(
    userId,
    factId,
    (card) {
      if (card.status == 'completed') return card;
      return card.copyWith(
        status: 'processing',
        clearFailureReason: true,
      );
    },
  );
  if (updated != null && updated.status == 'processing') {
    await emitTimelineCardUpdated(
      userId: userId,
      cardId: factId,
      cardData: updated,
    );
  }
  return true;
}
