import 'package:flutter/material.dart';

/// A text field with a dropdown button that shows all options.
/// Typing filters the options; tapping the dropdown always shows all.
class SearchableDropdown extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;

  /// Optional builder for each option row (e.g. to add badges).
  final Widget Function(String option, bool isHighlighted)? optionBuilder;

  const SearchableDropdown({
    super.key,
    required this.options,
    this.initialValue,
    required this.onChanged,
    this.decoration,
    this.validator,
    this.optionBuilder,
  });

  @override
  State<SearchableDropdown> createState() => SearchableDropdownState();
}

class SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filtered = [];
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _filtered = widget.options;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options != widget.options) {
      _updateFiltered();
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _updateFiltered();
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _updateFiltered() {
    final query = _controller.text.toLowerCase();
    setState(() {
      if (_showAll || query.isEmpty) {
        _filtered = widget.options;
      } else {
        _filtered = widget.options
            .where((o) => o.toLowerCase().contains(query))
            .toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: _filtered.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final option = _filtered[i];
                        return InkWell(
                          onTap: () => _selectOption(option),
                          child: widget.optionBuilder != null
                              ? widget.optionBuilder!(option, false)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Text(option),
                                ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectOption(String option) {
    _controller.text = option;
    _controller.selection = TextSelection.collapsed(offset: option.length);
    _showAll = false;
    widget.onChanged(option);
    _focusNode.unfocus();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onDropdownTap() {
    _showAll = true;
    _filtered = widget.options;
    if (_focusNode.hasFocus) {
      _overlayEntry?.markNeedsBuild();
    } else {
      _focusNode.requestFocus();
    }
  }

  /// Allow parent to update the text programmatically.
  void setText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration =
        (widget.decoration ?? const InputDecoration()).copyWith(
      suffixIcon: IconButton(
        icon: const Icon(Icons.arrow_drop_down),
        onPressed: _onDropdownTap,
      ),
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: effectiveDecoration,
        validator: widget.validator,
        onChanged: (value) {
          _showAll = false;
          widget.onChanged(value);
          _updateFiltered();
        },
      ),
    );
  }
}
