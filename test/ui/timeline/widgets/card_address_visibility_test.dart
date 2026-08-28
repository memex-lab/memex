import 'package:test/test.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';

void main() {
  test('hides empty and Unknown placeholder addresses', () {
    expect(shouldShowCardAddress(''), isFalse);
    expect(shouldShowCardAddress('Unknown'), isFalse);
    expect(shouldShowCardAddress('Tokyo'), isTrue);
  });
}
