import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_audio_progress_bar.dart';

/// Interactive variant of the shared 5px Home progress indicator.
///
/// The larger transparent hit target permits precise seeking while the
/// visible track remains exactly 5px high. No audio backend is involved.
class AppAudioSeekBar extends StatelessWidget {
  const AppAudioSeekBar({
    required this.progress,
    required this.onChanged,
    super.key,
  });

  final double progress;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        void seek(double localDx) {
          if (constraints.maxWidth <= 0) return;
          onChanged((localDx / constraints.maxWidth).clamp(0.0, 1.0));
        }

        return Semantics(
          slider: true,
          label: 'Playback position',
          value: '${(value * 100).round()} percent',
          onIncrease: () => onChanged((value + 0.05).clamp(0.0, 1.0)),
          onDecrease: () => onChanged((value - 0.05).clamp(0.0, 1.0)),
          child: GestureDetector(
            key: const Key('player_seek_bar'),
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => seek(details.localPosition.dx),
            onHorizontalDragUpdate: (details) =>
                seek(details.localPosition.dx),
            child: SizedBox(
              height: AppSpacing.playerSeekTouchHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(child: SizedBox()),
                  Center(child: AppAudioProgressBar(progress: value)),
                  Positioned(
                    left: (constraints.maxWidth - AppSpacing.playerThumbSize) *
                        value,
                    top: (AppSpacing.playerSeekTouchHeight -
                            AppSpacing.playerThumbSize) /
                        2,
                    child: const DecoratedBox(
                      key: Key('player_progress_thumb'),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: AppSpacing.playerThumbSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
