import 'package:memex/l10n/template_gallery_l10n.dart';
import 'package:memex/utils/user_storage.dart';

/// Sample insight cards shown as preview when the user has no real insights.
/// These are never persisted — purely for display.
class InsightPreviewData {
  InsightPreviewData._();

  static List<InsightPreviewSample> get samples =>
      UserStorage.l10n.insightPreviewSamples;
}
