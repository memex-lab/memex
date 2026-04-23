import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memex/data/repositories/get_schedule_aggregation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/schedule_aggregation_model.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/result.dart';

final _logger = getLogger('ScheduleAggregatorViewModel');

class ScheduleAggregatorViewModel extends ChangeNotifier {
  ScheduleAggregationModel? _aggregation;
  bool _isLoading = false;
  String? _error;

  ScheduleAggregationModel? get aggregation => _aggregation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _aggregation != null;

  /// Load schedule aggregation from disk
  Future<void> loadAggregation() async {
    _setLoading(true);
    try {
      _aggregation = await getScheduleAggregation();
      _error = null;
    } catch (e) {
      _logger.severe('Failed to load schedule aggregation: $e');
      _error = 'Failed to load schedule data';
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh schedule aggregation by triggering the Agent
  Future<void> refreshAggregation() async {
    _setLoading(true);
    try {
      // Trigger agent run via MemexRouter
      final result = await MemexRouter().refreshScheduleAggregation();
      result.when(
        onOk: (_) {
          _logger.info('Schedule aggregation refresh triggered');
        },
        onError: (e, st) {
          _logger.warning('Failed to trigger schedule aggregation: $e');
          _error = 'Failed to trigger agent: $e';
        },
      );

      // Wait a bit for agent to complete, then reload
      // In production, this should be event-driven instead of polling
      await Future.delayed(const Duration(seconds: 2));
      await loadAggregation();
    } catch (e) {
      _logger.severe('Failed to refresh schedule aggregation: $e');
      _error = 'Failed to refresh schedule data';
    } finally {
      _setLoading(false);
    }
  }

  /// Check if data needs refresh and load if needed
  Future<void> ensureFresh({Duration? maxAge}) async {
    final needsRefresh = await scheduleAggregationNeedsRefresh(maxAge: maxAge);
    if (needsRefresh || _aggregation == null) {
      await loadAggregation();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
