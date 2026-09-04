import 'template_gallery_models.dart';
import 'template_gallery_ar.dart';
import 'template_gallery_de.dart';
import 'template_gallery_en.dart';
import 'template_gallery_es.dart';
import 'template_gallery_fa.dart';
import 'template_gallery_fr.dart';
import 'template_gallery_hi.dart';
import 'template_gallery_id.dart';
import 'template_gallery_it.dart';
import 'template_gallery_ja.dart';
import 'template_gallery_ko.dart';
import 'template_gallery_pt.dart';
import 'template_gallery_ru.dart';
import 'template_gallery_th.dart';
import 'template_gallery_tr.dart';
import 'template_gallery_vi.dart';
import 'template_gallery_zh.dart';

typedef TemplateGalleryData = ({
  List<TemplateGallerySection> timelineSections,
  List<TemplateGalleryItem> insightItems,
});

TemplateGalleryData lookupTemplateGallery(String localeName) {
  switch (localeName) {
    case 'zh':
    case 'zh_Hant':
      return (
        timelineSections: timelineTemplateGallerySectionsZh,
        insightItems: insightTemplateGalleryItemsZh,
      );
    case 'de':
      return (
        timelineSections: timelineTemplateGallerySectionsDe,
        insightItems: insightTemplateGalleryItemsDe,
      );
    case 'ja':
      return (
        timelineSections: timelineTemplateGallerySectionsJa,
        insightItems: insightTemplateGalleryItemsJa,
      );
    case 'ko':
      return (
        timelineSections: timelineTemplateGallerySectionsKo,
        insightItems: insightTemplateGalleryItemsKo,
      );
    case 'es':
      return (
        timelineSections: timelineTemplateGallerySectionsEs,
        insightItems: insightTemplateGalleryItemsEs,
      );
    case 'hi':
      return (
        timelineSections: timelineTemplateGallerySectionsHi,
        insightItems: insightTemplateGalleryItemsHi,
      );
    case 'ar':
      return (
        timelineSections: timelineTemplateGallerySectionsAr,
        insightItems: insightTemplateGalleryItemsAr,
      );
    case 'pt':
      return (
        timelineSections: timelineTemplateGallerySectionsPt,
        insightItems: insightTemplateGalleryItemsPt,
      );
    case 'fr':
      return (
        timelineSections: timelineTemplateGallerySectionsFr,
        insightItems: insightTemplateGalleryItemsFr,
      );
    case 'id':
      return (
        timelineSections: timelineTemplateGallerySectionsId,
        insightItems: insightTemplateGalleryItemsId,
      );
    case 'it':
      return (
        timelineSections: timelineTemplateGallerySectionsIt,
        insightItems: insightTemplateGalleryItemsIt,
      );
    case 'fa':
      return (
        timelineSections: timelineTemplateGallerySectionsFa,
        insightItems: insightTemplateGalleryItemsFa,
      );
    case 'vi':
      return (
        timelineSections: timelineTemplateGallerySectionsVi,
        insightItems: insightTemplateGalleryItemsVi,
      );
    case 'th':
      return (
        timelineSections: timelineTemplateGallerySectionsTh,
        insightItems: insightTemplateGalleryItemsTh,
      );
    case 'tr':
      return (
        timelineSections: timelineTemplateGallerySectionsTr,
        insightItems: insightTemplateGalleryItemsTr,
      );
    case 'ru':
      return (
        timelineSections: timelineTemplateGallerySectionsRu,
        insightItems: insightTemplateGalleryItemsRu,
      );
    case 'en':
    default:
      return (
        timelineSections: timelineTemplateGallerySectionsEn,
        insightItems: insightTemplateGalleryItemsEn,
      );
  }
}
