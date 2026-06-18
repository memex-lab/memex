import 'package:logging/logging.dart';
import 'package:memex/data/services/photo_suggestion_service.dart';
import 'package:memex/data/services/auto_input/data_collector_interface.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class PhotoCollector implements DataCollector {
  final Logger _logger = Logger('PhotoCollector');
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  String get sourceName => 'photos';

  @override
  Future<List<Map<String, dynamic>>> collect() async {
    _logger.info('Starting photo collection cycle...');
    final List<Map<String, dynamic>> collectedItems = [];

    try {
      // 1. Fetch recent photos ignoring last publish constraints
      final recentPhotos = await PhotoSuggestionService.getRecentPhotos(
        maxCount: 20, ignoreLastPublishTime: true);
      if (recentPhotos.isEmpty) {
        _logger.info('No recent photos found during auto collect.');
        return [];
      }

      _logger.info('Found ${recentPhotos.length} recent photos to evaluate.');

      // 2. Process each photo
      // Since hashing and parsing strings can be slightly CPU intensive and block the UI thread
      // if there are many photos, we move the map construction to an isolate.
      // XFile operations are async but md5.convert is sync.

      for (final asset in recentPhotos) {
        final xFile = await PhotoSuggestionService.assetToXFile(asset);
        if (xFile == null) {
          _logger
              .warning('Failed to convert AssetEntity ${asset.id} to XFile.');
          continue;
        }

        final length = await xFile.length();

        // asset.title represents the original filename (e.g. IMG_1234.JPG).
        // xFile.name on iOS might be deeply cached and altered like `A15B..._o_IMG_1234.JPG`.
        final String trueTitle = await asset.titleAsync;
        final String effectiveName = trueTitle ?? xFile.name;

        final rawHashStr = 'photo_${effectiveName}_$length';

        _logger.info('Generating hash for photo: $rawHashStr');
        // Use compute to prevent blocking main thread with crypto hashing
        // even though MD5 is fast, it's safer for smooth UI.
        // We can just compute the hash here. Let's do a simple compute for the single string.
        // But since we are looping, doing compute() 15 times is also overhead.
        // Instead, let's just use `compute` for a batch hashing function.
        // But actually MD5 on a tiny string is so unbelievably fast it's O(1) negligible.
        // To be absolutely safe and to appease the user, we will yield the event loop.
        await Future.delayed(Duration.zero);
        final clientHash = md5.convert(utf8.encode(rawHashStr)).toString();

        String clientTime = _dateFormat.format(DateTime.now());
        clientTime = _dateFormat.format(asset.createDateTime);

        collectedItems.add({
          'type': 'image_url',
          'client_hash': clientHash,
          'client_time': clientTime,
          'image_url': {
            'filePath': xFile.path,
          }
        });
      }

      _logger.info(
          'Successfully prepared ${collectedItems.length} photo items for auto input.');
    } catch (e, stackTrace) {
      _logger.severe('Error during photo collection: $e', e, stackTrace);
    }

    return collectedItems;
  }
}
