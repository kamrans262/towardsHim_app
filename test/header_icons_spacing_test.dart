import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/app_header_actions.dart';
import 'package:towards_him_app/core/widgets/app_svg_icon_button.dart';

void main() {
  for (final width in <double>[320, 375, 430, 820]) {
    testWidgets('Header SVGs have exactly 16px space at width $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var notificationTaps = 0;
      var profileTaps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppHeaderActions(
                onNotifications: () => notificationTaps++,
                onProfile: () => profileTaps++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bell = find.byKey(const Key('header_svg_Notifications'));
      final person = find.byKey(const Key('header_svg_Profile'));
      expect(bell, findsOneWidget);
      expect(person, findsOneWidget);
      final bellRect = tester.getRect(bell);
      final personRect = tester.getRect(person);
      expect(bellRect.width, AppSpacing.homeHeaderIcon);
      expect(personRect.width, AppSpacing.homeHeaderIcon);
      expect(bellRect.height, AppSpacing.homeHeaderIcon);
      expect(personRect.height, AppSpacing.homeHeaderIcon);
      expect(
        personRect.left - bellRect.right,
        closeTo(AppSpacing.homeHeaderIconGap, 0.01),
      );

      final tapTargets = tester
          .widgetList<AppSvgIconButton>(find.byType(AppSvgIconButton))
          .toList();
      expect(tapTargets.length, 2);
      expect(tapTargets.first.iconSize, 28);
      expect(tapTargets.last.iconSize, 28);
      expect(
        tester.getRect(find.byType(AppSvgIconButton).first).width,
        44,
      );
      expect(find.byType(SvgPicture), findsNWidgets(2));
      await tester.tap(find.byTooltip('Notifications'));
      await tester.tap(find.byTooltip('Profile'));
      await tester.pump();
      expect(notificationTaps, 1);
      expect(profileTaps, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
