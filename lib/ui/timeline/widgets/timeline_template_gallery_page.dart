import 'package:flutter/material.dart';
import 'package:memex/l10n/template_gallery_l10n.dart';
import 'package:memex/ui/core/cards/native_card_factory.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/back_button.dart';

/// Timeline 卡片模板展示页面
/// 展示所有支持的 Timeline 卡片模板及示例数据
class TimelineTemplateGalleryPage extends StatelessWidget {
  const TimelineTemplateGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = UserStorage.l10n.timelineTemplateGallerySections;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UserStorage.l10n.timelineTemplateGalleryTitle,
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0A0A),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: const AppBackButton(),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final section in sections) ...[
            _buildCategoryHeader(section.title),
            for (final item in section.items) _buildTemplateItem(context, item),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTemplateItem(BuildContext context, TemplateGalleryItem item) {
    if (item.wrapped) {
      return _buildWrappedSection(
        context,
        item.label,
        item.templateId,
        item.data,
        title: item.title,
      );
    }
    return _buildSection(
      context,
      item.label,
      item.templateId,
      item.data,
      title: item.title,
    );
  }

  /// 分类标题
  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  /// 普通卡片区块
  Widget _buildSection(
    BuildContext context,
    String label,
    String templateId,
    Map<String, dynamic> data, {
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5565),
            ),
          ),
        ),
        NativeCardFactory.build(
          templateId: templateId,
          data: data,
          title: title,
          status: 'completed',
          onTap: () => _openPreview(context, templateId, data, title),
        ),
      ],
    );
  }

  /// 带背景包装的卡片区块（用于自身没有背景的 compact_card 等）
  Widget _buildWrappedSection(
    BuildContext context,
    String label,
    String templateId,
    Map<String, dynamic> data, {
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5565),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _openPreview(context, templateId, data, title),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: NativeCardFactory.build(
              templateId: templateId,
              data: data,
              title: title,
              status: 'completed',
            ),
          ),
        ),
      ],
    );
  }

  void _openPreview(BuildContext context, String templateId,
      Map<String, dynamic> data, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TemplatePreviewPage(
          templateId: templateId,
          data: data,
          title: title,
        ),
      ),
    );
  }
}

/// 卡片模板预览详情页 — 模拟详情页布局
class _TemplatePreviewPage extends StatelessWidget {
  final String templateId;
  final Map<String, dynamic> data;
  final String title;

  const _TemplatePreviewPage({
    required this.templateId,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppBackButton(),
                  Text(
                    templateId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF99A1AF),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    if (title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'PingFang SC',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0A0A),
                            height: 1.375,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                    // Tags
                    if (tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Wrap(
                          spacing: 8,
                          children: tags
                              .map((t) => Text(
                                    '#$t',
                                    style: const TextStyle(
                                      fontFamily: 'PingFang SC',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF5B6CFF),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    // Card
                    NativeCardFactory.build(
                      templateId: templateId,
                      data: data,
                      title: title,
                      status: 'completed',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
