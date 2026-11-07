import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import 'app_header_actions.dart';

/// Shared main-tab heading row, with accessible Home-style header actions.
class AppMainScreenHeader extends StatelessWidget {
  const AppMainScreenHeader({
    required this.title,
    required this.onNotifications,
    required this.onProfile,
    super.key,
  });

  final String title;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.mainScreenTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        AppHeaderActions(
          onNotifications: onNotifications,
          onProfile: onProfile,
        ),
      ],
    );
  }
}
