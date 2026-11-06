import 'dart:ui' show FontVariation;

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const heading = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    height: 1,
    letterSpacing: 0,
    color: AppColors.heading,
  );

  static const description = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    letterSpacing: 0,
    color: AppColors.secondaryText,
  );

  static const button = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    letterSpacing: 0,
  );

  static const guest = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    letterSpacing: -0.3,
    color: AppColors.secondaryText,
  );
}
