import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:camera/camera.dart';
import 'publish_timestamp_service.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Photo suggestion service (album images)
class PhotoSuggestionService {
  static final Logger _logger = getLogger('PhotoSuggestionService');
  static const int _cacheVersion = 3; // bump version to invalidate old cache

  /// Get recent new images (up to 5). Returns list of AssetEntity.
  static Future<List<AssetEntity>> getRecentPhotos({
    int maxCount = 5,
    bool ignoreLastPublishTime = false,
  }) async {
    try {
      _logger.fine(
          'Fetching recent photos, platform: ${Platform.isAndroid ? "Android" : "iOS"}');

      // Check album permission (Android and iOS)
      PermissionStatus permissionStatus;
      if (Platform.isAndroid) {
        // Android 13+ use photos, older use storage
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isGranted) {
          permissionStatus = photosStatus;
        } else {
          final storageStatus = await Permission.storage.status;
          permissionStatus =
              storageStatus.isGranted ? storageStatus : photosStatus;
        }
      } else {
        // iOS: only NSPhotoLibraryUsageDescription in Info.plist; no ACCESS_MEDIA_LOCATION
        // photo_manager handles permission request on iOS
        permissionStatus = await Permission.photos.status;
      }

      if (!permissionStatus.isGranted) {
        _logger.info('Photo permission not granted, requesting...');
        // If not granted, try request
        PermissionStatus result;
        if (Platform.isAndroid) {
          final photosResult = await Permission.photos.request();
          result = photosResult.isGranted
              ? photosResult
              : await Permission.storage.request();
        } else {
          result = await Permission.photos.request();
        }
        if (!result.isGranted) {
          _logger.warning('Photo permission denied');
          return [];
        }
      }

      if (Platform.isAndroid) {
        // Android 10+ need ACCESS_MEDIA_LOCATION for GPS in photos
        try {
          final mediaLocationStatus =
              await Permission.accessMediaLocation.status;
          if (!mediaLocationStatus.isGranted) {
            await Permission.accessMediaLocation.request();
          }
        } catch (e) {
          // If permission not available (older Android), ignore
          _logger.fine('ACCESS_MEDIA_LOCATION not available: $e');
        }
      }

      _logger.fine('Permission check passed, fetching timestamp');

      FilterOptionGroup filterOptions;

      if (ignoreLastPublishTime) {
        // No time filter, get latest photos
        filterOptions = FilterOptionGroup(
          imageOption: const FilterOption(
            needTitle: false,
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
          orders: [
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false,
            ),
          ],
        );
      } else {
        // Get query timestamp
        final queryTimestamp =
            await PublishTimestampService.getQueryTimestamp();
        final queryDateTime =
            DateTime.fromMillisecondsSinceEpoch(queryTimestamp);
        final now = DateTime.now();
        _logger.fine('Query timestamp: $queryTimestamp, time: $queryDateTime');

        // Filter by time range in FilterOption
        filterOptions = FilterOptionGroup(
          imageOption: const FilterOption(
            needTitle: false,
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
          // creation time must be after query time
          createTimeCond: DateTimeCond(
            min: queryDateTime,
            max: now,
          ),
          orders: [
            // order by creation time desc (newest first)
            const OrderOption(
              type: OrderOptionType.createDate,
              asc: false,
            ),
          ],
        );
      }

      // Get albums (filter applied, all-photos album)
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
        filterOption: filterOptions,
      );

      if (albums.isEmpty) {
        _logger.fine('No albums found');
        return [];
      }

      // Use first (all-photos) album
      final allPhotosAlbum = albums[0];

      // Get up to maxCount matching images via getAssetListPaged
      final result = await allPhotosAlbum.getAssetListPaged(
        page: 0,
        size: maxCount,
      );
      _logger.info('Got ${result.length} recent photo(s)');
      return result;
    } catch (e, stackTrace) {
      _logger.severe('Failed to get album photos: $e', e, stackTrace);
      return [];
    }
  }

  /// Get thumbnail file for image
  static Future<File?> getThumbnailFile(
    AssetEntity asset, {
    int width = 200,
    int height = 200,
  }) async {
    try {
      final thumbnail = await asset.thumbnailDataWithSize(
        ThumbnailSize(width, height),
      );
      if (thumbnail == null) {
        _logger.warning('Thumbnail is null, asset.id: ${asset.id}');
        return null;
      }

      // Save thumbnail to temp file
      final tempDir = Directory.systemTemp;
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      // Sanitize asset.id (e.g. remove /) to avoid path issues
      final safeAssetId = asset.id.replaceAll(RegExp(r'[/\\]'), '_');
      final tempFile = File('${tempDir.path}/thumbnail_$safeAssetId.jpg');
      await tempFile.writeAsBytes(thumbnail);
      return tempFile;
    } catch (e, stackTrace) {
      _logger.severe('Failed to get thumbnail: $e', e, stackTrace);
      return null;
    }
  }

  /// Get original image file
  static Future<File?> getOriginalFile(AssetEntity asset) async {
    try {
      final file = await asset.file;
      return file;
    } catch (e) {
      _logger.severe('Failed to get original file: $e', e);
      return null;
    }
  }

  /// Convert AssetEntity to XFile (for upload). Use originFile to preserve GPS/EXIF.
  static Future<XFile?> assetToXFile(AssetEntity asset) async {
    try {
      // originFile keeps full EXIF (including GPS); file may lose metadata
      final file = await asset.originFile;
      if (file == null) {
        _logger.warning('originFile is null, falling back to file');
        // Fallback to file if originFile fails
        final fallbackFile = await asset.file;
        if (fallbackFile == null) {
          return null;
        }
        return XFile(fallbackFile.path);
      }
      return XFile(file.path);
    } catch (e) {
      _logger.severe('Failed to convert AssetEntity to XFile: $e', e);
      return null;
    }
  }

  /// Fetch and cluster recent photos
  static Future<List<List<EnhancedPhoto>>> fetchAndClusterRecentPhotos({
    int maxCount = 10,
    bool ignoreLastPublishTime = true,
  }) async {
    final recentPhotos = await getRecentPhotos(
        maxCount: maxCount, ignoreLastPublishTime: ignoreLastPublishTime);
    if (recentPhotos.isEmpty) {
      return [];
    }

    _logger.info('Clustering ${recentPhotos.length} recent photo(s)...');

    // 1. Precompute hashes for batch check
    final List<
        ({
          AssetEntity asset,
          String rawHashStr,
          String md5Hash,
          XFile xFile
        })> photoInfoList = [];
    for (final asset in recentPhotos) {
      final xFile = await assetToXFile(asset);
      if (xFile == null) continue;

      final length = await xFile.length();
      final String? trueTitle = await asset.titleAsync;
      final String effectiveName = trueTitle ?? xFile.name;
      final rawHashStr = 'photo_${effectiveName}_$length';

      photoInfoList.add(
          (asset: asset, rawHashStr: rawHashStr, md5Hash: '', xFile: xFile));
    }

    if (photoInfoList.isEmpty) return [];

    // Load cache early to check unprocessed fast
    var cache = await UserStorage.getPhotoSuggestionCache();
    bool cacheChanged = false;

    // If cache version mismatch, clear and start fresh
    final int currentVersion = cache['__version__'] as int? ?? 0;
    if (currentVersion != _cacheVersion) {
      _logger.fine(
          'Cache version mismatch ($currentVersion vs $_cacheVersion), clearing.');
      cache = {
        '__version__': _cacheVersion,
        'data': <String, dynamic>{}, // real data under 'data'
      };
      cacheChanged = true;
    }

    // ensure data fieldexists
    if (!cache.containsKey('data')) {
      cache['data'] = <String, dynamic>{};
      cacheChanged = true;
    }
    final Map<String, dynamic> cacheData =
        cache['data'] as Map<String, dynamic>;

    for (int i = 0; i < photoInfoList.length; i++) {
      var pi = photoInfoList[i];
      final rawData = cacheData[pi.rawHashStr];
      if (rawData is Map<String, dynamic>) {
        // cache hit: use stored md5Hash
        final cachedMd5 = rawData['md5Hash'] as String? ??
            md5.convert(utf8.encode(pi.rawHashStr)).toString();
        photoInfoList[i] = (
          asset: pi.asset,
          rawHashStr: pi.rawHashStr,
          md5Hash: cachedMd5,
          xFile: pi.xFile
        );
      } else {
        // no cache: compute md5
        final computedMd5 = md5.convert(utf8.encode(pi.rawHashStr)).toString();
        photoInfoList[i] = (
          asset: pi.asset,
          rawHashStr: pi.rawHashStr,
          md5Hash: computedMd5,
          xFile: pi.xFile
        );
      }
    }

    // 2. Batch check backend processed status
    List<String> unprocessedHashes = [];
    try {
      final allHashes = photoInfoList.map((pi) => pi.md5Hash).toList();
      unprocessedHashes = await MemexRouter().checkProcessedHashes(allHashes);
    } catch (e) {
      _logger
          .warning('Batch hash check failed, treating all as unprocessed: $e');
      unprocessedHashes = photoInfoList.map((pi) => pi.md5Hash).toList();
    }

    final unprocessedSet = unprocessedHashes.toSet();
    final List<
            ({
              AssetEntity asset,
              String rawHashStr,
              String md5Hash,
              XFile xFile
            })> unprocessedInfoList =
        photoInfoList
            .where((pi) => unprocessedSet.contains(pi.md5Hash))
            .toList();

    _logger.info(
        '${unprocessedInfoList.length}/${photoInfoList.length} photo(s) unprocessed');

    if (unprocessedInfoList.isEmpty) {
      return [];
    }

    final List<EnhancedPhoto> enhancedPhotos = [];

    // Use cache hits; only miss items request latlng/title concurrently
    final List<Map<String, dynamic>> processedData =
        List.generate(unprocessedInfoList.length, (_) => {});
    final List<Future<void>> prefetchFutures = [];

    for (int i = 0; i < unprocessedInfoList.length; i++) {
      final info = unprocessedInfoList[i];
      final rawHashStr = info.rawHashStr;

      final rawData = cacheData[rawHashStr];
      final cachedEntry = rawData is Map<String, dynamic> ? rawData : null;
      // Check cache has all required fields (avoid stale cache shape)
      final bool isCompleteHit = cachedEntry != null &&
          cachedEntry.containsKey('ocrBlocks') &&
          cachedEntry.containsKey('labels') &&
          cachedEntry.containsKey('md5Hash') &&
          cachedEntry.containsKey('effectiveName') &&
          cachedEntry.containsKey('lat') &&
          cachedEntry.containsKey('lng') &&
          cachedEntry.containsKey('fileModifiedTime');

      if (isCompleteHit) {
        // Cache hit: use cached entry
        processedData[i] = {
          'isHit': true,
          'cachedData': cachedEntry,
          'info': info,
        };
      } else {
        // Miss or incomplete: enqueue for native (latlng/title) fetch
        processedData[i] = {
          'isHit': false,
          'info': info,
        };
        prefetchFutures.add(() async {
          final latlng = await info.asset.latlngAsync();
          final String? trueTitle = await info.asset.titleAsync;
          final String effectiveName = trueTitle ?? info.xFile.name;

          processedData[i]['latlng'] = latlng;
          processedData[i]['effectiveName'] = effectiveName;
        }());
      }
    }

    // Wait for all miss prefetches to complete
    if (prefetchFutures.isNotEmpty) {
      await Future.wait(prefetchFutures);
    }

    for (final data in processedData) {
      final isHit = data['isHit'] as bool;
      final info = data['info'];
      final asset = info.asset;
      final xFile = info.xFile;
      final rawHashStr = info.rawHashStr;
      final md5Hash = info.md5Hash;

      String effectiveName;
      double? lat;
      double? lng;
      List<String> ocrBlocks;
      List<String> labels;
      DateTime fileModifiedTime;

      if (isHit) {
        final cachedData = data['cachedData'] as Map<String, dynamic>;
        effectiveName = cachedData['effectiveName'] as String? ?? xFile.name;
        lat = cachedData['lat'] as double?;
        lng = cachedData['lng'] as double?;
        ocrBlocks = List<String>.from(cachedData['ocrBlocks'] ?? []);
        labels = List<String>.from(cachedData['labels'] ?? []);
        fileModifiedTime = DateTime.fromMillisecondsSinceEpoch(
            cachedData['fileModifiedTime'] as int);
      } else {
        effectiveName = data['effectiveName'] as String;
        final latlng = data['latlng'];
        lat = latlng?.latitude;
        lng = latlng?.longitude;

        _logger.fine('Cache miss: $effectiveName');
        final ocrResult = await _processImageOCR(xFile);
        ocrBlocks = ocrResult.ocrBlocks;
        labels = ocrResult.labels;
        fileModifiedTime = ocrResult.modifiedTime;

        // Update cache
        cacheData[rawHashStr] = {
          'effectiveName': effectiveName,
          'lat': lat,
          'lng': lng,
          'ocrBlocks': ocrBlocks,
          'labels': labels,
          'fileModifiedTime': fileModifiedTime.millisecondsSinceEpoch,
          'md5Hash': md5Hash, // save md5 for fast check next time
          'timestamp':
              DateTime.now().millisecondsSinceEpoch, // For LRU/FIFO if needed
        };
        cacheChanged = true;

        // Limit cache size to maxCount items (FIFO)
        if (cacheData.length > maxCount) {
          final photoKeys = cacheData.keys.toList();
          photoKeys.sort((a, b) {
            final valA = cacheData[a] as Map<String, dynamic>;
            final valB = cacheData[b] as Map<String, dynamic>;
            return (valA['timestamp'] ?? 0).compareTo(valB['timestamp'] ?? 0);
          });

          while (cacheData.length > maxCount) {
            cacheData.remove(photoKeys.removeAt(0));
          }
        }
      }

      final effectiveNameLower = effectiveName.toLowerCase();
      final effectiveNameUpper = effectiveName.toUpperCase();

      final isScreenshot = effectiveNameLower.contains('screenshot') ||
          (effectiveNameUpper.startsWith('IMG_') &&
              effectiveNameUpper.endsWith('.PNG'));

      String? appId;
      if (isScreenshot) {
        final RegExp appRegex = RegExp(r'Screenshot_.*_([a-zA-Z0-9_.]+)\.');
        final match = appRegex.firstMatch(effectiveName);
        if (match != null) {
          appId = match.group(1);
        }
      }

      enhancedPhotos.add(EnhancedPhoto(
        entity: asset,
        xFile: xFile,
        time: fileModifiedTime,
        lat: lat,
        lng: lng,
        ocrBlocks: ocrBlocks,
        ngramFrequency: TextSimilarity.getNgramFrequency(ocrBlocks),
        labels: labels,
        isScreenshot: isScreenshot,
        appId: appId,
      ));
    }

    // Save cache if modified
    if (cacheChanged) {
      cache['__version__'] = _cacheVersion;
      await UserStorage.savePhotoSuggestionCache(cache);
    }

    final clustering = GlobalPhotoClustering();
    final clusters = clustering.performGlobalClustering(enhancedPhotos);
    _logger.info(
        'Clustered ${enhancedPhotos.length} photos → ${clusters.length} cluster(s)');
    return clusters;
  }

  static Future<
      ({
        List<String> ocrBlocks,
        List<String> labels,
        DateTime modifiedTime
      })> _processImageOCR(XFile xFile) async {
    _logger.info('--- Starting OCR + Labeling for ${xFile.name} ---');
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.chinese);
    final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    try {
      final file = File(xFile.path);
      final stat = await file.stat();
      _logger.fine('Processing ${xFile.name}, modified: ${stat.modified}');

      final inputImage = InputImage.fromFilePath(xFile.path);

      // Run both in parallel
      final results = await Future.wait([
        textRecognizer.processImage(inputImage),
        imageLabeler.processImage(inputImage),
      ]);

      final recognizedText = results[0] as RecognizedText;
      final labels = results[1] as List<ImageLabel>;
      final List<String> labelNames = labels.map((l) => l.label).toList();
      final List<String> blockTexts =
          recognizedText.blocks.map((b) => b.text).toList();

      return (
        ocrBlocks: blockTexts,
        labels: labelNames,
        modifiedTime: stat.modified
      );
    } catch (e) {
      _logger.warning('OCR/Labeling failed for image ${xFile.name}: $e');
      return (
        ocrBlocks: <String>[],
        labels: <String>[],
        modifiedTime: DateTime.now()
      );
    } finally {
      textRecognizer.close();
      imageLabeler.close();
    }
  }
}

/// Enhanced photo (with labels, OCR, ngram, etc.)
class EnhancedPhoto {
  final AssetEntity entity;
  final XFile xFile;
  final List<String> labels; // Image labeling result
  final List<String> ocrBlocks; // OCR block-level text list
  final Map<String, int> ngramFrequency; // precomputed ngram frequency
  final bool isScreenshot; // whether screenshot
  final String? appId; // source app ID
  final DateTime time;
  final double? lat;
  final double? lng;

  EnhancedPhoto({
    required this.entity,
    required this.xFile,
    required this.time,
    this.lat,
    this.lng,
    this.labels = const [],
    this.ocrBlocks = const [],
    this.ngramFrequency = const {},
    this.isScreenshot = false,
    this.appId,
  });
}

/// Text similarity (cosine similarity on ngram frequency vectors)
class TextSimilarity {
  static double calculate(Map<String, int> freq1, Map<String, int> freq2) {
    if (freq1.isEmpty || freq2.isEmpty) return 0.0;

    final allTerms = {...freq1.keys, ...freq2.keys};
    double dotProduct = 0;
    double mag1 = 0;
    double mag2 = 0;

    for (var term in allTerms) {
      final v1 = freq1[term] ?? 0;
      final v2 = freq2[term] ?? 0;
      dotProduct += v1 * v2;
      mag1 += v1 * v1;
      mag2 += v2 * v2;
    }

    if (mag1 == 0 || mag2 == 0) return 0.0;
    return dotProduct / (sqrt(mag1) * sqrt(mag2));
  }

  static Map<String, int> getNgramFrequency(List<String> blocks) {
    if (blocks.isEmpty) return const {};
    final Map<String, int> freq = {};

    // tokenize: CJK, letters, digits; filter spaces/symbols
    final tokenRegExp = RegExp(r'([\u4e00-\u9fa5]+|[a-z]+|[0-9]+)');

    for (final block in blocks) {
      final text = block.toLowerCase();
      final matches = tokenRegExp.allMatches(text);
      for (final match in matches) {
        final token = match.group(0)!;
        freq[token] = (freq[token] ?? 0) + 1;
      }
    }
    return freq;
  }
}

class GlobalPhotoClustering {
  // Cluster stop threshold. Smaller distance = more similar. Distance = 1.0 - similarity.
  static const double baseMaxLinkageDistance = 0.5;
  static const int maxClusterSize = 5;
  static const double thresholdReductionStep = 0.05;
  static const double minAllowableThreshold = 0.1;

  final Map<String, double> _distanceCache = {};

  String _getCacheKey(EnhancedPhoto a, EnhancedPhoto b) {
    final id1 = a.entity.id;
    final id2 = b.entity.id;
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }

  double _getOrComputePhotoDistance(EnhancedPhoto a, EnhancedPhoto b) {
    if (identical(a, b)) return 0.0;
    final key = _getCacheKey(a, b);
    if (_distanceCache.containsKey(key)) {
      return _distanceCache[key]!;
    }
    final dist = _calculatePhotoDistance(a, b);
    _distanceCache[key] = dist;
    return dist;
  }

  List<List<EnhancedPhoto>> performGlobalClustering(
      List<EnhancedPhoto> photos) {
    if (photos.isEmpty) return [];

    // Phase 1: global clustering with base threshold
    List<List<EnhancedPhoto>> initialClusters =
        _runClusteringPass(photos, baseMaxLinkageDistance);

    // Phase 2: split oversized clusters recursively
    List<List<EnhancedPhoto>> finalClusters = [];
    for (var cluster in initialClusters) {
      if (cluster.length <= maxClusterSize) {
        finalClusters.add(cluster);
      } else {
        finalClusters
            .addAll(_reclusterOversizedGroup(cluster, baseMaxLinkageDistance));
      }
    }

    // Final sort: by last photo time in each cluster, newest first
    finalClusters.sort((a, b) => b.last.time.compareTo(a.last.time));
    return finalClusters;
  }

  /// Single-pass clustering implementation
  List<List<EnhancedPhoto>> _runClusteringPass(
      List<EnhancedPhoto> subset, double threshold) {
    List<List<EnhancedPhoto>> clusters = subset.map((p) => [p]).toList();

    while (clusters.length > 1) {
      double minDistance = double.infinity;
      int clusterIndexA = -1;
      int clusterIndexB = -1;

      // 1. Find two closest (most similar) clusters
      for (int i = 0; i < clusters.length; i++) {
        for (int j = i + 1; j < clusters.length; j++) {
          double dist = _calculateClusterDistance(clusters[i], clusters[j]);

          if (dist < minDistance) {
            minDistance = dist;
            clusterIndexA = i;
            clusterIndexB = j;
          }
        }
      }

      // 2. If min distance exceeds threshold, stop merging
      if (minDistance > threshold) {
        break;
      }

      // 3. merge
      List<EnhancedPhoto> merged = [
        ...clusters[clusterIndexA],
        ...clusters[clusterIndexB]
      ];
      merged.sort((a, b) => a.time.compareTo(b.time));

      // updatelist
      clusters.removeAt(max(clusterIndexA, clusterIndexB));
      clusters.removeAt(min(clusterIndexA, clusterIndexB));
      clusters.add(merged);
    }

    return clusters;
  }

  /// Recursively split oversized clusters by lowering similarity threshold
  List<List<EnhancedPhoto>> _reclusterOversizedGroup(
      List<EnhancedPhoto> group, double currentThreshold) {
    if (group.length <= maxClusterSize) {
      return [group];
    }

    double newThreshold = currentThreshold - thresholdReductionStep;

    // If threshold at minimum still cannot split (e.g. very similar screenshots), force split
    if (newThreshold < minAllowableThreshold) {
      return _forceSplitGroup(group);
    }

    // Recluster with stricter threshold
    List<List<EnhancedPhoto>> refinedClusters =
        _runClusteringPass(group, newThreshold);

    List<List<EnhancedPhoto>> results = [];
    for (var subCluster in refinedClusters) {
      if (subCluster.length <= maxClusterSize) {
        results.add(subCluster);
      } else {
        // Child cluster still too large, recurse
        results.addAll(_reclusterOversizedGroup(subCluster, newThreshold));
      }
    }
    return results;
  }

  /// Force split oversized very-similar group (by time chunks)
  List<List<EnhancedPhoto>> _forceSplitGroup(List<EnhancedPhoto> group) {
    List<List<EnhancedPhoto>> chunks = [];
    // Ensure time order
    group.sort((a, b) => a.time.compareTo(b.time));

    for (int i = 0; i < group.length; i += maxClusterSize) {
      int end = min(i + maxClusterSize, group.length);
      chunks.add(group.sublist(i, end));
    }
    return chunks;
  }

  /// Distance between two clusters (Average Linkage; avoids chain amplification)
  double _calculateClusterDistance(
      List<EnhancedPhoto> cluster1, List<EnhancedPhoto> cluster2) {
    // Average pairwise distance between clusters
    double sumDist = 0.0;
    int count = 0;
    for (var photo1 in cluster1) {
      for (var photo2 in cluster2) {
        sumDist += _getOrComputePhotoDistance(photo1, photo2);
        count++;
      }
    }
    return sumDist / count;
  }

  /// Score: similarity as distance (dynamic weights and soft penalty)
  double _calculatePhotoDistance(EnhancedPhoto a, EnhancedPhoto b) {
    int timeDiffMin = b.time.difference(a.time).inMinutes.abs();
    // if (timeDiffMin >= 240) return 1.0;

    double tScore = _timeScore(timeDiffMin);
    double gScore = _geoScore(a, b);
    double labelScore = _labelScore(a.labels, b.labels);
    double ocrScore =
        TextSimilarity.calculate(a.ngramFrequency, b.ngramFrequency);

    // 1. Dynamic weights by context
    double wTime = timeDiffMin <= 15 ? 0.6 : 0.4; // within 15 min dominates
    double wGeo = (a.lat != null && b.lat != null) ? 0.3 : 0.1;
    double wOcr =
        (a.ocrBlocks.isNotEmpty || b.ocrBlocks.isNotEmpty) ? 0.3 : 0.0;
    double wLabel = 0.2;

    double accumulatedScore = (tScore * wTime) +
        (gScore * wGeo) +
        (labelScore * wLabel) +
        (ocrScore * wOcr);

    double totalWeight = wTime + wGeo + wLabel + wOcr;
    double baseSimilarity = accumulatedScore / totalWeight;

    // 2. Soft penalty/reward by source (screenshot vs photo, same app vs different)
    double penalty = 0.0;
    if (a.isScreenshot != b.isScreenshot) {
      penalty += 0.15; // mix of photo and screenshot: light penalty
    } else if (a.isScreenshot && b.isScreenshot) {
      if (a.appId != null && b.appId != null) {
        if (a.appId == b.appId) {
          penalty -= 0.15; // same app screenshot: reward
        } else {
          penalty += 0.10; // different app: light penalty
        }
      }
    }

    // 3. Strong semantic: high OCR overlap can override time/place
    if (ocrScore >= 0.5) {
      penalty -= 0.20;
    }

    double similarity = (baseSimilarity - penalty).clamp(0.0, 1.0);
    return 1.0 - similarity;
  }

  // Non-linear time decay

  double _timeScore(int diffMin) {
    if (diffMin <= 5) return 1.0; // within 5 min likely same event
    if (diffMin <= 30) return 0.8 + 0.2 * (30 - diffMin) / 25;
    if (diffMin <= 120) return 0.2 + 0.6 * (120 - diffMin) / 90;
    if (diffMin <= 240) return 0.2 * (240 - diffMin) / 120;
    return 0.0;
  }

  double _geoScore(EnhancedPhoto a, EnhancedPhoto b) {
    if (a.lat == null || b.lat == null) return 0.5; // no GPS: neutral score
    double d = _getHaversineDist(a.lat!, a.lng!, b.lat!, b.lng!);
    if (d <= 100) return 1.0; // same building/location
    if (d <= 1000) return 0.8 - 0.2 * (d - 100) / 900;
    if (d <= 5000) return 0.6 - 0.4 * (d - 1000) / 4000;
    return max(0.0, 0.2 - (d - 5000) / 15000);
  }

  double _labelScore(List<String> l1, List<String> l2) {
    if (l1.isEmpty || l2.isEmpty) return 0.0;
    final s1 = l1.toSet();
    final s2 = l2.toSet();
    if (s1.union(s2).isEmpty) return 0.0;
    return s1.intersection(s2).length / s1.union(s2).length;
  }

  double _getHaversineDist(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    double p = pi / 180.0;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2.0 +
        cos(lat1 * p) * cos(lat2 * p) * (1.0 - cos((lon2 - lon1) * p)) / 2.0;
    return 2.0 * r * asin(sqrt(a));
  }
}
