import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_auth_header.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_button.dart';
import 'package:towards_him_app/core/widgets/app_or_divider.dart';
import 'package:towards_him_app/core/widgets/app_social_auth_button.dart';
import 'package:towards_him_app/core/widgets/app_text_field.dart';
import 'package:towards_him_app/features/auth/presentation/screens/create_account_screen.dart';
import 'package:towards_him_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:towards_him_app/features/auth/presentation/screens/login_screen.dart';
import 'package:towards_him_app/features/onboarding/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('Login matches Figma headings, fields and shared widgets',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('WELCOME BACK'), findsOneWidget);
    expect(find.text('Sign in to continue your journey'), findsOneWidget);
    expect(find.byType(AppAuthHeader), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(AppOrDivider), findsOneWidget);
    expect(find.byType(AppSocialAuthButton), findsNWidgets(2));

    final fields = tester.widgetList<AppTextField>(find.byType(AppTextField))
        .toList();
    expect(fields.map((field) => field.label), ['E-mail', 'Password']);
    expect(fields.map((field) => field.iconAsset), [
      'assets/icons/wpf_message-outline.svg',
      'assets/icons/mingcute_lock-line.svg',
    ]);
    expect(fields.first.keyboardType, TextInputType.emailAddress);
    expect(fields.last.obscureText, isTrue);
    expect(AppTypography.heading.fontSize, 26);
    expect(AppTypography.description.fontSize, 16);
    expect(AppSpacing.screenHorizontal, 20);
    expect(AppSpacing.screenTop, 25);
    expect(AppSpacing.screenBottom, 25);
    expect(AppSpacing.passwordToForgot, 15);
    expect(AppSpacing.forgotToDivider, 25);
    expect(find.byType(AppButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Forgot Password link has exact styling and right alignment',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final forgot = find.byKey(const Key('login_forgot_password'));
    expect(forgot, findsOneWidget);
    final text = tester.widget<Text>(forgot);
    expect(text.data, 'Forgot Password ?');
    expect(text.style, AppTypography.forgotPassword);
    expect(text.style!.color, AppColors.primaryOrange);
    expect(text.style!.fontSize, 14);
    expect(text.style!.letterSpacing, -0.3);
    final textBounds = tester.getRect(forgot);
    final passwordBounds =
        tester.getRect(find.byType(AppTextField).last);
    expect(textBounds.top - passwordBounds.bottom, closeTo(15, 0.1));
    final viewportRight = tester.getRect(find.byType(Scaffold)).right;
    expect(textBounds.right, closeTo(viewportRight - 20, 1));
  });

  testWidgets('Login form uses local controllers and masks password',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.enterText(find.byType(TextField).first, 'sample@example.com');
    await tester.enterText(find.byType(TextField).last, 'secret123');
    expect(find.text('sample@example.com'), findsOneWidget);
    final password = tester.widget<TextField>(find.byType(TextField).last);
    expect(password.obscureText, isTrue);
    expect(password.controller!.text, 'secret123');
  });

  testWidgets('Welcome Login navigates; back returns to Welcome',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('Login inline link navigates to Create Account',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inline_create_account_action')), findsOneWidget);
    await tester.tap(find.byKey(const Key('inline_create_account_action')));
    await tester.pumpAndSettle();
    expect(find.byType(CreateAccountScreen), findsOneWidget);
  });

  testWidgets('Forgot Password navigates to verification UI and back',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('login_forgot_password')));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Login action is UI-only and does not authenticate',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Login will be connected after the UI phase.'),
        findsOneWidget);
  });

  testWidgets('Login actions are 25px above safe-area bottom', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    final footer = tester.getRect(find.byKey(const Key('login_bottom_actions')));
    final screen = tester.getRect(find.byType(Scaffold));
    expect(footer.bottom, closeTo(screen.bottom - AppSpacing.screenBottom, 1));
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Login is usable on ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(2));
      expect(find.byKey(const Key('login_bottom_actions')), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });
  }

  testWidgets('Login handles a simulated keyboard inset', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 260)),
        child: LoginScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byKey(const Key('login_bottom_actions')), findsOneWidget);
  });
}
