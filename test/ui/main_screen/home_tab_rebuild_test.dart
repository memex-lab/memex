import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/ui/insight/view_models/insight_viewmodel.dart';
import 'package:memex/ui/knowledge/view_models/knowledge_base_viewmodel.dart';
import 'package:memex/ui/timeline/view_models/timeline_viewmodel.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('reading tab view models does not rebuild siblings on notify',
      (tester) async {
    final timeline = TimelineViewModel.forTest(autoLoad: false);
    final insight = InsightViewModel(router: MemexRouter());
    final knowledge = KnowledgeBaseViewModel(router: MemexRouter());
    addTearDown(timeline.dispose);
    addTearDown(insight.dispose);
    addTearDown(knowledge.dispose);

    var knowledgeBuilds = 0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TimelineViewModel>.value(value: timeline),
          ChangeNotifierProvider<InsightViewModel>.value(value: insight),
          ChangeNotifierProvider<KnowledgeBaseViewModel>.value(value: knowledge),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  Text('cards:${context.read<TimelineViewModel>().cards.length}'),
                  Builder(
                    builder: (context) {
                      knowledgeBuilds += 1;
                      context.read<KnowledgeBaseViewModel>();
                      return Text('kb:$knowledgeBuilds');
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(knowledgeBuilds, 1);
    timeline.notifyListeners();
    await tester.pump();
    expect(knowledgeBuilds, 1);
  });
}
