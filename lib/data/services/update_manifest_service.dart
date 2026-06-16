import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:memex/domain/models/update_manifest.dart';
import 'package:memex/utils/logger.dart';

class UpdateManifestEndpoint {
  const UpdateManifestEndpoint({required this.manifestUrl, this.sha256Url});

  final String manifestUrl;
  final String? sha256Url;
}

class UpdateManifestLoadResult {
  const UpdateManifestLoadResult({
    required this.manifest,
    required this.sourceUrl,
    required this.loadedAt,
    this.error,
    this.usedFallback = false,
    this.usedBuiltInFallback = false,
  });

  final UpdateManifest manifest;
  final String sourceUrl;
  final DateTime loadedAt;
  final Object? error;
  final bool usedFallback;
  final bool usedBuiltInFallback;

  bool get hasError => error != null;
}

typedef UpdateManifestClock = DateTime Function();

class UpdateManifestService {
  UpdateManifestService({
    http.Client? httpClient,
    List<UpdateManifestEndpoint>? endpoints,
    UpdateManifestClock? clock,
    this.verifyManifestSha256 = true,
    this.requestTimeout = const Duration(seconds: 5),
  })  : _httpClient = httpClient ?? http.Client(),
        _endpoints = endpoints ?? defaultEndpoints,
        _clock = clock ?? DateTime.now;

  static final UpdateManifestService instance = UpdateManifestService();

  static const primaryManifestUrl =
      'https://www.memexlab.ai/updates/v1/manifest.json';
  static const primaryManifestSha256Url =
      'https://www.memexlab.ai/updates/v1/manifest.sha256';
  static const fallbackManifestUrl =
      'https://github.com/memex-lab/memex/releases/latest/download/manifest.json';
  static const fallbackManifestSha256Url =
      'https://github.com/memex-lab/memex/releases/latest/download/manifest.sha256';

  static const defaultEndpoints = [
    UpdateManifestEndpoint(
      manifestUrl: primaryManifestUrl,
      sha256Url: primaryManifestSha256Url,
    ),
    UpdateManifestEndpoint(
      manifestUrl: fallbackManifestUrl,
      sha256Url: fallbackManifestSha256Url,
    ),
  ];

  final http.Client _httpClient;
  final List<UpdateManifestEndpoint> _endpoints;
  final UpdateManifestClock _clock;
  final bool verifyManifestSha256;
  final Duration requestTimeout;
  final _logger = getLogger('UpdateManifestService');

  Future<UpdateManifestLoadResult> loadManifest() async {
    Object? firstError;
    for (var i = 0; i < _endpoints.length; i += 1) {
      final endpoint = _endpoints[i];
      try {
        final manifest = await _fetchManifest(endpoint);
        return UpdateManifestLoadResult(
          manifest: manifest,
          sourceUrl: endpoint.manifestUrl,
          loadedAt: _clock(),
          usedFallback: i > 0,
        );
      } catch (e, st) {
        firstError ??= e;
        _logger.warning(
          'Failed to load update manifest from ${endpoint.manifestUrl}',
          e,
          st,
        );
      }
    }

    return UpdateManifestLoadResult(
      manifest: UpdateManifest.empty(),
      sourceUrl: 'built-in:no-op',
      loadedAt: _clock(),
      error: firstError,
      usedFallback: true,
      usedBuiltInFallback: true,
    );
  }

  Future<UpdateManifest> _fetchManifest(UpdateManifestEndpoint endpoint) async {
    final manifestUri = Uri.parse(endpoint.manifestUrl);
    final response = await _httpClient
        .get(manifestUri, headers: _headers)
        .timeout(requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Manifest request failed: HTTP ${response.statusCode}',
        uri: manifestUri,
      );
    }

    final body = response.body;
    if (verifyManifestSha256 && endpoint.sha256Url != null) {
      await _verifyManifestSha256(body, endpoint.sha256Url!);
    }

    return UpdateManifest.fromJsonString(body);
  }

  Future<void> _verifyManifestSha256(String body, String sha256Url) async {
    final uri = Uri.parse(sha256Url);
    final response =
        await _httpClient.get(uri, headers: _headers).timeout(requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _logger.info(
        'Skipping optional manifest sha256 check: HTTP '
        '${response.statusCode} for $sha256Url',
      );
      return;
    }

    final expected = _extractSha256(response.body);
    if (expected == null) {
      _logger.info(
        'Skipping optional manifest sha256 check: invalid hash file',
      );
      return;
    }

    final actual = sha256.convert(utf8.encode(body)).toString();
    if (actual != expected) {
      throw const FormatException('Manifest sha256 mismatch');
    }
  }

  String? _extractSha256(String value) {
    final match = RegExp(r'\b[a-fA-F0-9]{64}\b').firstMatch(value);
    return match?.group(0)?.toLowerCase();
  }

  static const _headers = {
    'Accept': 'application/json',
    'User-Agent': 'Memex-Updater',
  };
}
