import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memex/ui/chat/view_models/photo_attachments_viewmodel.dart';
import 'package:memex/ui/core/widgets/reliable_asset_picker.dart';
import 'package:memex/utils/user_storage.dart';

/// Keeps the picker thumbnail visible while the original is being exported.
class SelectedPhotoAttachmentThumb extends StatelessWidget {
  const SelectedPhotoAttachmentThumb({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onRetry,
  });

  final SelectedPhotoAttachment item;
  final VoidCallback onRemove;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 72,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: item.nativeSelection == null
                    ? ReliableAssetThumbnail(asset: item.asset!)
                    : item.preview != null
                        ? Image.memory(item.preview!,
                            key: const Key('native-photo-preview'),
                            fit: BoxFit.cover,
                            gaplessPlayback: true)
                        : item.prepared != null
                            ? Image.file(File(item.prepared!.path),
                                fit: BoxFit.cover, cacheWidth: 200)
                            : const ColoredBox(color: Color(0xFF2A2A2A)),
              ),
            ),
            if (item.loading)
              const Positioned(
                left: 4,
                bottom: 4,
                child: SizedBox.square(
                  key: Key('selected-photo-preparing'),
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (item.failed)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: IconButton(
                    key: ValueKey('retry-photo-${item.id}'),
                    tooltip: UserStorage.l10n.retry,
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                key: ValueKey('remove-photo-${item.id}'),
                onTap: onRemove,
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
}
