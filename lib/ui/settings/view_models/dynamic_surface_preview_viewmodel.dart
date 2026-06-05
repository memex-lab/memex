import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/event_bus_service.dart';
import 'package:memex/domain/models/dynamic_surface_model.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

class DynamicSurfacePreviewViewModel extends ChangeNotifier {
  DynamicSurfacePreviewViewModel({required MemexRouter router})
      : _router = router {
    EventBusService.instance.addHandler(
      EventBusMessageType.dynamicSurfaceUpdated,
      _handleDynamicSurfaceUpdated,
    );
  }

  final MemexRouter _router;

  bool isLoading = false;
  bool isRendering = false;
  String? errorMessage;
  List<DynamicSurfaceModel> surfaces = [];
  DynamicSurfaceRenderResult? renderResult;
  static const String authorAgentName = 'dynamic-surface-author';

  bool _isDisposed = false;

  void _handleDynamicSurfaceUpdated(EventBusMessage message) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (_isDisposed) return;

      final updatedSurfaceId = message is DynamicSurfaceUpdatedMessage
          ? message.surfaceId
          : message.data['surface_id'] as String? ?? '';
      final currentSurfaceId = renderResult?.surface.id;

      await loadSurfaces();
      if (_isDisposed) return;

      final shouldRefreshCurrent = currentSurfaceId != null &&
          currentSurfaceId.isNotEmpty &&
          (updatedSurfaceId.isEmpty || updatedSurfaceId == currentSurfaceId);
      if (!shouldRefreshCurrent) return;

      final currentStillExists =
          surfaces.any((surface) => surface.id == currentSurfaceId);
      if (currentStillExists) {
        await renderSurface(currentSurfaceId);
      } else {
        renderResult = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadSurfaces() async {
    if (_isDisposed) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _router.listDynamicSurfaces();
    result.when(
      onOk: (value) {
        surfaces = value;
        errorMessage = null;
      },
      onError: (error, _) {
        surfaces = [];
        errorMessage = error.toString();
      },
    );

    isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> renderSurface(String surfaceId) async {
    if (_isDisposed) return;
    isRendering = true;
    errorMessage = null;
    notifyListeners();

    final result = await _router.renderDynamicSurface(surfaceId);
    result.when(
      onOk: (value) {
        renderResult = value;
        errorMessage = null;
      },
      onError: (error, _) {
        renderResult = null;
        errorMessage = error.toString();
      },
    );

    isRendering = false;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> requestAgentRefresh({String? surfaceId}) async {
    final targetSurfaceId = surfaceId ?? renderResult?.surface.id;
    if (targetSurfaceId == null || targetSurfaceId.isEmpty) {
      errorMessage = UserStorage.l10n.selectCustomPageBeforeRefresh;
      notifyListeners();
      return;
    }

    errorMessage = null;
    notifyListeners();
    final result = await _router.refreshDynamicSurface(targetSurfaceId);
    result.when(
      onOk: (_) {},
      onError: (error, _) {
        errorMessage = error.toString();
      },
    );
    notifyListeners();
  }

  Future<void> uninstallSurface(String surfaceId) async {
    if (surfaceId.isEmpty) return;

    errorMessage = null;
    notifyListeners();
    final result = await _router.uninstallDynamicSurface(surfaceId);
    result.when(
      onOk: (_) {
        surfaces =
            surfaces.where((surface) => surface.id != surfaceId).toList();
        if (renderResult?.surface.id == surfaceId) {
          renderResult = null;
        }
      },
      onError: (error, _) {
        errorMessage = error.toString();
      },
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    EventBusService.instance.removeHandler(
      EventBusMessageType.dynamicSurfaceUpdated,
      _handleDynamicSurfaceUpdated,
    );
    super.dispose();
  }
}
