import 'package:flutter/material.dart';
import 'package:memex/ui/core/cards/native_widget_factory.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/ui/core/widgets/back_button.dart';

class InsightTemplateGalleryPage extends StatelessWidget {
  const InsightTemplateGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = UserStorage.l10n.insightTemplateGalleryItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          UserStorage.l10n.insightTemplateGalleryTitle,
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
          for (final item in items)
            _buildSection(item.label, item.templateId, item.data),
        ],
      ),
    );
  }

  Widget _buildSection(
      String label, String templateId, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 22),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5565),
            ),
          ),
        ),
        NativeWidgetFactory.build(templateId, data) ??
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.red.shade50,
              child: Text('Failed to build $templateId'),
            ),
      ],
    );
  }
}
