import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/app_button.dart';
import 'package:towards_him_app/core/widgets/app_auth_header.dart';
import 'package:towards_him_app/core/widgets/app_otp_input.dart';
import 'package:towards_him_app/features/auth/data/auth_repository.dart';
import 'package:towards_him_app/features/auth/presentation/screens/login_otp_screen.dart';

const challenge = LoginOtpChallenge(
  challenge: '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
  email: 'member@example.com',
  expiresInSeconds: 600,
  resendAfterSeconds: 60,
);

void main() {
  testWidgets('OTP reuses approved six boxes, centered text and bottom button', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: LoginOtpScreen(challenge: challenge)));
    expect(find.byType(AppAuthHeader), findsOneWidget);
    expect(find.text('Verify Your Account'), findsOneWidget);
    expect(find.text('Enter the 6-digit code sent to\nmember@example.com'), findsOneWidget);
    expect(find.byType(AppOtpInput), findsOneWidget);
    expect(find.byKey(const Key('otp_box_0')), findsOneWidget);

    final verify = tester.widget<AppButton>(find.byType(AppButton));
    expect(verify.label, 'Verify');
    expect(verify.onPressed, isNull);
    final footer = tester.getRect(find.byKey(const Key('login_otp_bottom_action')));
    final screen = tester.getRect(find.byType(Scaffold));
    expect(footer.bottom, closeTo(screen.bottom - AppSpacing.screenBottom, 1));
    final content = tester.getRect(find.byKey(const Key('login_otp_centered_content')));
    expect(content.center.dx, closeTo(215, 1));

    await tester.enterText(find.byKey(const Key('otp_native_input')), '123456');
    await tester.pump();
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNotNull);
  });

  testWidgets('OTP resend respects initial cooldown', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginOtpScreen(challenge: challenge)));
    expect(find.text('Resend code in 60s'), findsOneWidget);
    expect(tester.widget<TextButton>(find.byKey(const Key('login_otp_resend'))).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('OTP remains usable at ' + size.width.toString(), (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: LoginOtpScreen(challenge: challenge)));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(AppOtpInput), findsOneWidget);
      expect(find.byKey(const Key('login_otp_bottom_action')), findsOneWidget);
    });
  }
}
