import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_svg_icon_button.dart';

/// Reuses the exact Home notification and profile icons across main tabs.
class AppHeaderActions extends StatelessWidget {
  const AppHeaderActions({
    required this.onNotifications,
    required this.onProfile,
    super.key,
  });

  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSvgIconButton(
          asset: 'assets/icons/home/notification.svg',
          label: 'Notifications',
          onPressed: onNotifications,
        ),
        const SizedBox(width: AppSpacing.homeHeaderIconGap),
        AppSvgIconButton(
          asset: 'assets/icons/home/profile.svg',
          label: 'Profile',
          onPressed: onProfile,
        ),
      ],
    );
  }
}
