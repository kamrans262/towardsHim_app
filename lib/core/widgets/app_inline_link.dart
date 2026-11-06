import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppInlineLink extends StatelessWidget {
  const AppInlineLink({
    required this.message,
    required this.action,
    required this.onPressed,
    this.actionKey = const Key('inline_login_action'),
    super.key,
  });

  final String message;
  final String action;
  final VoidCallback onPressed;
  final Key actionKey;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(message, style: AppTypography.description),
        Semantics(
          button: true,
          label: action,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: Text(
              action,
              key: actionKey,
              style: AppTypography.description.copyWith(
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
