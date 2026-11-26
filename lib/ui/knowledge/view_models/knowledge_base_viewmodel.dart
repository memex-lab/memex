import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/data/services/global_event_bus.dart';
import 'package:memex/domain/models/library_document.dart';
import 'package:memex/domain/models/system_event.dart';
import 'package:memex/utils/result.dart';
import 'package:memex/utils/user_storage.dart';

class KnowledgeBaseViewModel extends ChangeNotifier {
  KnowledgeBaseViewModel({required MemexRouter router}) : _router = router;
  final MemexRouter _router;
  List<LibraryDocument> documents = [];
  List<String> pinned = [], hidden = [];
  List<String> _visits = [];
  bool isLoading = false, failed = false;
  String? _user;
  bool _loaded = false, _disposed = false;
  int _generation = 0;
  Timer? _debounce;
  String get _subscription => 'library_home_${identityHashCode(this)}';
  List<LibraryDocument> get featured =>
      LibraryDocument.highlights(documents, pinned, hidden, visits: _visits);
  Map<String, List<LibraryDocument>> get topics {
    final groups = <String, List<LibraryDocument>>{};
    for (final doc in documents) {
      for (final topic in doc.topics) {
        groups.putIfAbsent(topic, () => []).add(doc);
      }
    }
    final entries = groups.entries.toList()
      ..sort((a, b) {
        final size = b.value.length.compareTo(a.value.length);
        return size != 0 ? size : a.key.compareTo(b.key);
      });
    return Map.fromEntries(entries);
  }

  Future<void> ensureLoaded() async {
    if (isLoading || (_loaded && _user == await UserStorage.getUserId()))
      return;
    if (!_disposed) await fetchData();
  }

  Future<void> fetchData({bool forceRefresh = false}) async {
    final generation = ++_generation;
    isLoading = true;
    notifyListeners();
    final user = await UserStorage.getUserId();
    if (_disposed || generation != _generation) return;
    if (user != _user) {
      documents = [];
      pinned = [];
      hidden = [];
      _visits = [];
    }
    _user = user;
    GlobalEventBus.instance.subscribeSync<DataChangeRecord>(
        eventType: SystemEventTypes.dataChanged,
        subscription: EventSyncSubscription(
            subscriptionId: _subscription,
            handler: (id, event) async {
              if (id != _user) return;
              if (event.payload.ns != DataChangeNs.pkmFile &&
                  (event.payload.ns != DataChangeNs.card ||
                      (event.payload.op == DataChangeOp.update &&
                          event.payload.before?['tags'].toString() ==
                              event.payload.after?['tags'].toString()))) return;
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 650),
                  () => fetchData(forceRefresh: true));
            }));
    final result = await runResult(() async {
      final docs =
          (await _router.loadLibraryHome(refresh: forceRefresh)).valueOrThrow;
      return (
        docs,
        user == null
            ? <String>[]
            : await UserStorage.libraryChoices(user, pins: true),
        user == null
            ? <String>[]
            : await UserStorage.libraryChoices(user, pins: false),
        user == null ? <String>[] : await UserStorage.libraryVisits(user)
      );
    });
    if (_disposed || generation != _generation) return;
    result.when(onOk: (data) {
      documents = data.$1;
      pinned = data.$2;
      hidden = data.$3;
      _visits = data.$4;
      _loaded = true;
      failed = false;
    }, onError: (_, __) {
      failed = true;
      _loaded = false;
    });
    isLoading = false;
    notifyListeners();
  }

  Future<void> opened(String path) async {
    final user = await UserStorage.getUserId();
    if (user == null || _disposed) return;
    final result =
        await runResult(() => UserStorage.recordLibraryVisit(user, path));
    if (!_disposed && _user == user)
      result.when(
          onOk: (paths) {
            _visits = paths;
            notifyListeners();
          },
          onError: (_, __) {});
  }

  Future<bool> toggle(String path, {required bool pin}) async {
    if (!_loaded) await ensureLoaded();
    final user = _user;
    if (user == null || user != await UserStorage.getUserId()) return false;
    final values = List<String>.of(pin ? pinned : hidden);
    if (!values.remove(path)) values.insert(0, path);
    final result = await runResult(
        () => UserStorage.saveLibraryChoices(user, values, pins: pin));
    if (_disposed || user != _user || result.isError) return false;
    if (pin) {
      pinned = values;
    } else {
      hidden = values;
    }
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    GlobalEventBus.instance.unsubscribeSync(
        eventType: SystemEventTypes.dataChanged, subscriptionId: _subscription);
    super.dispose();
  }
}
