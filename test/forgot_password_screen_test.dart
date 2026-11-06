import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_auth_header.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_otp_input.dart';
import 'package:towards_him_app/core/widgets/app_send_icon_button.dart';
import 'package:towards_him_app/core/widgets/app_text_field.dart';
import 'package:towards_him_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:towards_him_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Forgot Password uses shared branding and input styles',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    expect(find.byType(AppAuthHeader), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Enter your email and we’ll send you a code'),
        findsOneWidget);
    expect(find.text('Verify Your Account'), findsOneWidget);
    expect(find.text('Enter the 6-digit code sent to your email'),
        findsOneWidget);
    final email = tester.widget<AppTextField>(find.byType(AppTextField));
    expect(email.label, 'Enter your E-mail');
    expect(email.iconAsset, 'assets/icons/wpf_message-outline.svg');
    expect(email.keyboardType, TextInputType.emailAddress);
    expect(find.byType(AppSendIconButton), findsOneWidget);
    expect(find.byType(AppOtpInput), findsOneWidget);
    expect(AppTypography.heading.fontSize, 26);
    expect(AppTypography.heading.fontWeight, FontWeight.w700);
    expect(AppTypography.description.fontFamily, 'DMSans');
    expect(AppSpacing.screenHorizontal, 20);
    expect(AppSpacing.screenBottom, 25);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Email send row has 10px gap and heading 30px below',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    final emailRect = tester.getRect(find.byType(AppTextField));
    final sendRect = tester.getRect(find.byType(AppSendIconButton));
    final rowRect = tester.getRect(find.byKey(const Key('forgot_email_row')));
    final verifyRect = tester.getRect(find.text('Verify Your Account'));
    expect(sendRect.width, 48);
    expect(sendRect.height, 48);
    expect(sendRect.left - emailRect.right, closeTo(10, 0.1));
    expect(verifyRect.top - rowRect.bottom, closeTo(30, 0.1));
  });

  testWidgets('Six OTP boxes use Figma dimensions, colors and insets',
      (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    final first = tester.getRect(find.byKey(const Key('otp_box_0')));
    final last = tester.getRect(find.byKey(const Key('otp_box_5')));
    expect(first.width, 48);
    expect(first.height, 48);
    expect(first.left, closeTo(42, 0.1));
    expect(last.right, closeTo(430 - 42, 0.1));
    for (var i = 0; i < 6; i++) {
      final box = tester.widget<Container>(find.byKey(Key('otp_box_$i')));
      final style = box.decoration! as BoxDecoration;
      expect(style.color, AppColors.outlinedButtonBackground);
      expect(style.border!.top.color, AppColors.otpBorder);
      expect(style.border!.top.width, 1);
      expect(style.boxShadow!.single.color, AppColors.otpShadow);
    }
    expect(find.text('•'), findsNWidgets(6));
  });

  testWidgets('Verify is enabled only with a valid email and six digits',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    FilledButton button() => tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button().onPressed, isNull);
    expect(
      button().style!.backgroundColor!.resolve({WidgetState.disabled}),
      AppColors.secondaryText,
    );
    expect(
      button().style!.foregroundColor!.resolve({WidgetState.disabled}),
      AppColors.white,
    );
    final otp = find.byKey(const Key('otp_native_input'));
    await tester.enterText(otp, '123456');
    await tester.pump();
    expect(button().onPressed, isNull);
    expect(find.text('*'), findsNWidgets(6));
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.pump();
    expect(button().onPressed, isNotNull);
    await tester.enterText(otp, '12345');
    await tester.pump();
    expect(button().onPressed, isNull);
    await tester.enterText(otp, '123456');
    await tester.pump();
    expect(button().onPressed, isNotNull);
    await tester.tap(find.text('Verify'));
    await tester.pump();
    expect(
      find.text('Code verification will be available after the UI phase.'),
      findsOneWidget,
    );
  });

  testWidgets('OTP supports full-code paste, backspace and digit filters',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    final field = find.byKey(const Key('otp_native_input'));
    final input = tester.widget<TextField>(field);
    expect(input.keyboardType, TextInputType.number);
    expect(input.maxLength, 6);
    await tester.enterText(field, '123456');
    await tester.pump();
    expect(input.controller!.text, '123456');
    expect(find.text('*'), findsNWidgets(6));
    await tester.enterText(field, '1234');
    await tester.pump();
    expect(find.text('*'), findsNWidgets(4));
    expect(find.text('•'), findsNWidgets(2));
    await tester.enterText(field, '12a3456789');
    await tester.pump();
    expect(input.controller!.text, '123456');
  });

  testWidgets('Send is UI-only and does not enable Verify', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    await tester.tap(find.byType(AppSendIconButton));
    await tester.pump();
    expect(
      find.text(
        'Sending verification codes will be available after the UI phase.',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
  });

  testWidgets('Forgot Password route and top back return to Login',
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

  testWidgets('Back to login action navigates to Login', (tester) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: AppRoutes.forgotPassword,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('back_to_login_action')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Verify footer is 25px above bottom safe area', (tester) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    await tester.pumpAndSettle();
    final footer = tester.getRect(
      find.byKey(const Key('forgot_password_bottom_actions')),
    );
    final screen = tester.getRect(find.byType(Scaffold));
    expect(footer.bottom, closeTo(screen.bottom - AppSpacing.screenBottom, 1));
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Responsive Forgot Password ${size.width}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
      final first = tester.getRect(find.byKey(const Key('otp_box_0')));
      final sixth = tester.getRect(find.byKey(const Key('otp_box_5')));
      expect(first.width, lessThanOrEqualTo(48));
      expect(sixth.right, lessThanOrEqualTo(size.width - 20));
    });
  }

  testWidgets('Keyboard inset preserves scrolling and footer',
      (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 260)),
        child: ForgotPasswordScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byKey(const Key('forgot_password_bottom_actions')),
        findsOneWidget);
  });
}
