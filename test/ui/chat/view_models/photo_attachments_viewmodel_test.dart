import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:memex/domain/models/prepared_photo_attachment.dart';
import 'package:memex/ui/chat/view_models/photo_attachments_viewmodel.dart';
import 'package:memex/utils/result.dart';

AssetEntity asset(String id) =>
    AssetEntity(id: id, typeInt: 1, width: 100, height: 100);
PreparedPhotoAttachment photo(String id) => PreparedPhotoAttachment(
    path: '/original/$id.heic', originalName: '$id.heic');

void main() {
  test('publishes immediately, bounds exports, and preserves selection order',
      () async {
    final jobs = <String, Completer<Result<PreparedPhotoAttachment>>>{};
    final vm = PhotoAttachmentsViewModel.forTesting(loader: (id) {
      final job = Completer<Result<PreparedPhotoAttachment>>();
      jobs[id] = job;
      return job.future;
    });
    addTearDown(vm.dispose);
    vm.addAssets([asset('a'), asset('b'), asset('c'), asset('a')]);
    expect(vm.items.map((e) => e.asset!.id), ['a', 'b', 'c']);
    expect(jobs.keys, ['a', 'b']);
    expect(vm.canSubmit, isFalse);
    jobs['b']!.complete(Ok(photo('b')));
    await Future<void>.delayed(Duration.zero);
    expect(jobs.keys, ['a', 'b', 'c']);
    expect(vm.items[1].prepared!.originalName, 'b.heic');
    expect(vm.canSubmit, isFalse);
    jobs['a']!.complete(Ok(photo('a')));
    jobs['c']!.complete(Ok(photo('c')));
    await Future<void>.delayed(Duration.zero);
    expect(vm.canSubmit, isTrue);
    expect(vm.items.map((e) => e.prepared!.path),
        ['/original/a.heic', '/original/b.heic', '/original/c.heic']);
  });

  test('removed and cleared selections never return on late completion',
      () async {
    final jobs = <String, Completer<Result<PreparedPhotoAttachment>>>{};
    final vm = PhotoAttachmentsViewModel.forTesting(loader: (id) {
      final job = Completer<Result<PreparedPhotoAttachment>>();
      jobs[id] = job;
      return job.future;
    });
    addTearDown(vm.dispose);
    vm.addAssets([asset('a'), asset('b'), asset('queued')]);
    vm.remove(vm.items.first);
    vm.remove(vm.items.last);
    jobs['a']!.complete(Ok(photo('a')));
    await Future<void>.delayed(Duration.zero);
    expect(jobs.containsKey('queued'), isFalse);
    expect(vm.items.map((e) => e.asset!.id), ['b']);
    vm.clear();
    jobs['b']!.complete(Ok(photo('b')));
    await Future<void>.delayed(Duration.zero);
    expect(vm.items, isEmpty);
    expect(vm.canSubmit, isTrue);
  });

  test('failed originals block submission and can be retried', () async {
    var attempts = 0;
    final vm = PhotoAttachmentsViewModel.forTesting(loader: (id) async {
      attempts++;
      return attempts == 1 ? Error(StateError('offline')) : Ok(photo(id));
    });
    addTearDown(vm.dispose);
    vm.addAssets([asset('a')]);
    await Future<void>.delayed(Duration.zero);
    expect(vm.items.single.failed, isTrue);
    expect(vm.canSubmit, isFalse);
    vm.retry(vm.items.single);
    vm.retry(vm.items.single);
    await Future<void>.delayed(Duration.zero);
    expect(attempts, 2);
    expect(vm.canSubmit, isTrue);
  });

  test('disposing suppresses notifications and skips queued exports', () async {
    final pending = Completer<Result<PreparedPhotoAttachment>>();
    var calls = 0;
    var notifications = 0;
    final vm = PhotoAttachmentsViewModel.forTesting(loader: (_) {
      calls++;
      return pending.future;
    });
    vm.addListener(() => notifications++);
    vm.addAssets([asset('a'), asset('b'), asset('c')]);
    vm.dispose();
    pending.complete(Ok(photo('a')));
    await Future<void>.delayed(Duration.zero);
    expect(calls, 2);
    expect(notifications, 1);
  });
}
