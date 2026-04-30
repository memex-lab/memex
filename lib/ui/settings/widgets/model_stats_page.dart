import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/utils/token_usage_utils.dart';

class ModelStatsPage extends StatefulWidget {
  const ModelStatsPage({super.key});

  @override
  State<ModelStatsPage> createState() => _ModelStatsPageState();
}

class _ModelStatsPageState extends State<ModelStatsPage>
    with SingleTickerProviderStateMixin {
  final MemexRouter _memexRouter = MemexRouter();
  bool _isLoading = true;
  // Raw records
  List<Map<String, dynamic>> _records = [];

  // Aggregated data
  Map<String, dynamic> _stats = {};

  DateTimeRange? _dateRange;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Default to last 30 days
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Fetch raw records with date filter
      final records = await _memexRouter.getAgentUsages(
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      );

      // 2. Perform aggregation locally
      final aggregated = _aggregateRecords(records);

      if (mounted) {
        setState(() {
          _records = records;
          _stats = aggregated;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(UserStorage.l10n.loadStatsFailed(e))),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadData();
    }
  }

  // Pricing configuration (per token)
  static const _pricing = {
    'gemini-3-flash-preview': {
      'input': 0.0000005,
      'cached': 0.00000005,
      'output': 0.000003,
    },
    'gemini-2.5-flash': {
      'input': 0.0000003,
      'cached': 0.00000003,
      'output': 0.0000025,
    },
    'gemini-3.1-pro-preview': {
      'input': 0.000002,
      'cached': 0.0000002,
      'output': 0.000012,
    },
    'gemini-3-pro-preview': {
      'input': 0.000002,
      'cached': 0.0000002,
      'output': 0.000012,
    },
    'gpt-4o': {
      'input': 0.0000025,
      'cached': 0.00000125,
      'output': 0.00001,
    },
  };

  Map<String, double> _calculateCost(String model, int prompt, int completion,
      int cached, int thought, bool? cachedTokensIncludedInPrompt) {
    // Find matching model pricing
    Map<String, double>? prices;
    for (final key in _pricing.keys) {
      if (model.toLowerCase().contains(key)) {
        prices = _pricing[key];
        break;
      }
    }

    // Default to gpt-4o if not found
    prices ??= _pricing['gpt-4o'];

    if (prices == null) {
      return {'input': 0.0, 'output': 0.0, 'total': 0.0};
    }

    // Input cost: uncached prompt * input_price + cached * cached_price.
    final effectivePrompt = TokenUsageUtils.nonCachedPromptTokensOrNull(
            promptTokens: prompt,
            cachedTokens: cached,
            cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt) ??
        prompt;
    final inputCost =
        (effectivePrompt * prices['input']!) + (cached * prices['cached']!);

    // Output cost: (completion + thought) * output_price
    // Thought tokens are usually part of the output billing
    final outputCost = model.startsWith(
            'ep-') // todo: responses API completion includes thought
        ? completion * prices['output']!
        : (completion + thought) * prices['output']!;

    return {
      'input': inputCost,
      'output': outputCost,
      'total': inputCost + outputCost,
    };
  }

  String _formatCost(double cost) {
    if (cost == 0) return '';
    return '(\$${cost.toStringAsFixed(5)})';
  }

  String _formatTotalCost(double cost) {
    return '\$${cost.toStringAsFixed(4)}';
  }

  /// Aggregate records into the format expected by the UI
  Map<String, dynamic> _aggregateRecords(List<Map<String, dynamic>> records) {
    final dailyStats = <String, Map<String, dynamic>>{};
    // final monthlyStats = <String, Map<String, dynamic>>{}; // Removed
    final agentStats = <String, Map<String, dynamic>>{};

    int totalCalls = 0;
    int totalPromptTokens = 0;
    int totalCompletionTokens = 0;
    int totalCachedTokens = 0;
    int totalCacheBaseTokens = 0;
    int totalCacheUnknownTokens = 0;
    int totalThoughtTokens = 0;
    int totalTokens = 0;
    double totalEstimatedCost = 0.0;

    for (final record in records) {
      final calls = record['calls'] as List? ?? [];

      for (final call in calls) {
        final usage = call['usage'] as Map<String, dynamic>;
        final promptTokens = usage['prompt_tokens'] as int? ?? 0;
        final completionTokens = usage['completion_tokens'] as int? ?? 0;
        final cachedTokens = usage['cached_tokens'] as int? ?? 0;
        final model = call['model'] as String? ?? '';
        final cachedTokensIncludedInPrompt =
            TokenUsageUtils.cachedTokensIncludedInPrompt(
          originalUsage: usage['original_usage'],
          recordedValue: usage['cache_tokens_included_in_prompt'],
        );
        final cacheBaseTokens = (usage['cache_base_tokens'] as int?) ??
            TokenUsageUtils.effectivePromptTokensOrNull(
                promptTokens: promptTokens,
                cachedTokens: cachedTokens,
                cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt);
        final cacheUnknownTokens =
            cacheBaseTokens == null && cachedTokens > 0 ? cachedTokens : 0;
        final thoughtTokens = usage['thought_tokens'] as int? ?? 0;
        final tokens = usage['total_tokens'] as int? ?? 0;
        final agentName = call['agent_name'] as String;

        final timestamp = call['timestamp'] as int?;
        final callCreatedAt = timestamp != null
            ? DateTime.fromMicrosecondsSinceEpoch(timestamp)
            : DateTime.fromMicrosecondsSinceEpoch(record['created_at'] as int);

        final costs = _calculateCost(model, promptTokens, completionTokens,
            cachedTokens, thoughtTokens, cachedTokensIncludedInPrompt);
        final cost = costs['total']!;

        // Helper to update stats map
        void updateStat(
            Map<String, Map<String, dynamic>> statsMap, String key) {
          if (!statsMap.containsKey(key)) {
            statsMap[key] = {
              'calls': 0,
              'prompt_tokens': 0,
              'completion_tokens': 0,
              'cached_tokens': 0,
              'cache_base_tokens': 0,
              'cache_unknown_tokens': 0,
              'thought_tokens': 0,
              'total_tokens': 0,
              'total_cost': 0.0,
            };
          }
          final stat = statsMap[key]!;
          stat['calls'] = (stat['calls'] as int) + 1;
          stat['prompt_tokens'] = (stat['prompt_tokens'] as int) + promptTokens;
          stat['completion_tokens'] =
              (stat['completion_tokens'] as int) + completionTokens;
          stat['cached_tokens'] = (stat['cached_tokens'] as int) + cachedTokens;
          stat['cache_base_tokens'] =
              (stat['cache_base_tokens'] as int) + (cacheBaseTokens ?? 0);
          stat['cache_unknown_tokens'] =
              (stat['cache_unknown_tokens'] as int) + cacheUnknownTokens;
          stat['thought_tokens'] =
              (stat['thought_tokens'] as int) + thoughtTokens;
          stat['total_tokens'] = (stat['total_tokens'] as int) + tokens;
          stat['total_cost'] = (stat['total_cost'] as double) + cost;
        }

        // By Day
        final dayKey = DateFormat('yyyy-MM-dd').format(callCreatedAt);
        updateStat(dailyStats, dayKey);

        // By Agent
        updateStat(agentStats, agentName);

        // Total
        totalCalls++;
        totalPromptTokens += promptTokens;
        totalCompletionTokens += completionTokens;
        totalCachedTokens += cachedTokens;
        totalCacheBaseTokens += cacheBaseTokens ?? 0;
        totalCacheUnknownTokens += cacheUnknownTokens;
        totalThoughtTokens += thoughtTokens;
        totalTokens += tokens;
        totalEstimatedCost += cost;
      }
    }

    return {
      'total': {
        'calls': totalCalls,
        'prompt_tokens': totalPromptTokens,
        'completion_tokens': totalCompletionTokens,
        'cached_tokens': totalCachedTokens,
        'cache_base_tokens': totalCacheBaseTokens,
        'cache_unknown_tokens': totalCacheUnknownTokens,
        'thought_tokens': totalThoughtTokens,
        'total_tokens': totalTokens,
        'total_cost': totalEstimatedCost,
      },
      'by_day': dailyStats,
      'by_agent': agentStats,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.modelUsageStats),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: UserStorage.l10n.overview),
            Tab(text: UserStorage.l10n.daily),
            Tab(text: UserStorage.l10n.detail),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: AgentLogoLoading())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildListTab('by_day', UserStorage.l10n.date),
                _buildDetailedTab(),
              ],
            ),
    );
  }

  String _formatTokenCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(2)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(2)}k';
    }
    return count.toString();
  }

  Widget _buildOverviewTab() {
    final total = _stats['total'] as Map<String, dynamic>? ?? {};
    if (total.isEmpty) {
      return Center(child: Text(UserStorage.l10n.noData));
    }

    final cost = total['total_cost'] as double? ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(UserStorage.l10n.totalCalls, total['calls'].toString(),
            Colors.blue),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  UserStorage.l10n.totalTokenConsumption,
                  _formatTokenCount(total['total_tokens'] as int? ?? 0),
                  Colors.purple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(UserStorage.l10n.totalEstimatedCost,
                  _formatTotalCost(cost), Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
            'Cache Rate',
            _calculateCacheRate(total['cached_tokens'] as int? ?? 0,
                total['cache_base_tokens'] as int? ?? 0,
                unknownCachedTokens:
                    total['cache_unknown_tokens'] as int? ?? 0),
            Colors.teal),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  'Prompt Tokens',
                  _formatTokenCount(total['prompt_tokens'] as int? ?? 0),
                  Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  'Completion Tokens',
                  _formatTokenCount(total['completion_tokens'] as int? ?? 0),
                  Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  'Cached Tokens',
                  _formatTokenCount(total['cached_tokens'] as int? ?? 0),
                  Colors.cyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  'Thought Tokens',
                  _formatTokenCount(total['thought_tokens'] as int? ?? 0),
                  Colors.teal),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateCacheRate(int cached, int prompt,
      {int unknownCachedTokens = 0}) {
    if (unknownCachedTokens > 0) return 'N/A';
    return TokenUsageUtils.formatCacheRate(
        promptTokens: prompt,
        cachedTokens: cached,
        cachedTokensIncludedInPrompt: true);
  }

  Widget _buildListTab(String key, String label) {
    final data = _stats[key] as Map<String, dynamic>? ?? {};
    if (data.isEmpty) {
      return Center(child: Text(UserStorage.l10n.noData));
    }

    // Sort keys reverse (newest first)
    final keys = data.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final itemKey = keys[index];
        final itemData = data[itemKey] as Map<String, dynamic>;

        final cached = itemData['cached_tokens'] as int? ?? 0;
        final cacheBase = itemData['cache_base_tokens'] as int? ?? 0;
        final cacheRate = _calculateCacheRate(cached, cacheBase,
            unknownCachedTokens: itemData['cache_unknown_tokens'] as int? ?? 0);
        final cost = itemData['total_cost'] as double? ?? 0.0;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$label: $itemKey',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatTotalCost(cost),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Calls: ${itemData['calls']}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailRow('Total Tokens',
                    _formatTokenCount(itemData['total_tokens'] as int? ?? 0)),
                _buildDetailRow('Cache Rate', cacheRate),
                const SizedBox(height: 4),
                _buildDetailRow('Prompt',
                    _formatTokenCount(itemData['prompt_tokens'] as int? ?? 0)),
                _buildDetailRow(
                    'Completion',
                    _formatTokenCount(
                        itemData['completion_tokens'] as int? ?? 0)),
                _buildDetailRow('Cached',
                    _formatTokenCount(itemData['cached_tokens'] as int? ?? 0)),
                _buildDetailRow('Thought',
                    _formatTokenCount(itemData['thought_tokens'] as int? ?? 0)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedTab() {
    if (_records.isEmpty) {
      return Center(child: Text(UserStorage.l10n.noData));
    }

    // Sort records by updated_at desc
    final records = List<Map<String, dynamic>>.from(_records);
    records.sort(
        (a, b) => (b['updated_at'] as int).compareTo(a['updated_at'] as int));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final calls = record['calls'] as List? ?? [];
        if (calls.isEmpty) return const SizedBox.shrink();

        // Aggregate record stats
        int recPrompt = 0;
        int recCompletion = 0;
        int recCached = 0;
        int recCacheBase = 0;
        int recCacheUnknown = 0;
        int recThought = 0;
        int recTotal = 0;
        double recCost = 0.0;

        for (final call in calls) {
          final usage = call['usage'] as Map<String, dynamic>;
          final p = usage['prompt_tokens'] as int? ?? 0;
          final c = usage['completion_tokens'] as int? ?? 0;
          final ca = usage['cached_tokens'] as int? ?? 0;
          final model = call['model'] as String? ?? '';
          final cachedTokensIncludedInPrompt =
              TokenUsageUtils.cachedTokensIncludedInPrompt(
            originalUsage: usage['original_usage'],
            recordedValue: usage['cache_tokens_included_in_prompt'],
          );
          final cacheBase = (usage['cache_base_tokens'] as int?) ??
              TokenUsageUtils.effectivePromptTokensOrNull(
                  promptTokens: p,
                  cachedTokens: ca,
                  cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt);
          final cacheUnknown = cacheBase == null && ca > 0 ? ca : 0;
          final t = usage['thought_tokens'] as int? ?? 0;
          recPrompt += p;
          recCompletion += c;
          recCached += ca;
          recCacheBase += cacheBase ?? 0;
          recCacheUnknown += cacheUnknown;
          recThought += t;
          recTotal += usage['total_tokens'] as int? ?? 0;

          final costs =
              _calculateCost(model, p, c, ca, t, cachedTokensIncludedInPrompt);
          recCost += costs['total']!;
        }

        final timestamp =
            DateTime.fromMicrosecondsSinceEpoch(record['created_at'] as int);
        final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
        final cacheRate = _calculateCacheRate(recCached, recCacheBase,
            unknownCachedTokens: recCacheUnknown);

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _showRecordCalls(record, calls),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${record['scene']} (${calls.length} calls)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(timeStr,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  if (record['scene_id'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${record['scene_id']}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildMiniStat(
                          'Total', _formatTokenCount(recTotal), Colors.purple),
                      _buildMiniStat('Rate', cacheRate, Colors.teal),
                      Text(
                        _formatCost(recCost),
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: Text('P: ${_formatTokenCount(recPrompt)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text('C: ${_formatTokenCount(recCompletion)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text('Ca: ${_formatTokenCount(recCached)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text('T: ${_formatTokenCount(recThought)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRecordCalls(Map<String, dynamic> record, List calls) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Record Details: ${record['scene']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: calls.length,
                    itemBuilder: (context, index) {
                      final call = calls[index] as Map<String, dynamic>;
                      final usage = call['usage'] as Map<String, dynamic>;
                      final timestamp = DateTime.fromMicrosecondsSinceEpoch(
                          call['timestamp'] as int);
                      final timeStr =
                          DateFormat('HH:mm:ss.SSS').format(timestamp);

                      final prompt = usage['prompt_tokens'] as int? ?? 0;
                      final completion =
                          usage['completion_tokens'] as int? ?? 0;
                      final cached = usage['cached_tokens'] as int? ?? 0;
                      final thought = usage['thought_tokens'] as int? ?? 0;
                      final total = usage['total_tokens'] as int? ?? 0;

                      final model = call['model'] as String? ?? '';
                      final cachedTokensIncludedInPrompt =
                          TokenUsageUtils.cachedTokensIncludedInPrompt(
                        originalUsage: usage['original_usage'],
                        recordedValue: usage['cache_tokens_included_in_prompt'],
                      );
                      final cacheBase = (usage['cache_base_tokens'] as int?) ??
                          TokenUsageUtils.effectivePromptTokensOrNull(
                              promptTokens: prompt,
                              cachedTokens: cached,
                              cachedTokensIncludedInPrompt:
                                  cachedTokensIncludedInPrompt);
                      final cacheRate = cacheBase == null && cached > 0
                          ? 'N/A'
                          : _calculateCacheRate(cached, cacheBase ?? 0);

                      final costs = _calculateCost(model, prompt, completion,
                          cached, thought, cachedTokensIncludedInPrompt);
                      final totalCost = costs['total']!;
                      final inputCost = costs['input']!;
                      final outputCost = costs['output']!;

                      return Card(
                        elevation: 0,
                        color: Colors.grey[50],
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _showCallDetails(call),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        call['agent_name'] ?? 'Unknown',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(timeStr,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Model: ${call['model']}',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total: ${_formatTokenCount(total)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    Text('Rate: $cacheRate',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold)),
                                    Text(_formatCost(totalCost),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'P: ${_formatTokenCount(prompt)}\n${_formatCost(inputCost)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'C: ${_formatTokenCount(completion)}\n${_formatCost(outputCost)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Ca: ${_formatTokenCount(cached)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'T: ${_formatTokenCount(thought)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 10, color: color)),
          Text(value,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _showCallDetails(Map<String, dynamic> call) {
    final usage = call['usage'] as Map<String, dynamic>;
    final prompt = usage['prompt_tokens'] as int? ?? 0;
    final cached = usage['cached_tokens'] as int? ?? 0;
    final cachedTokensIncludedInPrompt =
        TokenUsageUtils.cachedTokensIncludedInPrompt(
      originalUsage: usage['original_usage'],
      recordedValue: usage['cache_tokens_included_in_prompt'],
    );
    final cacheBase = (usage['cache_base_tokens'] as int?) ??
        TokenUsageUtils.effectivePromptTokensOrNull(
            promptTokens: prompt,
            cachedTokens: cached,
            cachedTokensIncludedInPrompt: cachedTokensIncludedInPrompt);
    final cacheRate = cacheBase == null && cached > 0
        ? 'N/A'
        : _calculateCacheRate(cached, cacheBase ?? 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(call['agent_name'] ?? 'Call Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Model', call['model'] ?? 'N/A'),
              _buildDetailRow('Scene', call['scene'] ?? 'N/A'),
              _buildDetailRow('Scene ID', call['scene_id'] ?? 'N/A'),
              const Divider(),
              const Text('Token Usage',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailRow('Cache Rate', cacheRate),
              _buildDetailRow('Prompt', _formatTokenCount(prompt)),
              _buildDetailRow('Completion',
                  _formatTokenCount(usage['completion_tokens'] as int? ?? 0)),
              _buildDetailRow('Cached', _formatTokenCount(cached)),
              _buildDetailRow('Thought',
                  _formatTokenCount(usage['thought_tokens'] as int? ?? 0)),
              _buildDetailRow('Total',
                  _formatTokenCount(usage['total_tokens'] as int? ?? 0)),
              if (call['handler_name'] != null) ...[
                const Divider(),
                _buildDetailRow('Handler', call['handler_name']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(UserStorage.l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
