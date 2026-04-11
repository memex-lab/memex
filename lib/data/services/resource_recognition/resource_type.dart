/// Supported resource types that can be recognized from user input.
enum ResourceType {
  url,       // Web links (http/https)
  pdf,       // PDF documents
  doc,       // Word documents (.doc, .docx)
  bookmark,  // Browser bookmarks / saved links
  file,      // Generic file attachments
}

/// Recognition status — allows async enrichment after initial detection.
enum RecognitionStatus {
  detected,   // Resource detected but metadata not yet fetched
  enriching,  // Metadata fetch in progress
  enriched,   // Metadata successfully fetched
  failed,     // Metadata fetch failed (basic info still available)
}

/// Metadata extracted from a recognized resource.
class ResourceMetadata {
  final ResourceType type;
  final String source;       // Original URL or file path
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? textContent; // Extracted text (for PDF, doc, etc.)
  final RecognitionStatus status;
  final Map<String, dynamic> extra; // Type-specific metadata

  const ResourceMetadata({
    required this.type,
    required this.source,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.textContent,
    this.status = RecognitionStatus.detected,
    this.extra = const {},
  });

  /// Create a copy with updated fields (for async enrichment).
  ResourceMetadata copyWith({
    String? title,
    String? description,
    String? thumbnailUrl,
    String? textContent,
    RecognitionStatus? status,
    Map<String, dynamic>? extra,
  }) {
    return ResourceMetadata(
      type: type,
      source: source,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      textContent: textContent ?? this.textContent,
      status: status ?? this.status,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'source': source,
        'status': status.name,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        if (textContent != null) 'text_content': textContent,
        if (extra.isNotEmpty) 'extra': extra,
      };

  factory ResourceMetadata.fromJson(Map<String, dynamic> json) {
    return ResourceMetadata(
      type: ResourceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ResourceType.file,
      ),
      source: json['source'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      textContent: json['text_content'] as String?,
      status: RecognitionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String?),
        orElse: () => RecognitionStatus.detected,
      ),
      extra: (json['extra'] as Map<String, dynamic>?) ?? {},
    );
  }

  @override
  String toString() => 'ResourceMetadata($type, $source, title=$title, status=$status)';
}
