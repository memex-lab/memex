import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:memex/domain/models/dynamic_surface_model.dart';
import 'package:memex/ui/chat/widgets/agent_chat_dialog.dart';
import 'package:memex/ui/core/themes/app_colors.dart';
import 'package:memex/ui/core/widgets/html_webview_card.dart';
import 'package:memex/ui/settings/view_models/dynamic_surface_preview_viewmodel.dart';
import 'package:memex/ui/settings/widgets/dynamic_surface_webview.dart';
import 'package:memex/utils/user_storage.dart';

class DynamicSurfacePreviewScreen extends StatefulWidget {
  const DynamicSurfacePreviewScreen({
    super.key,
    required this.viewModel,
    this.isEmbedded = false,
    this.surfaceId,
  });

  final DynamicSurfacePreviewViewModel viewModel;
  final bool isEmbedded;
  final String? surfaceId;

  @override
  State<DynamicSurfacePreviewScreen> createState() =>
      _DynamicSurfacePreviewScreenState();
}

class _DynamicSurfacePreviewScreenState
    extends State<DynamicSurfacePreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final surfaceId = widget.surfaceId;
      if (surfaceId == null) {
        widget.viewModel.loadSurfaces();
      } else {
        widget.viewModel.renderSurface(surfaceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.surfaceId == null
        ? _DynamicSurfaceBrowser(viewModel: widget.viewModel)
        : _EmbeddedDynamicSurface(
            viewModel: widget.viewModel,
            surfaceId: widget.surfaceId!,
            isEmbedded: widget.isEmbedded,
          );

    if (widget.isEmbedded) {
      return ColoredBox(
        color: AppColors.background,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _DynamicSurfaceAppBar(
        viewModel: widget.viewModel,
      ),
      body: body,
    );
  }
}

class _DynamicSurfaceBrowser extends StatelessWidget {
  const _DynamicSurfaceBrowser({required this.viewModel});

  final DynamicSurfacePreviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (viewModel.errorMessage != null) ...[
              _ErrorPanel(message: viewModel.errorMessage!),
              const SizedBox(height: 16),
            ],
            _SurfaceList(
              surfaces: viewModel.surfaces,
              isRendering: viewModel.isRendering,
              selectedId: viewModel.renderResult?.surface.id,
              onSelect: viewModel.renderSurface,
              onDelete: (surface) => _confirmDeleteSurface(context, surface),
            ),
            const SizedBox(height: 20),
            if (viewModel.renderResult != null)
              _RenderedSurface(result: viewModel.renderResult!)
            else
              const _EmptyPreview(),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteSurface(
    BuildContext context,
    DynamicSurfaceModel surface,
  ) async {
    final l10n = UserStorage.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirm),
        content: Text(l10n.deleteConfirmMessage(surface.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.uninstallSurface(surface.id);
    }
  }
}

class _EmbeddedDynamicSurface extends StatelessWidget {
  const _EmbeddedDynamicSurface({
    required this.viewModel,
    required this.surfaceId,
    required this.isEmbedded,
  });

  final DynamicSurfacePreviewViewModel viewModel;
  final String surfaceId;
  final bool isEmbedded;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final result = viewModel.renderResult;
        final hasCurrentSurface = result?.surface.id == surfaceId;

        if ((viewModel.isLoading || viewModel.isRendering) &&
            !hasCurrentSurface) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (viewModel.errorMessage != null) ...[
                    _ErrorPanel(message: viewModel.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  if (hasCurrentSurface)
                    Expanded(
                      child: result!.contentType == 'html'
                          ? DynamicSurfaceWebView(
                              html: result.content,
                              bottomContentInset: isEmbedded
                                  ? _embeddedBottomContentInset(context)
                                  : 0,
                            )
                          : _RenderedSurface(
                              result: result,
                              showDataPreview: false,
                            ),
                    )
                  else
                    const Expanded(child: _EmptyPreview()),
                ],
              ),
            ),
            if (isEmbedded && hasCurrentSurface)
              Positioned(
                right: 20,
                bottom: _embeddedFloatingButtonBottom(context),
                child: _FloatingSurfaceUpdateButton(
                  isBusy: viewModel.isRendering,
                  onPressed: () =>
                      viewModel.requestAgentRefresh(surfaceId: surfaceId),
                ),
              ),
          ],
        );
      },
    );
  }

  double _embeddedFloatingButtonBottom(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 132;
  }

  double _embeddedBottomContentInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 192;
  }
}

class _FloatingSurfaceUpdateButton extends StatelessWidget {
  const _FloatingSurfaceUpdateButton({
    required this.isBusy,
    required this.onPressed,
  });

  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: isBusy ? 0.72 : 1,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B6CFF), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B6CFF).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: isBusy ? null : onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBusy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Colors.white,
                ),
              const SizedBox(width: 10),
              Text(
                isBusy ? UserStorage.l10n.updating : UserStorage.l10n.update,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DynamicSurfaceAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _DynamicSurfaceAppBar({required this.viewModel});

  final DynamicSurfacePreviewViewModel viewModel;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = UserStorage.l10n;
    return AppBar(
      title: Text(l10n.customPages),
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      foregroundColor: Colors.black,
      elevation: 0.5,
      actions: [
        TextButton.icon(
          onPressed: () => _openAuthorChat(context),
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: Text(l10n.designPage),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          tooltip: l10n.runPageAgent,
          icon: const Icon(Icons.smart_toy_outlined),
          onPressed: viewModel.requestAgentRefresh,
        ),
        IconButton(
          tooltip: l10n.reload,
          icon: const Icon(Icons.refresh),
          onPressed: viewModel.loadSurfaces,
        ),
      ],
    );
  }

  void _openAuthorChat(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        final l10n = UserStorage.l10n;
        return AgentChatDialog(
          agentName: DynamicSurfacePreviewViewModel.authorAgentName,
          title: l10n.pageDesigner,
          inputHint: l10n.dynamicSurfaceAuthorInputHint,
          scene: 'dynamic_surface_author',
        );
      },
    );
  }
}

class _SurfaceList extends StatelessWidget {
  const _SurfaceList({
    required this.surfaces,
    required this.isRendering,
    required this.selectedId,
    required this.onSelect,
    required this.onDelete,
  });

  final List<DynamicSurfaceModel> surfaces;
  final bool isRendering;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final ValueChanged<DynamicSurfaceModel> onDelete;

  @override
  Widget build(BuildContext context) {
    if (surfaces.isEmpty) {
      return _Panel(
        child: Text(
          UserStorage.l10n.customPagesEmpty,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: surfaces.map((surface) {
        final selected = surface.id == selectedId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isRendering ? null : () => onSelect(surface.id),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        selected ? AppColors.primary : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.dashboard_customize_outlined,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surface.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${surface.id} · ${surface.source.type} · ${surface.parser.type}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isRendering && selected)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: UserStorage.l10n.delete,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.textTertiary,
                            ),
                            onPressed:
                                isRendering ? null : () => onDelete(surface),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RenderedSurface extends StatelessWidget {
  const _RenderedSurface({
    required this.result,
    this.showDataPreview = true,
  });

  final DynamicSurfaceRenderResult result;
  final bool showDataPreview;

  @override
  Widget build(BuildContext context) {
    if (!showDataPreview && result.contentType == 'html') {
      return HtmlWebViewCard(
        html: result.content,
        config: const HtmlWebViewConfig(
          initialHeight: 360,
          minHeightThreshold: 120,
          maxHeight: 1200,
          showContainerDecoration: true,
          borderRadius: 8,
          backgroundColor: Colors.white,
          borderColor: Color(0xFFE5E7EB),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDataPreview) ...[
          _Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.surface.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.contentType} · ${_dataShapeLabel(result.data)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  const JsonEncoder.withIndent('  ').convert(result.data),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (result.contentType == 'html')
          HtmlWebViewCard(
            html: result.content,
            config: const HtmlWebViewConfig(
              initialHeight: 360,
              minHeightThreshold: 120,
              maxHeight: 1200,
              showContainerDecoration: true,
              borderRadius: 8,
              backgroundColor: Colors.white,
              borderColor: Color(0xFFE5E7EB),
            ),
          )
        else
          _Panel(
            child: MarkdownBody(data: result.content),
          ),
      ],
    );
  }

  String _dataShapeLabel(Object? data) {
    if (data is List) return '${data.length} items';
    if (data is Map) return '${data.length} fields';
    if (data == null) return 'null';
    if (data is String) return 'string';
    if (data is num) return 'number';
    if (data is bool) return 'boolean';
    return data.runtimeType.toString();
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Text(
        UserStorage.l10n.customPagesPreviewEmpty,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}
