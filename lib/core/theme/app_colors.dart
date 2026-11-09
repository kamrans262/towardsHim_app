import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF7EDDF);
  static const outlinedButtonBackground = Color(0xFFF8F0E3);
  static const primaryOrange = Color(0xFFE47821);

  // Delete Account UI-only warning tokens (other screens retain orange).
  static const warningRed = Color(0xFFE42124);
  static const warningBackground = Color(0x0DE42124); // ~5% opacity
  static const warningBorder = Color(0x1FE42124); // subtle 12% border
  static const warningIconBackground = Color(0x14E42124); // 8% tint
  static const heading = Color(0xFF1C1C1C);
  static const secondaryText = Color(0xFF8C8A8A);
  static const white = Color(0xFFFFFFFF);
  static const inputBorder = Color(0x268C8A8A);
  static const divider = Color(0x148C8A8A);
  static const backShadow = Color(0x14000000);
  static const otpBorder = Color(0x33C8C8C1);
  static const otpShadow = Color(0x08000000);

  // Home UI tokens (shared with upcoming content/listening modules).
  static const cardBorder = Color(0x14E47821);
  static const weeklyCurrentBorder = Color(0x4DE47821);
  static const podcastTile = Color(0x14E47821);
  static const meditationTile = Color(0x142870B8);
  static const prayerTile = Color(0x1443A047);
  static const progressTrack = Color(0x14E47821);
  static const navShadow = Color(0x14000000);
}
