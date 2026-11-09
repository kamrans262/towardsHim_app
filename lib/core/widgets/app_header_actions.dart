import 'package:flutter/material.dart';

import 'app_svg_icon_button.dart';

/// Shared Home notification and profile icons. Adjacent 44px tap targets
/// keep 28px SVGs 16px apart visually without stacking another 16px gap.
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
        AppSvgIconButton(
          asset: 'assets/icons/home/profile.svg',
          label: 'Profile',
          onPressed: onProfile,
        ),
      ],
    );
  }
}
