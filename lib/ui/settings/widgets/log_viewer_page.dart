import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:memex/data/services/file_logger_service.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  // Config
  bool _autoRefresh = true;
  int _lineCount = 500; // 100, 500, 1000, -1 (All)
  String _levelFilter = 'ALL'; // ALL, WARNING, SEVERE
  String _searchQuery = '';

  // State
  List<File> _logFiles = [];
  File? _selectedFile;
  final List<String> _logLines = [];
  Timer? _refreshTimer;
  int _currentFileOffset = 0;
  bool _isLoading = false;
  bool _isSearching = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  /// Filters
  final List<int> _lineOptions = [100, 500, 1000, -1];
  final List<String> _levelOptions = ['ALL', 'WARNING', 'SEVERE'];

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
    _startAutoRefresh();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_autoRefresh && _selectedFile != null && !_isLoading) {
        _checkAndLoadNewLogs();
      }
    });
  }

  Future<void> _loadLogFiles() async {
    setState(() => _isLoading = true);
    try {
      final files = await FileLoggerService.instance.getAllLogFiles();
      if (mounted) {
        setState(() {
          _logFiles = files;
          if (files.isNotEmpty && _selectedFile == null) {
            _selectedFile = files.first;
            _loadLogs(isInitial: true);
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error loading log files: $e');
    }
  }

  /// Initial load or full reload of the file
  Future<void> _loadLogs({bool isInitial = false}) async {
    if (_selectedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final file = _selectedFile!;
      if (!await file.exists()) {
        _logLines.clear();
        _currentFileOffset = 0;
        return;
      }

      final content = await file.readAsLines();
      _logLines.clear();
      _logLines.addAll(content);
      _currentFileOffset = await file.length(); // Update offset to end of file

      setState(() {});

      // Scroll to bottom on initial load
      if (isInitial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading logs: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Incremental load
  Future<void> _checkAndLoadNewLogs() async {
    if (_selectedFile == null) return;

    try {
      final file = _selectedFile!;
      if (!await file.exists()) return;

      final len = await file.length();
      if (len > _currentFileOffset) {
        // New content available
        final stream = file.openRead(_currentFileOffset, len);
        final newLines = await stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .toList();

        if (newLines.isNotEmpty) {
          if (mounted) {
            setState(() {
              _logLines.addAll(newLines);
              _currentFileOffset = len;
            });
            // Auto-scroll to bottom if already at bottom
            if (_scrollController.hasClients) {
              final pos = _scrollController.position;
              if (pos.pixels >= pos.maxScrollExtent - 50) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                });
              }
            }
          }
        }
      } else if (len < _currentFileOffset) {
        // File truncated or rotated? Reload fully.
        _loadLogs();
      }
    } catch (e) {
      debugPrint('Error reading new logs: $e');
    }
  }

  List<String> _getFilteredLines() {
    List<String> lines = _logLines;

    // 1. Search Filter
    if (_searchQuery.isNotEmpty) {
      lines = lines
          .where(
              (line) => line.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Level Filter
    if (_levelFilter != 'ALL') {
      // If WARNING, include WARNING and SEVERE
      if (_levelFilter == 'WARNING') {
        lines = lines
            .where(
                (line) => line.contains('WARNING') || line.contains('SEVERE'))
            .toList();
      } else if (_levelFilter == 'SEVERE') {
        lines = lines.where((line) => line.contains('SEVERE')).toList();
      }
    }

    // 3. Line Count Limit
    // We modify the VIEW, not the source data (_logLines), so we can toggle back to ALL easily.
    if (_lineCount != -1 && lines.length > _lineCount) {
      lines = lines.sublist(lines.length - _lineCount);
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final filteredLines = _getFilteredLines();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search logs...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black),
              )
            : Text(UserStorage.l10n.logViewer),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: _buildLogFileSelector(),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildControlBar(filteredLines.length),
          Expanded(
            child: _isLoading && _logLines.isEmpty
                ? Center(child: AgentLogoLoading())
                : SelectionArea(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      radius: const Radius.circular(4),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredLines.length,
                        itemBuilder: (context, index) {
                          final line = filteredLines[index];
                          return Text(
                            line,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                              color: _getLineColor(line),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scroll_up',
            mini: true,
            onPressed: () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'scroll_down',
            mini: true,
            onPressed: () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
            child: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }

  Color _getLineColor(String line) {
    if (line.contains('SEVERE')) return Colors.red;
    if (line.contains('WARNING')) return Colors.orange;
    return const Color(0xFF333333);
  }

  Widget _buildLogFileSelector() {
    if (_logFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButton<File>(
      value: _selectedFile,
      underline: const SizedBox(),
      style: const TextStyle(color: Colors.black, fontSize: 14),
      dropdownColor: Colors.white,
      items: _logFiles.map((file) {
        final name = file.path.split('/').last;
        return DropdownMenuItem(
          value: file,
          child: Text(name),
        );
      }).toList(),
      onChanged: (File? newValue) {
        if (newValue != null && newValue != _selectedFile) {
          setState(() {
            _selectedFile = newValue;
            _logLines.clear();
            _currentFileOffset = 0;
          });
          _loadLogs(isInitial: true);
        }
      },
    );
  }

  Widget _buildControlBar(int currentCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Auto Refresh
            Row(
              children: [
                Text(UserStorage.l10n.autoRefresh,
                    style: const TextStyle(fontSize: 12)),
                Switch(
                  value: _autoRefresh,
                  onChanged: (val) => setState(() => _autoRefresh = val),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Line Count
            Row(
              children: [
                Text(UserStorage.l10n.lineCount,
                    style: const TextStyle(fontSize: 12)),
                DropdownButton<int>(
                  value: _lineCount,
                  isDense: true,
                  underline: const SizedBox(),
                  items: _lineOptions.map((n) {
                    return DropdownMenuItem(
                      value: n,
                      child: Text(n == -1 ? UserStorage.l10n.all : '$n'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _lineCount = val);
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Level
            Row(
              children: [
                const Text('Level: ', style: TextStyle(fontSize: 12)),
                DropdownButton<String>(
                  value: _levelFilter,
                  isDense: true,
                  underline: const SizedBox(),
                  items: _levelOptions
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _levelFilter = val);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
