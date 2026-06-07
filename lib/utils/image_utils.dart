import 'package:memex/data/services/asset_safety_service.dart';
import 'package:memex/utils/logger.dart';

/// Image handling utilities
class ImageUtils {
  static final _logger = getLogger('ImageUtils');

  /// Get image dimensions (width, height, aspect ratio).
  /// Returns map: width, height (pixels, 0 on failure), aspectRatio (0.0 on failure).
  static Future<Map<String, dynamic>> getImageDimensions(
    String imagePath,
  ) async {
    int width = 0;
    int height = 0;
    double aspectRatio = 0.0;

    try {
      final safety = await AssetSafetyService.instance.inspectFile(imagePath);
      if (safety.type == AssetSafetyType.missing) {
        _logger.warning("Image file not found: $imagePath");
        return {'width': width, 'height': height, 'aspectRatio': aspectRatio};
      }

      width = safety.width ?? 0;
      height = safety.height ?? 0;
      aspectRatio = safety.width != null && safety.height != null
          ? safety.width! / safety.height!
          : 0.0;
    } catch (e) {
      _logger.warning('Failed to get image dimensions for $imagePath: $e');
    }

    return {'width': width, 'height': height, 'aspectRatio': aspectRatio};
  }
}
