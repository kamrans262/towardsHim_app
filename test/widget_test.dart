import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:towards_him_app/app/toward_him_app.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_button.dart';
import 'package:towards_him_app/core/widgets/toward_him_logo.dart';
import 'package:towards_him_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:towards_him_app/features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('Splash shows the exact centered 110×67 logo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.byType(TowardHimLogo), findsOneWidget);
    final center = tester.getCenter(find.byType(TowardHimLogo));
    final screenCenter = tester.getCenter(find.byType(Scaffold));
    expect(center.dx, closeTo(screenCenter.dx, 0.01));
    expect(center.dy, closeTo(screenCenter.dy, 0.01));
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 110);
    expect(svg.height, 67);
  });

  testWidgets('Splash moves to Welcome and does not show counter UI',
      (tester) async {
    await tester.pumpWidget(const TowardHimApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Welcome to Toward HIM'), findsOneWidget);
    expect(find.text('You have pushed the button this many times:'),
        findsNothing);
  });

  testWidgets('Welcome applies Figma typography and button dimensions',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WelcomeScreen(),
    ));
    expect(find.text('Welcome to Toward HIM'), findsOneWidget);
    expect(find.text(WelcomeScreen.description), findsOneWidget);
    expect(AppTypography.heading.fontFamily, 'PlayfairDisplay');
    expect(AppTypography.heading.fontSize, 26);
    expect(AppTypography.heading.fontWeight, FontWeight.w700);
    expect(AppTypography.description.fontFamily, 'DMSans');
    expect(AppTypography.description.fontSize, 16);
    expect(AppTypography.description.color, AppColors.secondaryText);
    final buttons = tester.widgetList<AppButton>(find.byType(AppButton)).toList();
    expect(buttons.map((button) => button.variant), [
      AppButtonVariant.outlined,
      AppButtonVariant.filled,
    ]);
    for (final button in buttons) {
      expect(AppSpacing.buttonHeight, 50);
      expect(button.label.isNotEmpty, isTrue);
    }
  });

  testWidgets('Welcome actions call UI navigation hooks', (tester) async {
    var createPressed = false;
    var loginPressed = false;
    var guestPressed = false;
    await tester.pumpWidget(MaterialApp(
      home: WelcomeScreen(
        onCreateAccount: () => createPressed = true,
        onLogin: () => loginPressed = true,
        onContinueAsGuest: () => guestPressed = true,
      ),
    ));
    await tester.tap(find.text('Create Account'));
    await tester.tap(find.text('Login'));
    await tester.tap(find.textContaining('continue as Guest'));
    expect(createPressed, isTrue);
    expect(loginPressed, isTrue);
    expect(guestPressed, isTrue);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Welcome remains usable at ${size.width}×${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AppButton), findsNWidgets(2));
      expect(find.text('Welcome to Toward HIM'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  }
}
