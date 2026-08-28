import 'package:flutter/material.dart';
import 'package:memex/data/services/api_exception.dart';
import 'package:memex/utils/user_storage.dart';

/// Helper class for showing toast notifications
class ToastHelper {
  /// Show error toast from exception
  static void showError(BuildContext? context, dynamic error) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(_buildErrorSnackBar(error));
  }

  /// Show success toast
  static void showSuccess(BuildContext? context, String message) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(_buildSuccessSnackBar(message));
  }

  /// Show success toast using GlobalKey
  static void showSuccessWithKey(
    GlobalKey<ScaffoldMessengerState> key,
    String message,
  ) {
    key.currentState?.showSnackBar(_buildSuccessSnackBar(message));
  }

  /// Show error toast using GlobalKey
  static void showErrorWithKey(
    GlobalKey<ScaffoldMessengerState> key,
    dynamic error,
  ) {
    key.currentState?.showSnackBar(_buildErrorSnackBar(error));
  }

  /// Show info toast
  static void showInfo(BuildContext? context, String message) {
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(_buildInfoSnackBar(message));
  }

  /// Show info toast using GlobalKey
  static void showInfoWithKey(
    GlobalKey<ScaffoldMessengerState> key,
    String message,
  ) {
    key.currentState?.showSnackBar(_buildInfoSnackBar(message));
  }

  static SnackBar _buildInfoSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.blue.shade600,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static SnackBar _buildSuccessSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static SnackBar _buildErrorSnackBar(dynamic error) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              formatErrorMessage(error),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFF334155), // dark blue-grey background
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 130, // above submit button to avoid overlap
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @visibleForTesting
  static String formatErrorMessage(dynamic error) {
    String errorMessage;
    if (error is ApiException) {
      errorMessage = error.message;
    } else if (error is Exception) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } else {
      errorMessage = error.toString();
    }
    if (errorMessage.trim().isEmpty) {
      return UserStorage.l10n.unknownError;
    }
    return errorMessage;
  }
}
