import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

enum PlayerSkipDirection { backward, forward }

/// Shared rewind/forward control, with orange press-state feedback.
class PlayerSkipButton extends StatefulWidget {
  const PlayerSkipButton({
    required this.direction,
    required this.onPressed,
    super.key,
  });

  final PlayerSkipDirection direction;
  final VoidCallback onPressed;

  @override
  State<PlayerSkipButton> createState() => _PlayerSkipButtonState();
}

class _PlayerSkipButtonState extends State<PlayerSkipButton> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final backward = widget.direction == PlayerSkipDirection.backward;
    return SizedBox(
      width: AppSpacing.playerSkipTapSize,
      height: AppSpacing.playerSkipTapSize,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: Key(backward ? 'player_rewind' : 'player_forward'),
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onPressed,
          onHighlightChanged: (pressed) {
            if (mounted) setState(() => _highlighted = pressed);
          },
          child: Tooltip(
            message: backward ? 'Rewind 10 seconds' : 'Forward 10 seconds',
            child: Center(
              child: SvgPicture.asset(
                backward
                    ? 'assets/icons/player/rewind_10_seconds.svg'
                    : 'assets/icons/player/forward_10_seconds.svg',
                width: AppSpacing.playerControlIcon,
                height: AppSpacing.playerControlIcon,
                colorFilter: ColorFilter.mode(
                  _highlighted
                      ? AppColors.primaryOrange
                      : AppColors.secondaryText,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
