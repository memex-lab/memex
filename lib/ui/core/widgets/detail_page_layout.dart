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

  Color _getHeaderColor(String? type) {
    if (type == 'alert') {
      return const Color(0xFFE11D48);
    }
    return const Color(0xFF6366F1);
  }

  Color _getIconBgColor(String? type) {
    if (type == 'alert') {
      return const Color(0xFFFFE4E6);
    }
    return const Color(0xFFE0E7FF);
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _getHeaderColor(type);
    final iconBgColor = _getIconBgColor(type);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 100,
                pinned: false,
                leading: const SizedBox.shrink(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: headerColor,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Header content overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
                                    child: IconHelper.getIcon(
                                      icon,
                                      size: 20,
                                      color: headerColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        subTitle.isEmpty ? UserStorage.l10n.detailSubtitle : subTitle,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Top actions and close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actions != null) ...actions!,
                if (actions != null) const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
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
