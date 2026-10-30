import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:memex/domain/models/prepared_photo_attachment.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/result.dart';

class PhotoAttachmentService {
  PhotoAttachmentService._(this._assetLoader);

  @visibleForTesting
  factory PhotoAttachmentService.forTesting({
    required Future<AssetEntity?> Function(String) assetLoader,
  }) =>
      PhotoAttachmentService._(assetLoader);

  static final _instance = PhotoAttachmentService._(AssetEntity.fromId);
  static Future<Result<PreparedPhotoAttachment>> prepare(String assetId) =>
      _instance.prepareAsset(assetId);

  final Future<AssetEntity?> Function(String) _assetLoader;
  final Map<String, Future<Result<PreparedPhotoAttachment>>> _pending = {};

  Future<Result<PreparedPhotoAttachment>> prepareAsset(String assetId) {
    final existing = _pending[assetId];
    if (existing != null) return existing;
    final job = _prepare(assetId);
    _pending[assetId] = job;
    unawaited(job.then((_) {
      if (identical(_pending[assetId], job)) _pending.remove(assetId);
    }));
    return job;
  }

  Future<Result<PreparedPhotoAttachment>> _prepare(String assetId) =>
      runResult(() async {
        final watch = Stopwatch()..start();
        final asset = await _assetLoader(assetId);
        if (asset == null) throw StateError('Photo is no longer available');
        // Keep the original, including EXIF/GPS. The picker thumbnail is only
        // for presentation and must never replace the file sent to the agent.
        final file = await asset.originFile ?? await asset.file;
        if (file == null) throw StateError('Could not prepare original photo');
        getLogger('PhotoAttachmentService').fine(
          'Photo attachment original prepared in ${watch.elapsedMilliseconds}ms',
        );
        String name;
        try {
          name = await asset.titleAsync;
        } catch (_) {
          name = file.uri.pathSegments.last;
        }
        return PreparedPhotoAttachment(
          path: file.path,
          originalName: name.isEmpty ? file.uri.pathSegments.last : name,
        );
      });
}
