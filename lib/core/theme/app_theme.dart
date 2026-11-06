import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryOrange,
          surface: AppColors.background,
          onSurface: AppColors.heading,
          onPrimary: AppColors.white,
        ),
        textTheme: const TextTheme(
          headlineLarge: AppTypography.heading,
          bodyMedium: AppTypography.description,
        ),
        splashColor: AppColors.primaryOrange.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
      );
}
