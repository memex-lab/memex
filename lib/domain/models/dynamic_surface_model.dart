/// Experimental manifest for AI-authored dynamic UI surfaces.
///
/// A dynamic surface keeps the UI free-form while keeping Markdown data
/// deterministic through a page-owned parser script. Agents can author
/// HTML/CSS/JS, Markdown, and parser.js; the host runs the parser in a
/// constrained JavaScript runtime and injects its JSON result into the page.
class DynamicSurfaceModel {
  final String id;
  final String title;
  final String? description;
  final DynamicSurfaceSource source;
  final DynamicSurfaceParserSpec parser;
  final DynamicSurfaceRenderSpec render;

  const DynamicSurfaceModel({
    required this.id,
    required this.title,
    this.description,
    required this.source,
    required this.parser,
    required this.render,
  });

  factory DynamicSurfaceModel.fromJson(Map<String, dynamic> json) {
    return DynamicSurfaceModel(
      id: _string(json['id']),
      title: _string(json['title']),
      description: json['description']?.toString(),
      source: DynamicSurfaceSource.fromJson(
        _map(json['source']),
      ),
      parser: DynamicSurfaceParserSpec.fromJson(
        _map(json['parser']),
      ),
      render: DynamicSurfaceRenderSpec.fromJson(
        _map(json['render']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        'source': source.toJson(),
        'parser': parser.toJson(),
        'render': render.toJson(),
      };
}

class DynamicSurfaceSource {
  final String type;
  final String path;
  final bool recursive;

  const DynamicSurfaceSource({
    required this.type,
    required this.path,
    this.recursive = true,
  });

  bool get isDirectory => type == 'directory';
  bool get isFile => type == 'file';

  factory DynamicSurfaceSource.fromJson(Map<String, dynamic> json) {
    final type = _string(json['type'], fallback: 'file');
    if (type != 'file' && type != 'directory') {
      throw ArgumentError('Unsupported dynamic surface source type: $type');
    }
    return DynamicSurfaceSource(
      type: type,
      path: _string(json['path']),
      recursive: json['recursive'] is bool ? json['recursive'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'path': path,
        if (isDirectory) 'recursive': recursive,
      };
}

class DynamicSurfaceParserSpec {
  final String type;
  final String scriptPath;
  final String entry;

  const DynamicSurfaceParserSpec({
    this.type = 'javascript',
    required this.scriptPath,
    this.entry = 'parse',
  });

  factory DynamicSurfaceParserSpec.fromJson(Map<String, dynamic> json) {
    final type = _string(json['type'], fallback: 'javascript');
    if (type != 'javascript') {
      throw ArgumentError('Unsupported dynamic surface parser type: $type');
    }
    return DynamicSurfaceParserSpec(
      type: type,
      scriptPath: _string(json['script_path'], fallback: 'parser.js'),
      entry: _string(json['entry'], fallback: 'parse'),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'script_path': scriptPath,
        'entry': entry,
      };
}

class DynamicSurfaceRenderSpec {
  final String type;
  final String templatePath;

  const DynamicSurfaceRenderSpec({
    required this.type,
    required this.templatePath,
  });

  factory DynamicSurfaceRenderSpec.fromJson(Map<String, dynamic> json) {
    final type = _string(json['type'], fallback: 'html');
    if (type != 'html' && type != 'markdown') {
      throw ArgumentError('Unsupported dynamic surface render type: $type');
    }
    return DynamicSurfaceRenderSpec(
      type: type,
      templatePath: _string(json['template_path']),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'template_path': templatePath,
      };
}

class DynamicSurfaceRenderResult {
  final DynamicSurfaceModel surface;
  final Object? data;
  final String content;
  final String contentType;

  const DynamicSurfaceRenderResult({
    required this.surface,
    required this.data,
    required this.content,
    required this.contentType,
  });
}

String _string(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
