import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_spacing.dart';

class TowardHimLogo extends StatelessWidget {
  const TowardHimLogo({super.key});

  static const assetPath = 'assets/branding/toward_him_logo.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: AppSpacing.logoWidth,
      height: AppSpacing.logoHeight,
      fit: BoxFit.contain,
      semanticsLabel: 'Toward HIM',
    );
  }
}
