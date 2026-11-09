import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_spacing.dart';

class TowardHimLogo extends StatelessWidget {
  const TowardHimLogo({
    this.width = AppSpacing.logoWidth,
    this.height = AppSpacing.logoHeight,
    super.key,
  });

  final double width;
  final double height;

  static const assetPath = 'assets/branding/toward_him_logo.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticsLabel: 'Toward HIM',
    );
  }
}
