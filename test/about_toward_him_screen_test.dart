import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/widgets/app_back_button.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_content_card.dart';
import 'package:towards_him_app/core/widgets/toward_him_logo.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/profile/data/about_toward_him_demo_data.dart';
import 'package:towards_him_app/features/profile/presentation/screens/about_toward_him_screen.dart';
import 'package:towards_him_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/about_contact_card.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/about_hero_header.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/about_section_card.dart';

void main() {
  Future<void> openAbout(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeShellScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    final aboutItem = find.byKey(const Key('profile_menu_about'));
    await tester.ensureVisible(aboutItem);
    await tester.pumpAndSettle();
    await tester.tap(aboutItem);
    await tester.pumpAndSettle();
  }

  test('Approved About content and supplied social asset mapping', () {
    expect(AboutTowardHimDemoData.title, 'About Toward HIM');
    expect(AboutTowardHimDemoData.sections.length, 3);
    expect(AboutTowardHimDemoData.sections.map((e) => e.title), [
      'Our Mission',
      'Our Vision',
      'Our Values',
    ]);
    expect(AboutTowardHimDemoData.primaryEmail, 'Hello.towardhHIM@gmail.com');
    expect(AboutTowardHimDemoData.secondaryEmail, 'Hello.towardHIM@gmail.com');
    expect(AboutTowardHimDemoData.website, 'TowardHIM.com');
    expect(AboutTowardHimDemoData.socials.map((e) => e.name), [
      'Facebook',
      'Instagram',
      'TikTok',
      'YouTube',
    ]);
    expect(
      AboutTowardHimDemoData.socials.every(
        (social) => social.asset.startsWith('assets/icons/profile/'),
      ),
      isTrue,
    );
  });

  testWidgets('Profile About action opens standalone About page', (tester) async {
    await openAbout(tester);
    expect(find.byType(AboutTowardHimScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(TowardHimLogo), findsOneWidget);
    expect(find.byType(AboutHeroHeader), findsOneWidget);
    expect(find.byKey(const Key('about_hero_image')), findsOneWidget);
    expect(find.byType(AboutSectionCard), findsNWidgets(3));
    expect(find.byType(AboutContactCard), findsOneWidget);
    expect(find.byType(AppContentCard), findsNWidgets(4));
    expect(find.text('About Toward HIM'), findsOneWidget);
    expect(find.text('A journey of faith. a journey with god'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(find.byType(AboutTowardHimScreen), findsNothing);
  });

  testWidgets('About hero keeps 20px top inset and rounded upper corners',
      (tester) async {
    await openAbout(tester);
    final container = tester.widget<Container>(
      find.byKey(const Key('about_rounded_container')),
    );
    expect(container.padding, const EdgeInsets.only(top: 20));
    expect(
      (container.decoration! as BoxDecoration).borderRadius,
      const BorderRadius.vertical(top: Radius.circular(20)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Section cards open local content without backend', (tester) async {
    await openAbout(tester);
    await tester.tap(find.byKey(const Key('about_section_mission')));
    await tester.pumpAndSettle();
    expect(find.text('Our Mission'), findsNWidgets(2));
    expect(find.text(AboutTowardHimDemoData.sectionDescription), findsNWidgets(4));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AboutTowardHimScreen), findsOneWidget);
  });

  testWidgets('Contact panel shows the supplied SVGs and contact details',
      (tester) async {
    await openAbout(tester);
    final panel = find.byType(AboutContactCard);
    await tester.ensureVisible(panel);
    await tester.pumpAndSettle();
    expect(find.text(AboutTowardHimDemoData.primaryEmail), findsOneWidget);
    expect(find.text(AboutTowardHimDemoData.secondaryEmail), findsOneWidget);
    expect(find.text(AboutTowardHimDemoData.address), findsOneWidget);
    expect(find.text(AboutTowardHimDemoData.website), findsOneWidget);
    expect(find.byKey(const Key('about_social_facebook')), findsOneWidget);
    expect(find.byKey(const Key('about_social_instagram')), findsOneWidget);
    expect(find.byKey(const Key('about_social_tiktok')), findsOneWidget);
    expect(find.byKey(const Key('about_social_youtube')), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
    await tester.tap(find.byKey(const Key('about_social_facebook')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Facebook link will be configured'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('About Toward HIM is scrollable at ${size.width} x ${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openAbout(tester);
      expect(find.byKey(const Key('about_toward_him_scroll')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const Key('about_toward_him_scroll')),
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
