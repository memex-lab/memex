class TemplateGallerySection {
  const TemplateGallerySection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<TemplateGalleryItem> items;
}

class TemplateGalleryItem {
  const TemplateGalleryItem({
    required this.label,
    required this.templateId,
    required this.data,
    this.title = '',
    this.wrapped = false,
  });

  final String label;
  final String templateId;
  final Map<String, dynamic> data;
  final String title;
  final bool wrapped;
}

typedef InsightPreviewSample = ({String template, Map<String, dynamic> data});
