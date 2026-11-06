import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_back_button.dart';
import 'toward_him_logo.dart';

/// Shared centered brand header for authentication screens.
class AppAuthHeader extends StatelessWidget {
  const AppAuthHeader({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.logoHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(child: TowardHimLogo()),
          Align(
            alignment: Alignment.centerLeft,
            child: AppBackButton(onPressed: onBack),
          ),
        ],
      ),
    );
  }
}
