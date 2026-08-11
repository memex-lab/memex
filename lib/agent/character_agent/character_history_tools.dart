// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:dart_agent_core/dart_agent_core.dart';
import 'package:memex/data/services/character_history_acquaintance_service.dart';

class CharacterHistoryTools {
  CharacterHistoryTools({
    required this.userId,
    CharacterHistoryAcquaintanceService? historyService,
  }) : _historyService =
            historyService ?? CharacterHistoryAcquaintanceService.instance;

  final String userId;
  final CharacterHistoryAcquaintanceService _historyService;
  bool hasBrowsed = false;

  List<Tool> build() => [
        _buildBrowseHistoryTool(),
        _buildSearchHistoryTool(),
        _buildReadHistoryMomentTool(),
      ];

  Tool _buildBrowseHistoryTool() {
    return Tool(
      name: 'BrowseHistory',
      description: 'Browse one page of the user\'s past timeline moments, '
          'newest first. Use different pages to notice different periods.',
      parameters: const {
        'type': 'object',
        'properties': {
          'page': {
            'type': 'integer',
            'minimum': 1,
            'description': 'One-based page number.',
          },
          'page_size': {
            'type': 'integer',
            'minimum': 1,
            'maximum': 30,
            'description': 'Moments per page. Usually 12 to 20.',
          },
        },
        'required': ['page', 'page_size'],
      },
      executable: (int page, int page_size) async {
        hasBrowsed = true;
        final result = await _historyService.browseMoments(
          userId: userId,
          page: page,
          pageSize: page_size,
        );
        return const JsonEncoder.withIndent('  ').convert(result.toAgentJson());
      },
    );
  }

  Tool _buildSearchHistoryTool() {
    return Tool(
      name: 'SearchHistory',
      description: 'Search the user\'s timeline for a person, place, topic, '
          'habit, or phrase that genuinely interests you.',
      parameters: const {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'A concrete search phrase.',
          },
          'limit': {
            'type': 'integer',
            'minimum': 1,
            'maximum': 30,
          },
        },
        'required': ['query', 'limit'],
      },
      executable: (String query, int limit) async {
        hasBrowsed = true;
        final results = await _historyService.searchMoments(
          userId: userId,
          query: query,
          limit: limit,
        );
        return const JsonEncoder.withIndent('  ').convert(
          results.map((moment) => moment.toAgentJson()).toList(),
        );
      },
    );
  }

  Tool _buildReadHistoryMomentTool() {
    return Tool(
      name: 'ReadHistoryMoment',
      description: 'Open one timeline moment when its full wording matters '
          'to your understanding. Do not open everything mechanically.',
      parameters: const {
        'type': 'object',
        'properties': {
          'fact_id': {
            'type': 'string',
            'description': 'The exact fact_id returned by a history tool.',
          },
        },
        'required': ['fact_id'],
      },
      executable: (String fact_id) async {
        hasBrowsed = true;
        final moment = await _historyService.readMoment(
          userId: userId,
          factId: fact_id,
        );
        if (moment == null) return 'Moment not found.';
        return const JsonEncoder.withIndent('  ').convert(
          moment.toAgentJson(includeFullContent: true),
        );
      },
    );
  }
}
