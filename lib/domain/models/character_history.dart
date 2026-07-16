class CharacterHistoryMoment {
  const CharacterHistoryMoment({
    required this.factId,
    required this.timestamp,
    required this.content,
    this.title,
    this.tags = const [],
    this.address,
  });

  final String factId;
  final DateTime timestamp;
  final String content;
  final String? title;
  final List<String> tags;
  final String? address;

  Map<String, dynamic> toAgentJson({bool includeFullContent = false}) => {
        'fact_id': factId,
        'timestamp': timestamp.toIso8601String(),
        if (title?.trim().isNotEmpty == true) 'title': title!.trim(),
        'content': includeFullContent ? content : _excerpt(content),
        if (tags.isNotEmpty) 'tags': tags,
        if (address?.trim().isNotEmpty == true) 'address': address!.trim(),
      };

  static String _excerpt(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 180) return normalized;
    return '${normalized.substring(0, 180)}...';
  }
}

class CharacterHistoryPage {
  const CharacterHistoryPage({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.moments,
  });

  final int page;
  final int pageSize;
  final int total;
  final List<CharacterHistoryMoment> moments;

  bool get hasMore => page * pageSize < total;

  Map<String, dynamic> toAgentJson() => {
        'page': page,
        'page_size': pageSize,
        'total': total,
        'has_more': hasMore,
        'moments': moments.map((moment) => moment.toAgentJson()).toList(),
      };
}
