import 'dart:async';
import 'package:memex/domain/models/native_photo_selection.dart';
import 'package:memex/data/services/native_photo_picker_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/prepared_photo_attachment.dart';
import 'package:memex/utils/async_work_queue.dart';
import 'package:memex/utils/result.dart';

typedef PhotoAttachmentLoader = Future<Result<PreparedPhotoAttachment>>
    Function(
  String assetId,
);

class SelectedPhotoAttachment {
  SelectedPhotoAttachment(AssetEntity selected)
      : asset = selected,
        nativeSelection = null;
  SelectedPhotoAttachment.native(NativePhotoSelection selected)
      : nativeSelection = selected,
        asset = null;
  final AssetEntity? asset;
  final NativePhotoSelection? nativeSelection;
  String get id => nativeSelection?.id ?? asset!.id;
  String? get assetId => nativeSelection?.assetId ?? asset?.id;
  Uint8List? preview;
  PreparedPhotoAttachment? prepared;
  bool failed = false;
  bool get loading => prepared == null && !failed;
}

class PhotoAttachmentsViewModel extends ChangeNotifier {
  PhotoAttachmentsViewModel({required MemexRouter router})
      : _loader = router.preparePhotoAttachment,
        _picker = router.pickNativePhotos,
        _nativeLoader = router.prepareNativePhotoAttachment,
        _previewLoader = router.nativePhotoThumbnail,
        _releaseNative = router.releaseNativePhoto;

  @visibleForTesting
  PhotoAttachmentsViewModel.forTesting({required PhotoAttachmentLoader loader})
      : _loader = loader,
        _picker = NativePhotoPickerService.pick,
        _nativeLoader = NativePhotoPickerService.prepare,
        _previewLoader = NativePhotoPickerService.thumbnail,
        _releaseNative = NativePhotoPickerService.release;

  final Future<Result<List<NativePhotoSelection>>> Function() _picker;
  final PhotoAttachmentLoader _loader;
  final PhotoAttachmentLoader _nativeLoader;
  final Future<Result<Uint8List?>> Function(String) _previewLoader;
  final Future<void> Function(String) _releaseNative;
  final AsyncWorkQueue _queue = AsyncWorkQueue(maxConcurrent: 2);
  final List<SelectedPhotoAttachment> _items = [];
  bool _disposed = false;

  List<SelectedPhotoAttachment> get items => List.unmodifiable(_items);
  bool get canSubmit => _items.every((item) => item.prepared != null);
  bool get isPreparing => _items.any((item) => item.loading);

  void addAssets(Iterable<AssetEntity> assets) {
    if (_disposed) return;
    final added = <SelectedPhotoAttachment>[];
    for (final asset in assets) {
      if (_items.any((item) => item.assetId == asset.id)) continue;
      final item = SelectedPhotoAttachment(asset);
      _items.add(item);
      added.add(item);
    }
    // Publish selections before starting potentially slow native exports.
    notifyListeners();
    for (final item in added) {
      _prepare(item);
    }
  }

  Future<Result<void>> pickNativePhotos(
      {Set<String> excludedAssetIds = const {}}) async {
    final result = await _picker();
    return result.when(
        onOk: (photos) {
          for (final photo in photos
              .where((photo) => excludedAssetIds.contains(photo.assetId))) {
            unawaited(_releaseSafely(photo.id));
          }
          addNativePhotos(photos
              .where((photo) => !excludedAssetIds.contains(photo.assetId)));
          return const Ok.v();
        },
        onError: (e, st) => Error<void>(e, st));
  }

  void addNativePhotos(Iterable<NativePhotoSelection> photos) {
    for (final photo in photos) {
      if (_items.any((item) => item.id == photo.id)) continue;
      if (_disposed ||
          _items.any((item) =>
              photo.assetId != null && item.assetId == photo.assetId)) {
        unawaited(_releaseSafely(photo.id));
        continue;
      }
      final item = SelectedPhotoAttachment.native(photo);
      _items.add(item);
      unawaited(_loadPreview(item));
      _prepare(item);
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> _loadPreview(SelectedPhotoAttachment item) async {
    final result = await _previewLoader(item.id);
    if (_disposed || !_items.contains(item)) return;
    result.when(onOk: (bytes) => item.preview = bytes, onError: (_, __) {});
    notifyListeners();
  }

  Future<void> _releaseSafely(String id) async {
    try {
      await _releaseNative(id);
    } catch (e, st) {
      getLogger('PhotoAttachmentsViewModel')
          .fine('Release picker selection failed', e, st);
    }
  }

  void _release(SelectedPhotoAttachment item) {
    if (item.nativeSelection != null) unawaited(_releaseSafely(item.id));
  }

  void _prepare(SelectedPhotoAttachment item) {
    unawaited(_queue.run(() async {
      if (_disposed || !_items.contains(item)) return;
      final result = await (item.nativeSelection == null
          ? _loader(item.asset!.id)
          : _nativeLoader(item.id));
      if (_disposed || !_items.contains(item)) return;
      result.when(
        onOk: (photo) => item.prepared = photo,
        onError: (_, __) => item.failed = true,
      );
      notifyListeners();
    }));
  }

  void retry(SelectedPhotoAttachment item) {
    if (_disposed || !_items.contains(item) || !item.failed) return;
    item.failed = false;
    notifyListeners();
    _prepare(item);
  }

  void remove(SelectedPhotoAttachment item) {
    if (_items.remove(item)) _release(item);
    notifyListeners();
  }

  void clear() {
    for (final item in _items) {
      _release(item);
    }
    _items.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final item in _items) {
      _release(item);
    }
    _items.clear();
    super.dispose();
  }
}
