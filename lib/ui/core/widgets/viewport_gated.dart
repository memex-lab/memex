import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Builds [builder] only after this widget intersects the nearest scroll
/// viewport. Used to keep off-screen Timeline WebViews from mounting.
class ViewportGated extends StatefulWidget {
  const ViewportGated({
    super.key,
    required this.placeholder,
    required this.builder,
    this.cacheExtent = 400,
    this.keepAlive = true,
  });

  final Widget placeholder;
  final WidgetBuilder builder;
  final double cacheExtent;
  final bool keepAlive;

  @override
  State<ViewportGated> createState() => _ViewportGatedState();
}

class _ViewportGatedState extends State<ViewportGated> {
  bool _activated = false;
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_evaluate);
      _position = position;
      _position?.addListener(_evaluate);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  @override
  void dispose() {
    _position?.removeListener(_evaluate);
    super.dispose();
  }

  void _evaluate() {
    if (!mounted || (_activated && widget.keepAlive)) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        !renderObject.attached) {
      return;
    }
    final viewport = RenderAbstractViewport.maybeOf(renderObject);
    if (viewport == null) {
      if (_position == null) _activate();
      return;
    }
    if (viewport is! RenderBox) return;
    final viewportBox = viewport as RenderBox;
    if (!viewportBox.hasSize) return;
    final offset = renderObject.localToGlobal(
      Offset.zero,
      ancestor: viewportBox,
    );
    final itemRect = offset & renderObject.size;
    final visibleRect =
        (Offset.zero & viewportBox.size).inflate(widget.cacheExtent);
    if (itemRect.overlaps(visibleRect)) {
      _activate();
    }
  }

  void _activate() {
    if (_activated) return;
    setState(() => _activated = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_activated) return widget.placeholder;
    return widget.builder(context);
  }
}
