import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/toward_him_logo.dart';
import 'package:towards_him_app/features/onboarding/presentation/screens/splash_screen.dart';

void main() {
  test('Android callback manifest path is valid for AAPT resource linking', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:scheme="signinwithapple"'));
    expect(manifest, contains('android:path="/callback"'));
    expect(manifest, isNot(contains('android:path="callback"')));
  });

  test('Native startup remains cream with no smaller duplicate logo', () {
    const androidSplashXmls = [
      'android/app/src/main/res/drawable/launch_background.xml',
      'android/app/src/main/res/drawable-v21/launch_background.xml',
      'android/app/src/main/res/drawable-night/launch_background.xml',
      'android/app/src/main/res/drawable-night-v21/launch_background.xml',
    ];
    for (final file in androidSplashXmls) {
      final xml = File(file).readAsStringSync();
      expect(xml, contains('#F7EDDF'));
      expect(xml, isNot(contains('@drawable/splash')));
    }
    for (final file in [
      'android/app/src/main/res/values-v31/styles.xml',
      'android/app/src/main/res/values-night-v31/styles.xml',
    ]) {
      final xml = File(file).readAsStringSync();
      expect(xml, contains('@drawable/empty_splash_icon'));
      expect(xml, isNot(contains('@drawable/android12splash')));
    }
    expect(
      File('android/app/src/main/res/drawable/empty_splash_icon.xml')
          .readAsStringSync(),
      contains('@android:color/transparent'),
    );

    final ios = File('ios/Runner/Base.lproj/LaunchScreen.storyboard')
        .readAsStringSync();
    expect(ios, contains('0.968627451'));
    expect(ios, isNot(contains('LaunchImage')));
    expect(ios, isNot(contains('<imageView')));

    final config = File('flutter_native_splash.yaml').readAsStringSync();
    expect(config, contains('color: "#F7EDDF"'));
    expect(config, isNot(contains('image: assets/splash')));
  });

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
