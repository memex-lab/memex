import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/character_editor.dart';

void main() {
  test('character draft snapshots mutable editor collections', () {
    final tags = ['朋友'];
    final worldEntry = <String, dynamic>{'content': '旧书店在街角'};
    final memoryEntry = <String, dynamic>{'content': '喜欢被叫姐姐'};
    final draft = CharacterDraft(
      name: '小安',
      tags: tags,
      persona: '温柔的朋友',
      enabled: true,
      worldEntries: [worldEntry],
      memoryEntries: [memoryEntry],
    );

    tags.add('同事');
    worldEntry['content'] = '已经搬走';
    memoryEntry['content'] = '新的称呼';

    expect(draft.tags, ['朋友']);
    expect(draft.worldEntries.single['content'], '旧书店在街角');
    expect(draft.memoryEntries.single['content'], '喜欢被叫姐姐');
  });
}
