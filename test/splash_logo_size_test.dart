import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/toward_him_logo.dart';
import 'package:towards_him_app/features/onboarding/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Splash keeps the official logo large, not 110x67',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    final splash = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(splash.backgroundColor, AppColors.background);
    final logo = tester.widget<TowardHimLogo>(find.byType(TowardHimLogo));
    expect(logo.width, 270);
    expect(logo.height, 164);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shared logo defaults remain unchanged for Welcome and headers',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: TowardHimLogo())),
      ),
    );
    final logo = tester.widget<TowardHimLogo>(find.byType(TowardHimLogo));
    expect(logo.width, AppSpacing.logoWidth);
    expect(logo.height, AppSpacing.logoHeight);
    expect(tester.takeException(), isNull);
  });
}
