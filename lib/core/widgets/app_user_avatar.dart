
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared circular user portrait used by Community, Replies and Profile.
class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({
    required this.asset,
    this.size = 48,
    super.key,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => const ColoredBox(
            color: AppColors.podcastTile,
            child: Icon(
              Icons.person_outline_rounded,
              size: 24,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }
}
