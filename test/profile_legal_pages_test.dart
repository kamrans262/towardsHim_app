import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_content_card.dart';
import 'package:towards_him_app/core/widgets/app_detail_page_header.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/profile/data/legal_documents_demo_data.dart';
import 'package:towards_him_app/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:towards_him_app/features/profile/presentation/screens/terms_of_service_screen.dart';
import 'package:towards_him_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:towards_him_app/features/profile/presentation/widgets/legal_document_view.dart';

void main() {
  Future<void> openLegalPage(WidgetTester tester, String menuKey) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const HomeShellScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    final menu = find.byKey(Key('profile_menu_$menuKey'));
    await tester.ensureVisible(menu);
    await tester.pumpAndSettle();
    await tester.tap(menu);
    await tester.pumpAndSettle();
  }

  test('Both legal page models are explicitly marked unapproved', () {
    expect(LegalDocumentsDemoData.privacy.title, 'Privacy Policy');
    expect(LegalDocumentsDemoData.terms.title, 'Terms of Service');
    expect(LegalDocumentsDemoData.privacy.sections.length, 5);
    expect(LegalDocumentsDemoData.terms.sections.length, 5);
    expect(LegalDocumentsDemoData.draftNotice, contains('Draft content'));
    expect(LegalDocumentsDemoData.draftNotice, contains('before publishing'));
  });

  testWidgets('Profile Privacy Policy opens and returns without changing tabs',
      (tester) async {
    await openLegalPage(tester, 'privacy');
    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    expect(find.byType(LegalDocumentView), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.byKey(const Key('legal_draft_notice')), findsOneWidget);
    expect(find.byType(AppContentCard), findsNWidgets(6));
    expect(
      tester.widget<AppDetailPageHeader>(
        find.byType(AppDetailPageHeader),
      ).title,
      'Privacy Policy',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile Terms of Service opens and returns',
      (tester) async {
    await openLegalPage(tester, 'terms');
    expect(find.byType(TermsOfServiceScreen), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Community Guidelines'), findsOneWidget);
    expect(find.byKey(const Key('legal_document_scroll')), findsOneWidget);
    expect(find.byType(AppBottomNavigation), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    for (final usePrivacy in <bool>[true, false]) {
      testWidgets(
        '${usePrivacy ? 'Privacy' : 'Terms'} scrolls at '
        '${size.width}x${size.height}',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              home: usePrivacy
                  ? const PrivacyPolicyScreen()
                  : const TermsOfServiceScreen(),
            ),
          );
          expect(find.byType(LegalDocumentView), findsOneWidget);
          expect(find.byType(AppBottomNavigation), findsNothing);
          expect(find.byKey(const Key('legal_document_scroll')), findsOneWidget);
          expect(tester.takeException(), isNull);
          final card = tester.widget<AppContentCard>(
            find.byType(AppContentCard).first,
          );
          expect(card.padding, const EdgeInsets.all(20));
          expect(AppSpacing.screenHorizontal, 20);
          expect(AppColors.background, const Color(0xFFF7EDDF));
          await tester.drag(
            find.byKey(const Key('legal_document_scroll')),
            const Offset(0, -280),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
