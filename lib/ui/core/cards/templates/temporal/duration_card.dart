import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/ui/glass_card.dart';
import 'package:memex/l10n/app_localizations.dart';

class DurationCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final String? cardId;
  final int? configIndex;
  final Function(String cardId, int configIndex, Map<String, dynamic> data)?
      onUpdate;

  const DurationCard({
    super.key,
    required this.data,
    this.onTap,
    this.cardId,
    this.configIndex,
    this.onUpdate,
  });

  @override
  State<DurationCard> createState() => _DurationCardState();
}

class _DurationCardState extends State<DurationCard>
    with WidgetsBindingObserver {
  late int _totalDuration;
  late int _remaining;
  late bool _isRunning;
  int _completionCount = 0;
  DateTime? _lastTick;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeState();
  }

  @override
  void didUpdateWidget(DurationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      // Basic check, might need deeper comparison to avoid resetting active timer
      // For now, if external data updates, we re-sync but try to preserve running state if implied
    }
  }

  void _initializeState() {
    // 'elapsed' is used as the total duration to count down from
    _totalDuration = (widget.data['elapsed'] as num?)?.toInt() ?? 0;

    // 'remaining' is the current countdown value. If null, start from total.
    _remaining = (widget.data['remaining'] as num?)?.toInt() ?? _totalDuration;

    _completionCount = (widget.data['completion_count'] as num?)?.toInt() ?? 0;

    _isRunning = widget.data['is_running'] ?? false;
    final lastTickStr = widget.data['last_tick'] as String?;
    if (lastTickStr != null) {
      _lastTick = DateTime.tryParse(lastTickStr);
    }

    if (_isRunning && _lastTick != null) {
      // Calculate time passed while away/inactive
      final now = DateTime.now();
      final difference = now.difference(_lastTick!).inSeconds;
      if (difference > 0) {
        _remaining -= difference;
        if (_remaining < 0) _remaining = 0;
      }
      _startLocalTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isRunning && _lastTick != null) {
        final now = DateTime.now();
        final difference = now.difference(_lastTick!).inSeconds;
        if (difference > 0) {
          setState(() {
            _remaining -= difference;
            if (_remaining < 0) _remaining = 0;
            _lastTick = now;
          });
        }
      }
    }
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _lastTick = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 0) {
        // Timer finished
        _stopTimer();
        setState(() {
          // Reset to initial duration
          _remaining = _totalDuration;
          // Increment completion count
          _completionCount++;
          // Ensure it stops
          _isRunning = false;
          _lastTick = null;
        });

        // Persist completion count
        if (widget.cardId != null &&
            widget.configIndex != null &&
            widget.onUpdate != null) {
          widget.onUpdate!(widget.cardId!, widget.configIndex!, {
            'completion_count': _completionCount,
            'is_running': false,
            'last_tick': null,
          });
        }
        return;
      }
      setState(() {
        _remaining--;
        // _lastTick = DateTime.now();
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _lastTick = null;
    });
  }

  void _toggleTimer() {
    if (_remaining <= 0) {
      setState(() {
        _remaining = _totalDuration;
      });
    }

    if (_isRunning) {
      _stopTimer();
    } else {
      setState(() {
        _isRunning = true;
      });
      _startLocalTimer();
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 0) seconds = 0;
    final Duration d = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.data['title'] ?? 'Duration';
    final String durationStr = _formatDuration(_remaining);

    return GlassCard(
      onTap: widget.onTap,
      backgroundColor: const Color(0xFF0F172A), // Slate-900
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Decorative Blobs (Background) - Kept from original
          Positioned(
            top: -30,
            right: -20,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha:0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon + Duration
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleTimer,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _isRunning
                                    ? const Color(0xFF34D399) // Emerald
                                    : Colors.white.withValues(alpha:0.05)),
                          ),
                          child: Icon(
                              _isRunning ? Icons.timer : Icons.timer_outlined,
                              color: _isRunning
                                  ? const Color(0xFF34D399) // Emerald
                                  : const Color(0xFFC7D2FE), // Indigo-200
                              size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 12, color: Color(0xFFE0E7FF)),
                                const SizedBox(width: 6),
                                Text(
                                  durationStr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE0E7FF), // Indigo-100
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha:0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Completion Count
                if (_completionCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _completionCount.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF34D399), // Emerald
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppLocalizations.of(context)!.timesLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Colors.white.withValues(alpha:0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
