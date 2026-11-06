import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_button.dart';
import 'package:towards_him_app/core/widgets/app_or_divider.dart';
import 'package:towards_him_app/core/widgets/app_social_auth_button.dart';
import 'package:towards_him_app/core/widgets/app_text_field.dart';
import 'package:towards_him_app/features/auth/presentation/screens/create_account_screen.dart';
import 'package:towards_him_app/features/auth/presentation/screens/login_screen.dart';
import 'package:towards_him_app/features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('Create Account fields, icons and action styles match Figma',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateAccountScreen()),
    );
    final fields = tester.widgetList<AppTextField>(find.byType(AppTextField))
        .toList();
    expect(fields.map((field) => field.label), [
      'Full Name',
      'E-mail',
      'Password',
      'Confirm Password',
    ]);
    expect(fields.map((field) => field.iconAsset), [
      'assets/icons/iconamoon_profile-light.svg',
      'assets/icons/wpf_message-outline.svg',
      'assets/icons/mingcute_lock-line.svg',
      'assets/icons/mingcute_lock-line.svg',
    ]);
    expect(fields[0].keyboardType, TextInputType.name);
    expect(fields[1].keyboardType, TextInputType.emailAddress);
    expect(fields[2].obscureText, isTrue);
    expect(fields[3].obscureText, isTrue);
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(AppOrDivider), findsOneWidget);
    expect(find.byType(AppSocialAuthButton), findsNWidgets(2));
    expect(find.byType(AppButton), findsOneWidget);
    expect(AppTypography.inputPlaceholder.fontFamily, 'DMSans');
    expect(AppTypography.inputPlaceholder.fontSize, 14);
    expect(AppTypography.inputPlaceholder.color, AppColors.secondaryText);
    expect(AppSpacing.fieldGap, 20);
    expect(AppSpacing.fieldIconGap, 12);
    expect(AppSpacing.screenBottom, 25);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Local text field controllers accept entries', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateAccountScreen()),
    );
    await tester.enterText(find.byType(TextField).first, 'Taylor Smith');
    expect(find.text('Taylor Smith'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    expect(find.text('test@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Create Account opens from Welcome and back returns',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateAccountScreen), findsOneWidget);
    expect(find.text('Create Your Account'), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('Log In from Create Account opens Login UI',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.createAccount,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.pumpAndSettle();
    expect(find.byType(CreateAccountScreen), findsOneWidget);
    expect(find.byKey(const Key('inline_login_action')), findsOneWidget);
    await tester.tap(find.byKey(const Key('inline_login_action')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Bottom Create Account action ends 25px above safe-area bottom',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: CreateAccountScreen()));
    await tester.pumpAndSettle();
    final bounds =
        tester.getRect(find.byKey(const Key('create_account_bottom_actions')));
    final screen = tester.getRect(find.byType(Scaffold));
    expect(bounds.bottom, closeTo(screen.bottom - AppSpacing.screenBottom, 1));
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Create Account scrolls without overflow at ${size.width}×${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: CreateAccountScreen()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AppTextField), findsNWidgets(4));
      await tester.ensureVisible(find.text('Create Account'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
