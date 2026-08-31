import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:memex/data/services/photo_thumbnail_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

const Key reliableThumbnailLoadingKey = Key('reliable-thumbnail-loading');
const Key reliableThumbnailFailureKey = Key('reliable-thumbnail-failure');
const Key reliableThumbnailImageKey = Key('reliable-thumbnail-image');

/// A picker grid thumbnail that participates in bounded, cancellable loading.
class ReliableAssetThumbnail extends StatefulWidget {
  const ReliableAssetThumbnail({
    super.key,
    required this.asset,
    this.size = const ThumbnailSize.square(200),
    this.service,
  });

  final AssetEntity asset;
  final ThumbnailSize size;
  final PhotoThumbnailService? service;

  @override
  State<ReliableAssetThumbnail> createState() => _ReliableAssetThumbnailState();
}

class _ReliableAssetThumbnailState extends State<ReliableAssetThumbnail> {
  PhotoThumbnailRequest? _request;
  Uint8List? _bytes;
  bool _loading = true;
  int _attempt = 0;

  PhotoThumbnailService get _service =>
      widget.service ?? PhotoThumbnailService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ReliableAssetThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id ||
        oldWidget.size != widget.size ||
        oldWidget.service != widget.service) {
      _cancelRequest();
      _bytes = null;
      _attempt = 0;
      _load();
    }
  }

  void _load() {
    _attempt += 1;
    final request = _service.request(widget.asset, size: widget.size);
    _request = request;
    if (mounted) {
      setState(() => _loading = true);
    }
    request.future.then((bytes) {
      if (!mounted || !identical(_request, request)) return;
      if (bytes == null && _attempt < 2) {
        _request = null;
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 120), () {
            if (mounted && _request == null) {
              _load();
            }
          }),
        );
        return;
      }
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    });
  }

  void _retry() {
    _cancelRequest();
    _attempt = 0;
    _load();
  }

  void _cancelRequest() {
    final request = _request;
    _request = null;
    request?.cancel();
  }

  @override
  void dispose() {
    _cancelRequest();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes case final bytes?) {
      return Image.memory(
        bytes,
        key: reliableThumbnailImageKey,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }
    if (_loading) {
      return const ColoredBox(
        color: Color(0xFF2A2A2A),
        child: Center(
          child: SizedBox.square(
            key: reliableThumbnailLoadingKey,
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Color(0x99FFFFFF),
            ),
          ),
        ),
      );
    }
    return Material(
      key: reliableThumbnailFailureKey,
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: _retry,
        child: const Center(
          child: Icon(Icons.refresh, color: Color(0xB3FFFFFF), size: 22),
        ),
      ),
    );
  }
}

class ReliableAssetPickerBuilderDelegate
    extends DefaultAssetPickerBuilderDelegate<DefaultAssetPickerProvider> {
  ReliableAssetPickerBuilderDelegate({
    required super.provider,
    required super.initialPermission,
    required super.locale,
  }) : super(
          gridThumbnailSize: const ThumbnailSize.square(200),
        );

  @override
  Widget imageAndVideoItemBuilder(
    BuildContext context,
    int index,
    AssetEntity asset,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: ReliableAssetThumbnail(
            key: ValueKey('reliable-thumbnail-${asset.id}'),
            asset: asset,
            size: gridThumbnailSize,
          ),
        ),
        if (enableLivePhoto && asset.isLivePhoto)
          buildLivePhotoIndicator(context, asset),
      ],
    );
  }
}

/// Opens the image-only picker with lower page pressure and reliable cells.
Future<List<AssetEntity>?> pickReliableImageAssets(
  BuildContext context, {
  int maxAssets = 9,
}) async {
  const permissionOption = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );
  final permission = await AssetPicker.permissionCheck(
    requestOption: permissionOption,
  );
  if (!context.mounted) return null;

  final provider = DefaultAssetPickerProvider(
    maxAssets: maxAssets,
    pageSize: 40,
    requestType: RequestType.image,
  );
  final delegate = ReliableAssetPickerBuilderDelegate(
    provider: provider,
    initialPermission: permission,
    locale: Localizations.maybeLocaleOf(context),
  );
  return AssetPicker.pickAssetsWithDelegate<AssetEntity, AssetPathEntity,
      DefaultAssetPickerProvider, ReliableAssetPickerBuilderDelegate>(
    context,
    delegate: delegate,
    permissionRequestOption: permissionOption,
  );
}
