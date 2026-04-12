import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Builds a DiceBear Notionists avatar URL from a seed string.
String dicebearUrl(String seed) {
  final encoded = Uri.encodeComponent(seed);
  return 'https://api.dicebear.com/7.x/notionists/svg?seed=$encoded';
}

/// Downloads and caches the avatar SVG for a given seed.
/// Returns the local file path, or null on failure.
Future<String?> cacheAvatarSvg(String seed) async {
  try {
    final url = dicebearUrl(seed);
    final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 10),
        );
    if (response.statusCode == 200) {
      final file = await _cacheFile(seed);
      await file.writeAsString(response.body);
      return file.path;
    }
  } catch (_) {}
  return null;
}

Future<File> _cacheFile(String seed) async {
  final dir = await getApplicationSupportDirectory();
  final hash = md5.convert(utf8.encode(seed)).toString();
  return File('${dir.path}/avatar_$hash.svg');
}

/// Displays a DiceBear Notionists avatar as a circle.
///
/// [seed] is used to generate the avatar. If null, shows a placeholder icon.
/// Loads from local cache first, falls back to network.
class DiceBearAvatar extends StatelessWidget {
  const DiceBearAvatar({
    super.key,
    required this.seed,
    this.size = 48,
    this.backgroundColor,
  });

  final String? seed;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (seed == null || seed!.isEmpty) {
      return _placeholder();
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: backgroundColor ?? const Color(0xFFEEF2FF),
        child: FutureBuilder<File>(
          future: _cacheFile(seed!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.existsSync()) {
              try {
                return SvgPicture.file(
                  snapshot.data!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                );
              } catch (_) {
                return _placeholder();
              }
            }
            // Fallback to network with error handling
            return SvgPicture.network(
              dicebearUrl(seed!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => _loadingIndicator(),
              errorBuilder: (_, __, ___) => _placeholder(),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFEEF2FF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: const Color(0xFF5B6CFF),
      ),
    );
  }

  Widget _loadingIndicator() {
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? const Color(0xFFEEF2FF),
      child: Center(
        child: SizedBox(
          width: size * 0.3,
          height: size * 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF5B6CFF),
          ),
        ),
      ),
    );
  }
}
