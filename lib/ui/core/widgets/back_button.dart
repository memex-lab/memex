import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Back button using btn_back.svg from Figma design.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: SvgPicture.asset(
        'assets/icons/btn_back.svg',
        width: 36,
        height: 36,
      ),
    );
  }
}
