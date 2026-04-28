import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memex/data/repositories/memex_router.dart';
import 'package:memex/domain/models/insight_detail_model.dart';
import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/ui/core/cards/native_widget_factory.dart';
import 'package:memex/ui/timeline/widgets/timeline_card_detail_screen.dart';
import 'package:memex/utils/toast_helper.dart';
import 'package:memex/ui/core/widgets/detail_page_layout.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/utils/share_service.dart';
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';
import 'package:memex/ui/core/widgets/back_button.dart';

/// Unified AI Insight detail page
class InsightDetailPage extends StatefulWidget {
  final String id;

  const InsightDetailPage({
    super.key,
    required this.id,
  });

  /// Factory constructor for insight
  factory InsightDetailPage.insight({required String insightId}) {
    return InsightDetailPage(
      id: insightId,
    );
  }

  @override
  State<InsightDetailPage> createState() => _InsightDetailPageState();
}

class _InsightDetailPageState extends State<InsightDetailPage> {
  InsightDetailModel? _insightDetail;
  bool _isLoading = true;
  String? _errorMessage;
  late final MemexRouter _memexRouter;

  @override
  void initState() {
    super.initState();
    _memexRouter = MemexRouter();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _memexRouter.fetchInsightDetail(widget.id);
      if (!mounted) return;
      setState(() {
        _insightDetail = detail;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = UserStorage.l10n.loadDetailFailedRetry;
      });
      ToastHelper.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Get metadata
  InsightMetadataModel? get _metadata {
    return _insightDetail?.insight;
  }

  // Get content
  String get _content {
    return _insightDetail?.content ?? '';
  }

  Widget _buildInsightMarkdown(String content, TextStyle style) {
    return MarkdownBody(
      data: content,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: style,
        strong: style.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
        em: style.copyWith(fontStyle: FontStyle.italic),
        listBullet: style.copyWith(color: const Color(0xFF5B6CFF)),
        code: TextStyle(
          fontSize: (style.fontSize ?? 14) - 1,
          color: const Color(0xFF334155),
          backgroundColor: const Color(0xFFF7F8FA),
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Get related cards
  List<RelatedCardModel> get _relatedCards {
    return _insightDetail?.relatedCards ?? [];
  }

  Future<void> _shareInsight() async {
    if (_metadata == null) return;
    ToastHelper.showInfo(context, UserStorage.l10n.processingEllipsis);

    final shareWidget = Container(
      width: 400,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: 390, // Standard mobile width to ensure matching layout
            child: _insightDetail?.widgetType == 'native' &&
                    _insightDetail?.widgetTemplate != null
                ? NativeWidgetFactory.build(
                    _insightDetail!.widgetTemplate!,
                    Map<String, dynamic>.from(_insightDetail!.widgetData ?? {})
                      ..addAll({
                        'title': _metadata?.title,
                        'insight': _content,
                        if (_relatedCards.isNotEmpty)
                          'related_fact_ids':
                              _relatedCards.map((c) => c.id).toList(),
                      }),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await ShareService.shareWidgetAsPoster(context, shareWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: AgentLogoLoading()),
      );
    }

    if (_errorMessage != null || _metadata == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const AppBackButton(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Color(0xFF99A1AF)),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? UserStorage.l10n.loadFailed,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF99A1AF),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetail,
                child: Text(UserStorage.l10n.reload),
              ),
            ],
          ),
        ),
      );
    }

    final metadata = _metadata!;

    return DetailPageLayout(
      title: metadata.title,
      icon: metadata.icon,
      type: metadata.type,
      subTitle: UserStorage.l10n.aiInsightDetail,
      actions: [
        GestureDetector(
          onTap: _shareInsight,
          child: SvgPicture.asset(
            'assets/icons/btn_share.svg',
            width: 36,
            height: 36,
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content text
          if (_insightDetail?.widgetType == 'native' &&
              _insightDetail?.widgetTemplate != null &&
              _insightDetail?.widgetData != null) ...[
            NativeWidgetFactory.buildDetail(
                  _insightDetail!.widgetTemplate!,
                  _insightDetail!.widgetData!,
                ) ??
                const SizedBox.shrink(),

            // Insight comment below card
            if (_content.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Color(0xFF5B6CFF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInsightMarkdown(
                        _content,
                        GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF4A5565),
                          height: 1.6,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ] else if (_content.isNotEmpty) ...[
            _buildInsightMarkdown(
              _content,
              const TextStyle(
                fontSize: 17,
                color: Color(0xFF334155), // Slate-700
                height: 1.7,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Related cards section
          if (_relatedCards.isNotEmpty) ...[
            Text(
              UserStorage.l10n.relatedRecordsCount(_relatedCards.length),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 16),
            ..._relatedCards.map((card) {
              void onTap() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimelineCardDetailScreen(
                      cardId: card.id,
                    ),
                  ),
                );
              }

              return _RelatedCardItem(
                card: card,
                onTap: onTap,
              );
            }),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  UserStorage.l10n.noRelatedRecords,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RelatedCardItem extends StatelessWidget {
  final RelatedCardModel card;
  final VoidCallback onTap;

  const _RelatedCardItem({
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Only show native cards
    final displayConfigs = card.uiConfigs;

    if (displayConfigs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: displayConfigs.map((config) {
          if (config.templateId == 'legacy_html') {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: NativeCardFactory.build(
              status: card.status,
              templateId: config.templateId,
              data: config.data,
              title: card.title ?? '',
              tags: card.tags,
              onTap: onTap,
            ),
          );
        }).toList(),
      ),
    );
  }
}
