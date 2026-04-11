import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:crypto/crypto.dart';
import 'package:share_handler/share_handler.dart';

import 'package:memex/ui/main_screen/widgets/input_sheet.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/services/resource_recognition/resource_recognizer.dart';

/// Handles system share intents (text, images) and forwards them
/// as drafts into the input sheet for user confirmation.
class ShareIntentHandler {
  final Logger logger;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final void Function(InputData) onSharedDraft;

  StreamSubscription<SharedMedia>? _mediaSubscription;
  bool _isHandlingShare = false;

  ShareIntentHandler({
    required this.logger,
    required this.scaffoldMessengerKey,
    required this.onSharedDraft,
  });

  void init() {
    final handler = ShareHandlerPlatform.instance;

    // Handle initial shared media when app is launched from share
    handler.getInitialSharedMedia().then((media) {
      if (media != null) {
        _handleSharedMedia(media);
      }
    });

    // Listen for media shared while app is in memory
    _mediaSubscription = handler.sharedMediaStream.listen((media) {
      _handleSharedMedia(media);
    }, onError: (err) {
      logger.warning('Error in sharedMediaStream: $err');
    });
  }

  Future<void> _handleSharedMedia(SharedMedia media) async {
    if (_isHandlingShare) return;

    _isHandlingShare = true;

    try {
      // Ensure model is configured before accepting shared content
      final configs = await UserStorage.getLLMConfigs();
      final hasValidConfig = configs.any((c) => c.isValid);
      if (!hasValidConfig) {
        ToastHelper.showErrorWithKey(
          scaffoldMessengerKey,
          UserStorage.l10n.modelNotConfiguredSubmitHint,
        );
        return;
      }

      var trimmedText =
          media.content == null || media.content!.trim().isEmpty
              ? null
              : media.content!.trim();

      final imageFiles = <XFile>[];

      final attachments = media.attachments ?? const [];
      for (final attachment in attachments) {
        if (attachment == null) continue;
        final path = attachment.path;
        if (path.isEmpty) continue;

        final isImageAttachment =
            attachment.type == SharedAttachmentType.image ||
                _looksLikeImageFile(path);
        if (isImageAttachment) {
          imageFiles.add(XFile(path));
        } else if (_looksLikeDocument(path)) {
          // Append document file path as a resource reference in text
          final fileName = path.split('/').last;
          final docRef = '[📎 $fileName]($path)';
          trimmedText = trimmedText == null
              ? docRef
              : '$trimmedText\n$docRef';
        }
      }

      // Generate hashes similar to InputSheet
      String? textHash;
      List<String>? imageHashes;

      if (trimmedText != null && trimmedText.isNotEmpty) {
        textHash = md5.convert(utf8.encode(trimmedText)).toString();
      }

      if (imageFiles.isNotEmpty) {
        imageHashes = [];
        for (final xFile in imageFiles) {
          try {
            final file = File(xFile.path);
            final length = await file.length();
            final rawHashStr =
                'photo_${file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : file.path}_$length';
            logger.info('Generating hash for shared image: $rawHashStr');
            imageHashes.add(md5.convert(utf8.encode(rawHashStr)).toString());
          } catch (e) {
            imageHashes.add(md5
                .convert(utf8.encode(
                    'photo_${xFile.path}_${DateTime.now().millisecondsSinceEpoch}'))
                .toString());
          }
        }
      }

      final inputData = InputData(
        text: trimmedText,
        images: imageFiles,
        textHash: textHash,
        imageHashes: imageHashes,
      );

      if (inputData.isEmpty) return;

      onSharedDraft(inputData);
    } catch (e, stackTrace) {
      logger.severe('Error handling shared media: $e', e, stackTrace);
      ToastHelper.showErrorWithKey(scaffoldMessengerKey, e);
    } finally {
      _isHandlingShare = false;
    }
  }

  void dispose() {
    _mediaSubscription?.cancel();
  }

  bool _looksLikeImageFile(String path) {
    final lowerPath = path.toLowerCase();
    const imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.heic',
      '.heif',
      '.bmp',
      '.tif',
      '.tiff',
    ];
    return imageExtensions.any(lowerPath.endsWith);
  }

  bool _looksLikeDocument(String path) {
    return ResourceRecognizer.detectFileType(path) != null;
  }
}

