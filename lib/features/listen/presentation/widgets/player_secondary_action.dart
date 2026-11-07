import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class PlayerSecondaryAction extends StatelessWidget {
  const PlayerSecondaryAction({
    required this.label,
    required this.onPressed,
    this.svgAsset,
    this.pngAsset,
    super.key,
  }) : assert(svgAsset != null || pngAsset != null);

  final String label;
  final String? svgAsset;
  final String? pngAsset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('player_action_${label.toLowerCase()}'),
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (svgAsset case final asset?)
              SvgPicture.asset(
                asset,
                width: AppSpacing.playerControlIcon,
                height: AppSpacing.playerControlIcon,
              )
            else
              Image.asset(
                pngAsset!,
                width: AppSpacing.playerControlIcon,
                height: AppSpacing.playerControlIcon,
              ),
            const SizedBox(height: AppSpacing.playerActionLabelGap),
            Text(
              label,
              style: AppTypography.quickAccessLabel,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
