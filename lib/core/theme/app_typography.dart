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

  static const inputPlaceholder = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    letterSpacing: -0.3,
    color: AppColors.secondaryText,
  );

  static const inputValue = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    letterSpacing: -0.3,
    color: AppColors.heading,
  );

  static const socialButton = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    letterSpacing: -0.3,
    color: AppColors.heading,
  );

  static const forgotPassword = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    letterSpacing: -0.3,
    color: AppColors.primaryOrange,
  );

  static const otpCharacter = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
  );

  static const homeGreeting = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 26,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    color: AppColors.heading,
  );
  static const homeGreetingName = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    height: 1,
    color: AppColors.heading,
  );
  static const homeScripture = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    height: 1.25,
    color: AppColors.heading,
  );
  static const sectionHeading = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    height: 1,
    color: AppColors.heading,
  );
  static const cardTitle = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    height: 1.18,
    color: AppColors.heading,
  );
  static const featuredTitle = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    height: 1.15,
    color: AppColors.heading,
  );
  static const homeSecondary = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1.25,
    color: AppColors.secondaryText,
  );
  static const homeAccent = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1.15,
    color: AppColors.primaryOrange,
  );
  static const quickAccessLabel = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
    color: AppColors.heading,
  );
  static const mainScreenTitle = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    height: 1,
    letterSpacing: 0,
    color: AppColors.heading,
  );

  static const navigationLabel = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    height: 1,
  );
}
