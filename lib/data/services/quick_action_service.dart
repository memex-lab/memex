import 'dart:async';
import 'package:logging/logging.dart';
import 'package:memex/utils/logger.dart';

/// Manages app-icon quick actions (long-press shortcuts).
///
/// Handles both cold-start and warm-start scenarios by queuing the action
/// until a listener is ready to consume it. This decouples the platform
/// channel callback timing from the widget lifecycle.
class QuickActionService {
  QuickActionService._();
  static final QuickActionService instance = QuickActionService._();

  final Logger _logger = getLogger('QuickActionService');

  /// The action ID that was tapped, if not yet consumed.
  String? _pendingAction;

  /// The last action type that was consumed.
  /// Used to deduplicate the double delivery from quick_actions_android
  /// (onAttachedToActivity fires once, then initialize()→getLaunchAction()
  /// fires again ~1 s later with the same action).
  String? _consumedAction;

  /// Listener notified when an action arrives or becomes consumable.
  Completer<void>? _actionReady;

  /// Whether a listener is currently attached and ready.
  bool _hasListener = false;

  /// Called by the platform quick_actions callback.
  void handleAction(String actionType) {
    _logger.info('Quick action received: $actionType');
    if (actionType == _consumedAction) {
      _logger.info('Ignoring re-delivered action: $actionType');
      return;
    }
    _pendingAction = actionType;
    if (_hasListener) {
      // Listener is ready — deliver immediately.
      _actionReady?.complete();
    }
  }

  /// Register that [MainScreen] is ready to handle actions.
  void attach() {
    _hasListener = true;
  }

  /// Detach when [MainScreen] is disposed.
  void detach() {
    _hasListener = false;
    _actionReady?.complete();
    _actionReady = null;
  }

  /// Consume the pending action synchronously without waiting.
  ///
  /// Use this when the platform callback is expected to have already fired
  /// (e.g. on app resume). Unlike [consumePendingAction], this does NOT wait
  /// for a late-arriving callback, which prevents re-delivered shortcut
  /// intents from re-triggering the action.
  String? consumeIfPending() {
    final action = _pendingAction;
    _pendingAction = null;
    if (action != null) _consumedAction = action;
    return action;
  }

  /// Wait for and consume the pending action.
  ///
  /// Returns the action type, or `null` if no action is pending.
  /// If an action arrives after this call, it will be delivered via
  /// the returned future (with a reasonable timeout).
  Future<String?> consumePendingAction() async {
    // Already have a pending action — consume immediately.
    if (_pendingAction != null) {
      final action = _pendingAction;
      _pendingAction = null;
      _consumedAction = action;
      return action;
    }

    // No action yet — wait briefly for a late-arriving callback.
    _actionReady = Completer<void>();
    try {
      await _actionReady!.future.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      // No action arrived within the window.
    }
    _actionReady = null;

    final action = _pendingAction;
    _pendingAction = null;
    if (action != null) _consumedAction = action;
    return action;
  }

  /// Reset the dedup tracking so the same action type can be consumed again.
  /// Called when the app goes to background, allowing a fresh shortcut trigger
  /// on the next foreground session.
  void resetConsumed() {
    _consumedAction = null;
  }
}
