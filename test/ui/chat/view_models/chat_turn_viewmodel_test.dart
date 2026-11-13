import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/model/chat_events.dart';
import 'package:memex/ui/chat/view_models/chat_turn_viewmodel.dart';

void main() {
  test('preparation, queue and execution are distinct request states', () {
    final vm = ChatTurnViewModel();
    vm.prepare('a');
    expect(vm.hasPreparing, isTrue);
    vm.handle(ChatTurnQueuedEvent('a', 'run'), runId: 'submission');
    expect(vm.phaseOf('a'), ChatTurnPhase.queued);
    vm.handle(ChatAgentStartedEvent('a'), runId: 'run');
    expect(vm.hasRunning, isTrue);
    vm.handle(ChatAgentStoppedEvent('a'), runId: 'run');
    expect(vm.hasPending, isFalse);
  });

  test('closing an old run preserves independent preparation and queued work',
      () {
    final vm = ChatTurnViewModel();
    vm.handle(ChatAgentStartedEvent('a'), runId: 'old');
    vm.prepare('b');
    vm.handle(ChatTurnQueuedEvent('c', 'new'), runId: 'submission');
    vm.finishRun('old');
    expect(vm.phaseOf('a'), ChatTurnPhase.completed);
    expect(vm.phaseOf('b'), ChatTurnPhase.preparing);
    expect(vm.phaseOf('c'), ChatTurnPhase.queued);
    expect(vm.hasPending, isTrue);
  });

  test('finishing submission does not finish the queued turn', () {
    final vm = ChatTurnViewModel();
    vm.prepare('a');
    vm.handle(ChatTurnQueuedEvent('a', 'live'), runId: 'submission');
    vm.finishPreparation('a');
    vm.finishRun('submission');
    expect(vm.phaseOf('a'), ChatTurnPhase.queued);
    vm.finishRun('live');
    expect(vm.hasPending, isFalse);
  });

  test('late enqueue acknowledgement cannot regress a running or ended turn',
      () {
    final vm = ChatTurnViewModel();
    vm.handle(ChatAgentStartedEvent('a'), runId: 'run');
    vm.handle(ChatTurnQueuedEvent('a', 'run'), runId: 'submission');
    expect(vm.phaseOf('a'), ChatTurnPhase.running);
    vm.handle(ChatAgentStoppedEvent('a'), runId: 'run');
    vm.handle(ChatTurnQueuedEvent('a', 'run'), runId: 'submission');
    expect(vm.hasPending, isFalse);
  });

  test('preparation errors and stream errors are scoped to their request', () {
    final vm = ChatTurnViewModel();
    vm.handle(ChatAgentStartedEvent('a'), runId: 'run');
    vm.prepare('b');
    vm.handle(ChatErrorEvent('b', 'bad image'), runId: 'submission');
    vm.finishPreparation('b');
    expect(vm.phaseOf('b'), ChatTurnPhase.failed);
    expect(vm.phaseOf('a'), ChatTurnPhase.running);
    expect(vm.hasPending, isTrue);
  });
}
