import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:memex/agent/memory/character_memory_service.dart';
import 'package:memex/data/services/character_service.dart';
import 'package:memex/domain/models/character_model.dart';

class TavernCharacterImportService {
  TavernCharacterImportService._();

  static final TavernCharacterImportService instance =
      TavernCharacterImportService._();

  Future<Map<String, dynamic>> previewFromFile({
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ArgumentError('File not found: $filePath');
    }
    final lower = filePath.toLowerCase();
    Map<String, dynamic> card;
    if (lower.endsWith('.json')) {
      card = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } else if (lower.endsWith('.png')) {
      card = await _extractCardFromPng(await file.readAsBytes());
    } else {
      throw ArgumentError('Unsupported card format: $filePath');
    }
    final mapped = _mapCardToCharacter(card);
    final worldEntries = _extractWorldEntries(card);
    return {
      'name': mapped['name'],
      'tags': mapped['tags'],
      'persona_preview': (mapped['persona'] as String),
      'first_message': mapped['first_message'] ?? '',
      'system_prompt_override': mapped['system_prompt_override'] ?? '',
      'post_history_instructions': mapped['post_history_instructions'] ?? '',
      'mes_example': mapped['mes_example'] ?? '',
      'world_entries_count': worldEntries.length,
    };
  }

  Future<Map<String, dynamic>> detectConflicts({
    required String userId,
    required String filePath,
  }) async {
    final preview = await previewFromFile(filePath: filePath);
    final incomingName = (preview['name'] as String).trim().toLowerCase();
    final existing = await CharacterService.instance.getAllCharacters(userId);
    final sameName = existing
        .where((c) => c.name.trim().toLowerCase() == incomingName)
        .map((c) => {'id': c.id, 'name': c.name})
        .toList();
    return {
      'has_conflict': sameName.isNotEmpty,
      'same_name_characters': sameName,
      'incoming': preview,
    };
  }

  Future<CharacterModel> importFromFile({
    required String userId,
    required String filePath,
    bool setPrimaryCompanion = false,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ArgumentError('File not found: $filePath');
    }
    final lower = filePath.toLowerCase();
    Map<String, dynamic> card;
    if (lower.endsWith('.json')) {
      card = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } else if (lower.endsWith('.png')) {
      card = await _extractCardFromPng(await file.readAsBytes());
    } else {
      throw ArgumentError('Unsupported card format: $filePath');
    }
    final mapped = _mapCardToCharacter(card);

    // If imported from a PNG file, save the PNG as the character's avatar image.
    if (lower.endsWith('.png')) {
      final charsPath = CharacterService.instance.getCharactersPath(userId);
      final charsDir = Directory(charsPath);
      if (!await charsDir.exists()) {
        await charsDir.create(recursive: true);
      }
      final avatarFileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.png';
      final avatarDest = '$charsPath/$avatarFileName';
      await file.copy(avatarDest);
      mapped['avatar'] = avatarDest;
    }

    final created = await CharacterService.instance.createCharacter(
      userId: userId,
      characterData: mapped,
    );
    final worldEntries = _extractWorldEntries(card);
    if (worldEntries.isNotEmpty) {
      await CharacterMemoryService.instance.replaceWorldEntries(
        userId,
        created.id,
        worldEntries,
      );
    }
    if (setPrimaryCompanion) {
      await CharacterService.instance.setPrimaryCompanion(userId, created.id);
    }
    return created;
  }

  Map<String, dynamic> _mapCardToCharacter(Map<String, dynamic> card) {
    final data = _normalizeCardData(card);
    final name = (data['name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      throw ArgumentError('Invalid card: missing name');
    }
    final description = (data['description'] as String?)?.trim() ?? '';
    final personality = (data['personality'] as String?)?.trim() ?? '';
    final scenario = (data['scenario'] as String?)?.trim() ?? '';
    final firstMes = (data['first_mes'] as String?)?.trim() ?? '';
    final mesExample = (data['mes_example'] as String?)?.trim() ?? '';
    final systemPrompt = (data['system_prompt'] as String?)?.trim() ?? '';
    final postHistory =
        (data['post_history_instructions'] as String?)?.trim() ?? '';
    final tags = (data['tags'] as List?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        <String>[];

    // Build persona from description + personality + scenario only.
    // system_prompt, post_history_instructions, first_mes, mes_example
    // are stored as separate fields with proper runtime injection.
    // creator_notes is metadata-only, not sent to model.
    final persona = StringBuffer()
      ..writeln('## Identity')
      ..writeln(description);
    if (personality.isNotEmpty) {
      persona
        ..writeln('')
        ..writeln('## Personality')
        ..writeln(personality);
    }
    if (scenario.isNotEmpty) {
      persona
        ..writeln('')
        ..writeln('## Scenario')
        ..writeln(scenario);
    }

    return {
      'name': name,
      'tags': tags,
      'persona': persona.toString().trim(),
      'enabled': true,
      if (firstMes.isNotEmpty) 'first_message': firstMes,
      if (systemPrompt.isNotEmpty) 'system_prompt_override': systemPrompt,
      if (postHistory.isNotEmpty) 'post_history_instructions': postHistory,
      if (mesExample.isNotEmpty) 'mes_example': mesExample,
    };
  }

  List<Map<String, dynamic>> _extractWorldEntries(Map<String, dynamic> card) {
    final data = _normalizeCardData(card);
    final book = data['character_book'];
    if (book is! Map) return [];
    final entriesRaw = book['entries'];
    if (entriesRaw is! List) return [];
    final entries = <Map<String, dynamic>>[];
    for (var i = 0; i < entriesRaw.length; i++) {
      final raw = entriesRaw[i];
      if (raw is! Map) continue;
      final content = (raw['content'] as String?)?.trim() ?? '';
      if (content.isEmpty) continue;
      final keys = <String>[
        ...((raw['keys'] as List?) ?? const []).map((e) => e.toString()),
        ...((raw['key'] as List?) ?? const []).map((e) => e.toString()),
      ].where((e) => e.trim().isNotEmpty).toSet().toList();
      entries.add({
        'id': 'card_book_$i',
        'keys': keys,
        'content': content,
        'comment': (raw['comment'] as String?) ?? '',
        'constant': raw['constant'] == true,
        'enabled': raw['enabled'] != false && raw['disable'] != true,
        'source': 'tavern_character_book',
      });
    }
    return entries;
  }

  Map<String, dynamic> _normalizeCardData(Map<String, dynamic> input) {
    if (input.containsKey('data') && input['data'] is Map) {
      final data = Map<String, dynamic>.from(input['data'] as Map);
      if (data.isNotEmpty &&
          (data['name'] != null || data['description'] != null)) {
        return data;
      }
    }
    return Map<String, dynamic>.from(input);
  }

  Future<Map<String, dynamic>> _extractCardFromPng(Uint8List bytes) async {
    // PNG signature check.
    const pngSig = <int>[137, 80, 78, 71, 13, 10, 26, 10];
    if (bytes.length < 8 ||
        !List.generate(8, (i) => bytes[i] == pngSig[i]).every((e) => e)) {
      throw ArgumentError('Not a valid PNG file');
    }

    int offset = 8;
    String? jsonText;

    while (offset + 8 <= bytes.length) {
      final length = _readUint32(bytes, offset);
      offset += 4;
      final type = ascii.decode(bytes.sublist(offset, offset + 4));
      offset += 4;
      if (offset + length + 4 > bytes.length) break;
      final chunkData = bytes.sublist(offset, offset + length);
      offset += length;
      offset += 4; // crc

      if (type == 'tEXt') {
        final zero = chunkData.indexOf(0);
        if (zero > 0) {
          final key = latin1.decode(chunkData.sublist(0, zero));
          final value = latin1.decode(chunkData.sublist(zero + 1));
          final parsed = _parseEmbeddedCardValue(key, value);
          if (parsed != null) {
            jsonText = parsed;
            break;
          }
        }
      } else if (type == 'iTXt') {
        final parsed = _parseITXt(chunkData);
        if (parsed != null) {
          jsonText = parsed;
          break;
        }
      } else if (type == 'IEND') {
        break;
      }
    }

    if (jsonText == null) {
      throw ArgumentError('No embedded character card found in PNG');
    }
    final obj = jsonDecode(jsonText);
    if (obj is! Map) {
      throw ArgumentError('Invalid embedded character card JSON');
    }
    return Map<String, dynamic>.from(obj);
  }

  String? _parseEmbeddedCardValue(String key, String value) {
    final lower = key.toLowerCase();
    if (lower.contains('chara')) {
      // Many tavern cards store base64 JSON in key "chara".
      try {
        final decoded = utf8.decode(base64.decode(value.trim()));
        return decoded;
      } catch (_) {
        // Some cards may store plain JSON directly.
        if (value.trim().startsWith('{')) return value;
      }
    }
    if (value.trim().startsWith('{') && value.contains('"name"')) {
      return value;
    }
    return null;
  }

  String? _parseITXt(Uint8List data) {
    // iTXt format: keyword\0 compressionFlag compressionMethod languageTag\0 translatedKeyword\0 text
    final firstZero = data.indexOf(0);
    if (firstZero <= 0) return null;
    final keyword = latin1.decode(data.sublist(0, firstZero));
    if (!keyword.toLowerCase().contains('chara')) return null;
    if (firstZero + 2 >= data.length) return null;
    final compressionFlag = data[firstZero + 1];
    // Skip to language tag end.
    int pos = firstZero + 3;
    while (pos < data.length && data[pos] != 0) {
      pos++;
    }
    pos++; // language tag zero
    while (pos < data.length && data[pos] != 0) {
      pos++;
    }
    pos++; // translated keyword zero
    if (pos >= data.length) return null;
    final textBytes = data.sublist(pos);
    if (compressionFlag != 0) return null; // ignore compressed iTXt for now
    final value = utf8.decode(textBytes, allowMalformed: true);
    return _parseEmbeddedCardValue(keyword, value);
  }

  int _readUint32(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }
}
