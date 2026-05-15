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
    _tabController = TabController(length: 4, vsync: this);
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
    final agentStats = <String, Map<String, dynamic>>{};

    int totalCalls = 0;
    int totalPromptTokens = 0;
    int totalCompletionTokens = 0;
    int totalCachedTokens = 0;
    int totalEffectivePromptTokens = 0;
    int totalCachedForRate = 0;
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
        final sem = TokenUsageUtils.resolveFromUsageRecord(usage);
        final effPrompt = TokenUsageUtils.effectivePromptTokensOrNull(
            promptTokens: promptTokens,
            cachedTokens: cachedTokens,
            cachedTokensIncludedInPrompt: sem);
        final thoughtTokens = usage['thought_tokens'] as int? ?? 0;
        final tokens = usage['total_tokens'] as int? ?? 0;
        final agentName = call['agent_name'] as String;

        final timestamp = call['timestamp'] as int?;
        final callCreatedAt = timestamp != null
            ? DateTime.fromMicrosecondsSinceEpoch(timestamp)
            : DateTime.fromMicrosecondsSinceEpoch(record['created_at'] as int);

        final costs = TokenUsageUtils.calculateCost(
            model: model,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            cachedTokens: cachedTokens,
            thoughtTokens: thoughtTokens,
            cachedTokensIncludedInPrompt: sem);
        final cost = costs['total']!;

        // Helper to update stats map
        void updateStat(
          Map<String, Map<String, dynamic>> statsMap,
          String key, {
          String? modelName,
        }) {
          if (!statsMap.containsKey(key)) {
            statsMap[key] = {
              'calls': 0,
              'prompt_tokens': 0,
              'completion_tokens': 0,
              'cached_tokens': 0,
              'effective_prompt_tokens': 0,
              'cached_tokens_for_rate': 0,
              'thought_tokens': 0,
              'total_tokens': 0,
              'total_cost': 0.0,
              if (modelName != null) 'models': <String, Map<String, dynamic>>{},
            };
          }
          final stat = statsMap[key]!;
          stat['calls'] = (stat['calls'] as int) + 1;
          stat['prompt_tokens'] = (stat['prompt_tokens'] as int) + promptTokens;
          stat['completion_tokens'] =
              (stat['completion_tokens'] as int) + completionTokens;
          stat['cached_tokens'] = (stat['cached_tokens'] as int) + cachedTokens;
          if (effPrompt != null) {
            stat['effective_prompt_tokens'] =
                (stat['effective_prompt_tokens'] as int) + effPrompt;
            stat['cached_tokens_for_rate'] =
                (stat['cached_tokens_for_rate'] as int) + cachedTokens;
          }
          stat['thought_tokens'] =
              (stat['thought_tokens'] as int) + thoughtTokens;
          stat['total_tokens'] = (stat['total_tokens'] as int) + tokens;
          stat['total_cost'] = (stat['total_cost'] as double) + cost;

          if (modelName != null) {
            final models = stat.putIfAbsent(
              'models',
              () => <String, Map<String, dynamic>>{},
            ) as Map<String, Map<String, dynamic>>;
            updateStat(models, modelName);
          }
        }

        // By Day
        final dayKey = DateFormat('yyyy-MM-dd').format(callCreatedAt);
        updateStat(dailyStats, dayKey);

        // By Agent
        updateStat(
          agentStats,
          agentName,
          modelName: model.isEmpty ? UserStorage.l10n.unknownModel : model,
        );

        // Total
        totalCalls++;
        totalPromptTokens += promptTokens;
        totalCompletionTokens += completionTokens;
        totalCachedTokens += cachedTokens;
        if (effPrompt != null) {
          totalEffectivePromptTokens += effPrompt;
          totalCachedForRate += cachedTokens;
        }
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
        'effective_prompt_tokens': totalEffectivePromptTokens,
        'cached_tokens_for_rate': totalCachedForRate,
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
            tooltip: UserStorage.l10n.selectDateRange,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: UserStorage.l10n.overview),
            Tab(text: UserStorage.l10n.daily),
            Tab(text: UserStorage.l10n.modelStatsByAgent),
            Tab(text: UserStorage.l10n.detail),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: AgentLogoLoading())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildListTab('by_day', UserStorage.l10n.date),
                _buildAgentStatsTab(),
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
            UserStorage.l10n.cacheRate,
            _calculateCacheRate(total['cached_tokens_for_rate'] as int? ?? 0,
                total['effective_prompt_tokens'] as int? ?? 0),
            Colors.teal),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  UserStorage.l10n.promptTokens,
                  _formatTokenCount(total['prompt_tokens'] as int? ?? 0),
                  Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  UserStorage.l10n.completionTokens,
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
                  UserStorage.l10n.cachedTokens,
                  _formatTokenCount(total['cached_tokens'] as int? ?? 0),
                  Colors.cyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  UserStorage.l10n.thoughtTokens,
                  _formatTokenCount(total['thought_tokens'] as int? ?? 0),
                  Colors.teal),
            ),
          ],
        ),
      ],
    );
  }

  String _calculateCacheRate(int cached, int effectivePrompt) {
    return TokenUsageUtils.formatCacheRateFromAggregated(
        effectivePromptTokens: effectivePrompt, cachedTokens: cached);
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

        final cached = itemData['cached_tokens_for_rate'] as int? ?? 0;
        final effPrompt = itemData['effective_prompt_tokens'] as int? ?? 0;
        final cacheRate = _calculateCacheRate(cached, effPrompt);
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
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            UserStorage.l10n.callsCount(itemData['calls']),
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
                _buildDetailRow(UserStorage.l10n.totalTokens,
                    _formatTokenCount(itemData['total_tokens'] as int? ?? 0)),
                _buildDetailRow(UserStorage.l10n.cacheRate, cacheRate),
                const SizedBox(height: 4),
                _buildDetailRow(UserStorage.l10n.prompt,
                    _formatTokenCount(itemData['prompt_tokens'] as int? ?? 0)),
                _buildDetailRow(
                    UserStorage.l10n.completion,
                    _formatTokenCount(
                        itemData['completion_tokens'] as int? ?? 0)),
                _buildDetailRow(UserStorage.l10n.cached,
                    _formatTokenCount(itemData['cached_tokens'] as int? ?? 0)),
                _buildDetailRow(UserStorage.l10n.thought,
                    _formatTokenCount(itemData['thought_tokens'] as int? ?? 0)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgentStatsTab() {
    final data = _stats['by_agent'] as Map<String, dynamic>? ?? {};
    if (data.isEmpty) {
      return Center(child: Text(UserStorage.l10n.noData));
    }

    final keys = data.keys.toList()
      ..sort((a, b) {
        final aData = data[a] as Map<String, dynamic>;
        final bData = data[b] as Map<String, dynamic>;
        final byCost = (bData['total_cost'] as double? ?? 0.0)
            .compareTo(aData['total_cost'] as double? ?? 0.0);
        if (byCost != 0) return byCost;
        return (bData['total_tokens'] as int? ?? 0)
            .compareTo(aData['total_tokens'] as int? ?? 0);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final agentName = keys[index];
        final itemData = data[agentName] as Map<String, dynamic>;
        final cached = itemData['cached_tokens'] as int? ?? 0;
        final prompt = itemData['prompt_tokens'] as int? ?? 0;
        final cacheRate = _calculateCacheRate(cached, prompt);
        final cost = itemData['total_cost'] as double? ?? 0.0;
        final rawModels = itemData['models'] as Map? ?? {};
        final models = rawModels.map(
          (key, value) => MapEntry(
            key.toString(),
            Map<String, dynamic>.from(value as Map),
          ),
        );
        final modelKeys = models.keys.toList()
          ..sort((a, b) => (models[b]?['total_tokens'] as int? ?? 0)
              .compareTo(models[a]?['total_tokens'] as int? ?? 0));

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${UserStorage.l10n.agent}: $agentName',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTotalCost(cost),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildMiniStat(
                          UserStorage.l10n.calls,
                          '${itemData['calls']}',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailRow(
                  UserStorage.l10n.totalTokens,
                  _formatTokenCount(itemData['total_tokens'] as int? ?? 0),
                ),
                _buildDetailRow(UserStorage.l10n.cacheRate, cacheRate),
                const SizedBox(height: 4),
                _buildDetailRow(
                  UserStorage.l10n.prompt,
                  _formatTokenCount(itemData['prompt_tokens'] as int? ?? 0),
                ),
                _buildDetailRow(
                  UserStorage.l10n.completion,
                  _formatTokenCount(
                    itemData['completion_tokens'] as int? ?? 0,
                  ),
                ),
                _buildDetailRow(
                  UserStorage.l10n.cached,
                  _formatTokenCount(itemData['cached_tokens'] as int? ?? 0),
                ),
                _buildDetailRow(
                  UserStorage.l10n.thought,
                  _formatTokenCount(itemData['thought_tokens'] as int? ?? 0),
                ),
                if (modelKeys.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  Text(
                    UserStorage.l10n.modelBreakdown,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...modelKeys.map((modelName) {
                    final modelData = models[modelName]!;
                    final modelCost = modelData['total_cost'] as double? ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              modelName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            UserStorage.l10n.callsCount(modelData['calls']),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTokenCount(
                              modelData['total_tokens'] as int? ?? 0,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTotalCost(modelCost),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
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
        int recEffectivePrompt = 0;
        int recCachedForRate = 0;
        int recThought = 0;
        int recTotal = 0;
        double recCost = 0.0;

        for (final call in calls) {
          final usage = call['usage'] as Map<String, dynamic>;
          final p = usage['prompt_tokens'] as int? ?? 0;
          final c = usage['completion_tokens'] as int? ?? 0;
          final ca = usage['cached_tokens'] as int? ?? 0;
          final model = call['model'] as String? ?? '';
          final sem = TokenUsageUtils.resolveFromUsageRecord(usage);
          final effP = TokenUsageUtils.effectivePromptTokensOrNull(
              promptTokens: p,
              cachedTokens: ca,
              cachedTokensIncludedInPrompt: sem);
          final t = usage['thought_tokens'] as int? ?? 0;
          recPrompt += p;
          recCompletion += c;
          recCached += ca;
          if (effP != null) {
            recEffectivePrompt += effP;
            recCachedForRate += ca;
          }
          recThought += t;
          recTotal += usage['total_tokens'] as int? ?? 0;

          final costs = TokenUsageUtils.calculateCost(
              model: model,
              promptTokens: p,
              completionTokens: c,
              cachedTokens: ca,
              thoughtTokens: t,
              cachedTokensIncludedInPrompt: sem);
          recCost += costs['total']!;
        }

        final timestamp =
            DateTime.fromMicrosecondsSinceEpoch(record['created_at'] as int);
        final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
        final cacheRate =
            _calculateCacheRate(recCachedForRate, recEffectivePrompt);

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
                          '${record['scene']} (${UserStorage.l10n.callsCount(calls.length)})',
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
                      _buildMiniStat(UserStorage.l10n.totalTokens,
                          _formatTokenCount(recTotal), Colors.purple),
                      _buildMiniStat(
                          UserStorage.l10n.cacheRate, cacheRate, Colors.teal),
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
                          child: Text(
                              '${UserStorage.l10n.prompt}: ${_formatTokenCount(recPrompt)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(
                              '${UserStorage.l10n.completion}: ${_formatTokenCount(recCompletion)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(
                              '${UserStorage.l10n.cached}: ${_formatTokenCount(recCached)}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(
                              '${UserStorage.l10n.thought}: ${_formatTokenCount(recThought)}',
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
                        UserStorage.l10n.recordDetailsTitle(record['scene']),
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
                      final sem = TokenUsageUtils.resolveFromUsageRecord(usage);
                      final effP = TokenUsageUtils.effectivePromptTokensOrNull(
                          promptTokens: prompt,
                          cachedTokens: cached,
                          cachedTokensIncludedInPrompt: sem);
                      final cacheRate = effP != null
                          ? _calculateCacheRate(cached, effP)
                          : '0.0%';

                      final costs = TokenUsageUtils.calculateCost(
                          model: model,
                          promptTokens: prompt,
                          completionTokens: completion,
                          cachedTokens: cached,
                          thoughtTokens: thought,
                          cachedTokensIncludedInPrompt: sem);
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
                                        call['agent_name'] ??
                                            UserStorage.l10n.agent,
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
                                Text(
                                    '${UserStorage.l10n.model}: ${call['model']}',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${UserStorage.l10n.totalTokens}: ${_formatTokenCount(total)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '${UserStorage.l10n.cacheRate}: $cacheRate',
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
                                        '${UserStorage.l10n.prompt}: ${_formatTokenCount(prompt)}\n${_formatCost(inputCost)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${UserStorage.l10n.completion}: ${_formatTokenCount(completion)}\n${_formatCost(outputCost)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${UserStorage.l10n.cached}: ${_formatTokenCount(cached)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${UserStorage.l10n.thought}: ${_formatTokenCount(thought)}',
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
    final sem = TokenUsageUtils.resolveFromUsageRecord(usage);
    final effP = TokenUsageUtils.effectivePromptTokensOrNull(
        promptTokens: prompt,
        cachedTokens: cached,
        cachedTokensIncludedInPrompt: sem);
    final cacheRate = effP != null ? _calculateCacheRate(cached, effP) : '0.0%';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(call['agent_name'] ?? UserStorage.l10n.callDetails),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(UserStorage.l10n.model, call['model'] ?? 'N/A'),
              _buildDetailRow(UserStorage.l10n.scene, call['scene'] ?? 'N/A'),
              _buildDetailRow(
                  UserStorage.l10n.sceneId, call['scene_id'] ?? 'N/A'),
              const Divider(),
              Text(UserStorage.l10n.tokenUsage,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailRow(UserStorage.l10n.cacheRate, cacheRate),
              _buildDetailRow(
                  UserStorage.l10n.prompt, _formatTokenCount(prompt)),
              _buildDetailRow(UserStorage.l10n.completion,
                  _formatTokenCount(usage['completion_tokens'] as int? ?? 0)),
              _buildDetailRow(
                  UserStorage.l10n.cached, _formatTokenCount(cached)),
              _buildDetailRow(UserStorage.l10n.thought,
                  _formatTokenCount(usage['thought_tokens'] as int? ?? 0)),
              _buildDetailRow(UserStorage.l10n.totalTokens,
                  _formatTokenCount(usage['total_tokens'] as int? ?? 0)),
              if (call['handler_name'] != null) ...[
                const Divider(),
                _buildDetailRow(UserStorage.l10n.handler, call['handler_name']),
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
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
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
