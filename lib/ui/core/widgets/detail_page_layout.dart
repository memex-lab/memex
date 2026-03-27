import 'package:flutter/material.dart';
import 'package:memex/utils/user_storage.dart';
import 'icon_helper.dart';

class DetailPageLayout extends StatelessWidget {
  final String title;
  final String icon;
  final String? type;
  final Widget child;
  final String subTitle;
  final List<Widget>? actions;

  const DetailPageLayout({
    super.key,
    required this.title,
    required this.icon,
    this.type,
    required this.child,
    this.subTitle = '',
    this.actions,
  });

  Color _getIconBgColor(String? type) {
    if (type == 'alert') return const Color(0xFFFFE4E6);
    return const Color(0xFFEEF0FF);
  }

  Color _getIconColor(String? type) {
    if (type == 'alert') return const Color(0xFFE11D48);
    return const Color(0xFF5B6CFF);
  }

  @override
  Widget build(BuildContext context) {
    final iconBgColor = _getIconBgColor(type);
    final iconColor = _getIconColor(type);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, topPadding + 48, 24, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: IconHelper.getIcon(icon,
                              size: 20, color: iconColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subTitle.isEmpty
                                  ? UserStorage.l10n.detailSubtitle
                                  : subTitle,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF99A1AF),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A0A0A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  child: child,
                ),
              ),
            ],
          ),

          // Top actions and close button
          Positioned(
            top: topPadding + 8,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actions != null) ...actions!,
                if (actions != null) const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child:
                        Icon(Icons.close, size: 20, color: Color(0xFF4A5565)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
