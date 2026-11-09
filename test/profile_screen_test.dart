import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_content_card.dart';
import 'package:towards_him_app/core/widgets/app_main_screen_header.dart';
import 'package:towards_him_app/core/widgets/app_user_avatar.dart';
import 'package:towards_him_app/features/community/data/community_demo_data.dart';
import 'package:towards_him_app/features/community/presentation/widgets/community_post_card.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:towards_him_app/features/profile/data/profile_demo_data.dart';
import 'package:towards_him_app/features/profile/domain/models/profile_models.dart';
import 'package:towards_him_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/profile_user_card.dart';

void main() {
  Future<void> openProfile(WidgetTester tester, {String tab = 'Home'}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeShellScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    if (tab != 'Home') {
      await tester.tap(find.byKey(Key('nav_$tab')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
  }

  test('Demo data matches approved screenshot', () {
    expect(ProfileDemoData.user.fullName, 'Sarah Johnson');
    expect(ProfileDemoData.user.email, 'sarah@gmail.com');
    expect(ProfileDemoData.user.avatarAsset, CommunityDemoData.avatarAsset);
    expect(ProfileDemoData.menu.length, 7);
    expect(ProfileDemoData.menu.map((m) => m.action).toList(), [
      ProfileMenuAction.myProfile,
      ProfileMenuAction.about,
      ProfileMenuAction.merchandise,
      ProfileMenuAction.privacy,
      ProfileMenuAction.terms,
      ProfileMenuAction.deleteAccount,
      ProfileMenuAction.logout,
    ]);
    expect(ProfileDemoData.menu.last.showChevron, isFalse);
    expect(ProfileDemoData.menu.last.description, isNull);
    expect(ProfileDemoData.menu[5].tone, ProfileMenuIconTone.danger);
  });

  testWidgets('Profile uses shared header, avatar, cards and five tabs',
      (tester) async {
    await openProfile(tester);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(ProfileUserCard), findsOneWidget);
    expect(find.byType(AppUserAvatar), findsOneWidget);
    expect(find.byType(ProfileMenuCard), findsNWidgets(7));
    expect(find.text('Sarah Johnson'), findsOneWidget);
    expect(find.text('sarah@gmail.com'), findsOneWidget);
    expect(
      tester.widget<AppMainScreenHeader>(
        find.byType(AppMainScreenHeader),
      ).title,
      'Profile',
    );
    final nav = tester.widget<AppBottomNavigation>(
      find.byType(AppBottomNavigation),
    );
    expect(nav.items.length, 5);
    expect(nav.selectedIndex, 0);
    expect(find.byKey(const Key('profile_edit_button')), findsOneWidget);
    final card = tester.widget<AppContentCard>(
      find.byType(AppContentCard).first,
    );
    expect(card.backgroundColor, AppColors.outlinedButtonBackground);
    expect(card.padding, const EdgeInsets.all(20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile opens from every main tab, retaining nav selection',
      (tester) async {
    for (final tab in ['Home', 'Listen', 'Towards HIM 3', 'Community']) {
      await openProfile(tester, tab: tab);
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(
        tester.widget<AppBottomNavigation>(
          find.byType(AppBottomNavigation),
        ).selectedIndex,
        ['Home', 'Listen', 'Towards HIM 3', 'Community'].indexOf(tab),
      );
      await tester.tap(find.byKey(Key('nav_$tab')));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Existing Community state survives viewing Profile',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('nav_Community')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('community_tab_myPosts')));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostCard), findsNWidgets(2));
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav_Community')));
    await tester.pumpAndSettle();
    expect(find.byType(CommunityPostCard), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Delete confirmation is safe and does not remove data',
      (tester) async {
    await openProfile(tester);
    final delete = find.byKey(const Key('profile_menu_deleteAccount'));
    await tester.ensureVisible(delete);
    await tester.pumpAndSettle();
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(find.text('Delete Account?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile_delete_cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Delete Account?'), findsNothing);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_delete_confirm')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.textContaining('no account or data was deleted'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Log Out returns to Welcome', (tester) async {
    await openProfile(tester);
    final logout = find.byKey(const Key('profile_menu_logout'));
    await tester.ensureVisible(logout);
    await tester.pumpAndSettle();
    await tester.tap(logout);
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Profile scrolls at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openProfile(tester);
      expect(find.byKey(const Key('profile_scroll')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const Key('profile_scroll')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
