import 'package:flutter_test/flutter_test.dart';
import 'package:memex/ui/core/widgets/local_image.dart';

void main() {
  test('localImageDecodePixels scales by device pixel ratio', () {
    expect(localImageDecodePixels(120, 2), 240);
    expect(localImageDecodePixels(120, 3), 360);
  });

  test('localImageDecodePixels ignores empty or infinite sizes', () {
    expect(localImageDecodePixels(null, 2), isNull);
    expect(localImageDecodePixels(0, 2), isNull);
    expect(localImageDecodePixels(double.infinity, 2), isNull);
  });

  test('localImageDecodePixels clamps huge bitmaps', () {
    expect(localImageDecodePixels(8000, 3), 4096);
  });
}
