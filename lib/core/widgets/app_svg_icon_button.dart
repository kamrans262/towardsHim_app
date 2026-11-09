import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_spacing.dart';

class AppSvgIconButton extends StatelessWidget {
  const AppSvgIconButton({
    required this.asset,
    required this.label,
    required this.onPressed,
    this.iconSize = AppSpacing.homeHeaderIcon,
    super.key,
  });

  final String asset;
  final String label;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        icon: SvgPicture.asset(
          asset,
          key: Key('header_svg_$label'),
          width: iconSize,
          height: iconSize,
          semanticsLabel: label,
        ),
      ),
    );
  }
}
