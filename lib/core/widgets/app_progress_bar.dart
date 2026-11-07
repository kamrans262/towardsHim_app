import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Configurable progress indicator for challenge and content cards.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.progress,
    this.height = 8,
    this.semanticsLabel = 'Progress',
    super.key,
  });

  final double progress;
  final double height;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return Semantics(
      label: semanticsLabel,
      value: (value * 100).round().toString() + '%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: LinearProgressIndicator(
            value: value,
            minHeight: height,
            color: AppColors.primaryOrange,
            backgroundColor: AppColors.progressTrack,
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
  }
}
