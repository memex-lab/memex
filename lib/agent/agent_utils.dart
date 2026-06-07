import 'package:memex/agent/prompts.dart';

/// Formats the asset analysis list into a string for LLM context.
///
/// Includes analysis text and available EXIF data (like GPS coordinates).
String formatAssetAnalysis(List<Map<String, dynamic>>? assetAnalyses,
    {bool includeExif = false}) {
  if (assetAnalyses == null || assetAnalyses.isEmpty) {
    return '';
  }

  var assetInfo = "\n\n${Prompts.cardAgentAssetAnalysisHeader}";

  for (var analysis in assetAnalyses) {
    final index = analysis['index'] as int;
    final name = analysis['name'] as String? ?? '';
    final analysisText = analysis['analysis'] as String? ?? '';

    assetInfo += Prompts.cardAgentAssetHeader(index, name);
    if (analysisText.trim().isEmpty) {
      assetInfo += "${Prompts.cardAgentAssetAnalysisEmpty}\n\n";
    } else {
      assetInfo += "$analysisText\n\n";
    }

    if (includeExif) {
      // Add EXIF data (especially GPS coordinates) for card agent to use
      final exifData = analysis['exif_data'] as Map<String, dynamic>?;
      if (exifData != null) {
        final captureTime = exifData['datetime_original'] as String?;
        if (captureTime != null && captureTime.trim().isNotEmpty) {
          assetInfo += 'Photo Capture Time: $captureTime\n';
        }
        final address = exifData['address'] as String?;
        if (address != null && address.trim().isNotEmpty) {
          assetInfo += 'Photo Capture Location: $address\n';
        }
        final userMarkedLocation = exifData['user_marked_location'] as String?;
        if (userMarkedLocation != null &&
            userMarkedLocation.trim().isNotEmpty) {
          assetInfo +=
              'Nearby User-Marked Location: $userMarkedLocation (within 50 meters)\n';
        }
        final gpsCoords = exifData['gps_coordinates'] as List<dynamic>?;
        if (gpsCoords != null && gpsCoords.length >= 2) {
          final lat = (gpsCoords[0] as num).toDouble();
          final lng = (gpsCoords[1] as num).toDouble();
          assetInfo += Prompts.cardAgentGpsCoordinates(lat, lng);
        }
      }
    }
  }
  return assetInfo;
}
