import 'package:flutter_test/flutter_test.dart';
import 'package:memex/agent/agent_utils.dart';

void main() {
  test('formatAssetAnalysis includes photo capture location context', () {
    final formatted = formatAssetAnalysis(
      [
        {
          'index': 0,
          'name': 'photo.heic',
          'analysis': 'A child sits near a CETC Dongxin entrance.',
          'exif_data': {
            'datetime_original': '2026-06-07T10:56:39.000',
            'address': 'Hangzhou - Liuxia Street',
            'user_marked_location': 'Dongxin Chorus Garden',
            'gps_coordinates': [30.228316, 120.04158],
          },
        },
      ],
      includeExif: true,
    );

    expect(formatted, contains('Photo Capture Time: 2026-06-07T10:56:39.000'));
    expect(
      formatted,
      contains('Photo Capture Location: Hangzhou - Liuxia Street'),
    );
    expect(
      formatted,
      contains(
        'Nearby User-Marked Location: Dongxin Chorus Garden (within 50 meters)',
      ),
    );
    expect(formatted, contains('GPS Coordinates: Latitude 30.228316'));
  });

  test('formatAssetAnalysis omits exif details when includeExif is false', () {
    final formatted = formatAssetAnalysis(
      [
        {
          'index': 0,
          'name': 'photo.heic',
          'analysis': 'A child sits near a CETC Dongxin entrance.',
          'exif_data': {
            'address': 'Hangzhou - Liuxia Street',
            'gps_coordinates': [30.228316, 120.04158],
          },
        },
      ],
    );

    expect(formatted, isNot(contains('Photo Capture Location')));
    expect(formatted, isNot(contains('GPS Coordinates')));
  });
}
