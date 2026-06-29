import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memex/domain/models/card_detail_model.dart';
import 'package:memex/domain/models/card_model.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';

void main() {
  testWidgets('ignores structured card content and preserves raw fact text',
      (tester) async {
    final detail = _detail(
      rawContent: '## 晚餐记录\n- 家常菜\n- 太顺杨梅',
      uiConfigs: const [
        UiConfig(
          templateId: 'article',
          data: {
            'title': '端午的温馨家常晚餐和太顺杨梅',
            'body': '一家人吃了家常晚餐，还尝到了太顺杨梅。',
          },
        ),
      ],
      tags: const ['Visual'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimelineCardDetailBodySection(detail: detail),
        ),
      ),
    );

    expect(
      find.textContaining('## 晚餐记录', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('- 家常菜', findRichText: true), findsOneWidget);
    expect(find.textContaining('#Visual', findRichText: true), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.text('端午的温馨家常晚餐和太顺杨梅'), findsNothing);
    expect(find.text('一家人吃了家常晚餐，还尝到了太顺杨梅。'), findsNothing);
  });

  testWidgets('preserves raw fact markdown markers as plain text',
      (tester) async {
    final detail = _detail(
      rawContent: '## 晚餐记录\n- 家常菜\n- 太顺杨梅',
      uiConfigs: const [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimelineCardDetailBodySection(detail: detail),
        ),
      ),
    );

    expect(
      find.textContaining('## 晚餐记录', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('- 家常菜', findRichText: true), findsOneWidget);
    expect(find.text('晚餐记录'), findsNothing);
  });

  testWidgets('ignores legacy html config and renders raw fact',
      (tester) async {
    final detail = _detail(
      rawContent: '普通正文',
      uiConfigs: const [
        UiConfig(templateId: 'legacy_html', data: {'html': ''}),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimelineCardDetailBodySection(detail: detail),
        ),
      ),
    );

    expect(find.text('普通正文'), findsOneWidget);
  });

  testWidgets('keeps tag taps working when content is selectable',
      (tester) async {
    String? tappedTag;
    final detail = _detail(
      rawContent: '',
      uiConfigs: const [],
      tags: const ['Visual'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimelineCardDetailBodySection(
            detail: detail,
            onTagTap: (tag) => tappedTag = tag,
          ),
        ),
      ),
    );

    await tester.tap(find.textContaining('#Visual', findRichText: true));

    expect(tappedTag, 'Visual');
  });
}

CardDetailModel _detail({
  required String rawContent,
  required List<UiConfig> uiConfigs,
  List<String> tags = const [],
}) {
  return CardDetailModel(
    id: '2026/06/20.md#ts_2',
    title: '端午的温馨家常晚餐和太顺杨梅',
    timestamp: DateTime(2026, 6, 20),
    address: '',
    tags: tags,
    rawContent: rawContent,
    insight: InsightData(
      text: '',
      relatedCards: const [],
      comments: const [],
    ),
    assets: const [],
    uiConfigs: uiConfigs,
  );
}
