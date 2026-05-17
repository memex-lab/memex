import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/themes/app_colors.dart';

class AsyncTaskListPage extends StatefulWidget {
  const AsyncTaskListPage({super.key});

  @override
  State<AsyncTaskListPage> createState() => _AsyncTaskListPageState();
}

class _AsyncTaskListPageState extends State<AsyncTaskListPage> {
  final List<Task> _tasks = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTasks(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMore) {
        _loadTasks();
      }
    }
  }

  Future<void> _loadTasks({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (refresh) {
        _offset = 0;
        _tasks.clear();
        _hasMore = true;
      }

      final newTasks = await MemexRouter().getTasks(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _tasks.addAll(newTasks);
        _offset += newTasks.length;
        if (newTasks.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load tasks failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      case 'retrying':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }

  void _showTaskDetail(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('${task.type} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText('ID: ${task.id}'),
              const SizedBox(height: 8),
              SelectableText('BizID: ${task.bizId ?? "N/A"}'),
              const SizedBox(height: 8),
              SelectableText('Status: ${task.status}'),
              const SizedBox(height: 8),
              SelectableText('Created: ${_formatDate(task.createdAt)}'),
              SelectableText('Scheduled: ${_formatDate(task.scheduledAt)}'),
              SelectableText('Updated: ${_formatDate(task.updatedAt)}'),
              SelectableText('Completed: ${_formatDate(task.completedAt)}'),
              const SizedBox(height: 12),
              const Text('Payload:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.grey[100],
                child: SelectableText(task.payload ?? 'null'),
              ),
              if (task.error != null && task.error!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Last error:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[50],
                  child: SelectableText(
                    task.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
              if (task.result != null && task.result!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Result:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.green[50],
                  child: SelectableText(task.result!),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UserStorage.l10n.asyncTaskList),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadTasks(refresh: true),
        child: _tasks.isEmpty && !_isLoading
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text(UserStorage.l10n.noTaskData)),
                ],
              )
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _tasks.length + (_hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == _tasks.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final task = _tasks[index];
                  // Only show error if status is failed
                  final hasError = task.status == 'failed' &&
                      task.error != null &&
                      task.error!.isNotEmpty;

                  // Calculate duration
                  String? durationStr;
                  if ((task.status == 'completed' || task.status == 'failed') &&
                      task.completedAt != null) {
                    final start = task.scheduledAt ?? task.createdAt;
                    if (start != null) {
                      final duration = task.completedAt! - start;
                      durationStr = '${duration}s';
                    }
                  }

                  return InkWell(
                    onTap: () => _showTaskDetail(task),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: hasError
                                ? Colors.red.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  task.type,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.status,
                                  style: TextStyle(
                                    color: _getStatusColor(task.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (task.bizId != null) ...[
                            Text(
                              'BizID: ${task.bizId}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'ID: ${task.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    UserStorage.l10n.createdAtDate(
                                        _formatDate(task.createdAt)),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              if (task.updatedAt != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.update,
                                        size: 14, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      UserStorage.l10n.updatedAtDate(
                                          _formatDate(task.updatedAt)),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (durationStr != null ||
                                  task.retryCount > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (durationStr != null) ...[
                                      Icon(Icons.timer_outlined,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        UserStorage.l10n
                                            .durationLabel(durationStr),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      if (task.retryCount > 0)
                                        const SizedBox(width: 12),
                                    ],
                                    if (task.retryCount > 0) ...[
                                      Icon(Icons.refresh,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        UserStorage.l10n
                                            .retryCount(task.retryCount),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                          if (hasError) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  'Failed with error (tap to see details)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
