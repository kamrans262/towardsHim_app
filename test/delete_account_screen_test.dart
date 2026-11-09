import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_button.dart';
import 'package:towards_him_app/core/widgets/app_content_card.dart';
import 'package:towards_him_app/core/widgets/app_detail_page_header.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/profile/data/delete_account_demo_data.dart';
import 'package:towards_him_app/features/profile/data/profile_demo_data.dart';
import 'package:towards_him_app/features/profile/presentation/screens/delete_account_screen.dart';
import 'package:towards_him_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/profile_bullet_list.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/profile_menu_card.dart';

void main() {
  Future<void> openDelete(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeShellScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    final menu = find.byKey(const Key('profile_menu_deleteAccount'));
    await tester.ensureVisible(menu);
    await tester.pumpAndSettle();
    await tester.tap(menu);
    await tester.pumpAndSettle();
  }

  test('Delete Account copy matches approved Figma fixture', () {
    expect(DeleteAccountDemoData.bullets.length, 3);
    expect(
      DeleteAccountDemoData.warningItem.title,
      'This action cannot be undone',
    );
    expect(
      DeleteAccountDemoData.informationItem.title,
      'If you change your mind you can always create new account in future',
    );
    expect(
      DeleteAccountDemoData.confirmationDescription,
      'Are you sure you want to permanently delete your account? '
      'This action cannot be undone.',
    );
  });

  testWidgets('Profile menu opens standalone Delete Account page',
      (tester) async {
    await openDelete(tester);
    expect(find.byType(DeleteAccountScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(
      tester.widget<AppDetailPageHeader>(
        find.byType(AppDetailPageHeader),
      ).title,
      'Delete Account',
    );
    expect(find.byType(ProfileMenuCard), findsNWidgets(2));
    expect(find.byType(ProfileBulletList), findsOneWidget);
    expect(find.text('Before Deleting Account'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Warning, information, and action buttons reuse global styling',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openDelete(tester);

    final warningFinder = find.byKey(const Key('delete_warning_card'));
    final warning = tester.widget<ProfileMenuCard>(warningFinder);
    expect(warning.backgroundColor, AppColors.warningBackground);
    expect(warning.borderColor, AppColors.warningBorder);
    expect(warning.iconColor, AppColors.warningRed);
    expect(warning.titleStyle?.color, AppColors.warningRed);
    expect(warning.descriptionStyle?.fontSize, 12);
    expect(tester.getSize(warningFinder).width, closeTo(390, 0.1));

    final info = tester.widget<ProfileMenuCard>(
      find.byKey(const Key('delete_information_card')),
    );
    expect(info.backgroundColor, isNull);
    expect(info.titleStyle?.fontSize, 14);

    final deleteButton = tester.widget<AppButton>(
      find.byKey(const Key('delete_account_button')),
    );
    expect(deleteButton.filledBackgroundColor, AppColors.warningRed);

    final cancelButton = tester.widget<AppButton>(
      find.byKey(const Key('delete_account_cancel_button')),
    );
    expect(cancelButton.variant, AppButtonVariant.outlined);
    expect(cancelButton.outlinedBackgroundColor, Colors.transparent);
    expect(cancelButton.outlinedBorderColor, AppColors.warningRed);
    expect(cancelButton.outlinedForegroundColor, AppColors.warningRed);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Confirmation is UI-only; dismissing leaves user on page',
      (tester) async {
    await openDelete(tester);
    await tester.ensureVisible(find.byKey(const Key('delete_account_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_account_button')));
    await tester.pumpAndSettle();

    expect(find.text('Delete Account?'), findsOneWidget);
    expect(
      find.text(DeleteAccountDemoData.confirmationDescription),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('delete_dialog_cancel')));
    await tester.pumpAndSettle();
    expect(find.byType(DeleteAccountScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete_account_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_dialog_confirm')));
    await tester.pumpAndSettle();
    expect(find.byType(DeleteAccountScreen), findsOneWidget);
    expect(find.text(DeleteAccountDemoData.demoNotice), findsOneWidget);
    expect(ProfileDemoData.user.fullName, 'Sarah Johnson');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancel returns to Profile without losing five-tab navigation',
      (tester) async {
    await openDelete(tester);
    await tester.ensureVisible(
      find.byKey(const Key('delete_account_cancel_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_account_cancel_button')));
    await tester.pumpAndSettle();
    expect(find.byType(DeleteAccountScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Delete Account scrolls without overflow at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openDelete(tester);
      expect(find.byKey(const Key('delete_account_scroll')), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(const Key('delete_account_scroll')),
        const Offset(0, -260),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
