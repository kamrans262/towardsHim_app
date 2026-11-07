import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAudioProgressBar extends StatelessWidget {
  const AppAudioProgressBar({
    required this.progress,
    super.key,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return Semantics(
      label: 'Audio progress',
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 5,
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            color: AppColors.primaryOrange,
            backgroundColor: AppColors.progressTrack,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
