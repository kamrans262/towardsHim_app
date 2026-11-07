import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:towards_him_app/core/theme/app_colors.dart';
import 'package:towards_him_app/core/theme/app_spacing.dart';
import 'package:towards_him_app/core/theme/app_typography.dart';
import 'package:towards_him_app/core/widgets/app_audio_content_row.dart';
import 'package:towards_him_app/core/widgets/app_audio_thumbnail.dart';
import 'package:towards_him_app/core/widgets/app_bottom_navigation.dart';
import 'package:towards_him_app/core/widgets/app_circular_play_button.dart';
import 'package:towards_him_app/core/widgets/app_main_screen_header.dart';
import 'package:towards_him_app/core/widgets/app_svg_icon_button.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/home/presentation/widgets/home_quick_access_card.dart';
import 'package:towards_him_app/features/listen/data/listen_demo_data.dart';
import 'package:towards_him_app/features/listen/presentation/screens/listen_screen.dart';
import 'package:towards_him_app/features/listen/presentation/widgets/listen_audio_list_item.dart';

void main() {
  test('Listen has four unique demo episodes with Figma content', () {
    expect(ListenDemoData.episodes.length, 4);
    expect(
      ListenDemoData.episodes.map((episode) => episode.id).toSet().length,
      4,
    );
    for (final episode in ListenDemoData.episodes) {
      expect(episode.title, 'Finding hope in difficult season');
      expect(
        episode.description,
        'A conversation about trusting god when life feels uncertain',
      );
      expect(episode.contentType, 'Podcast');
      expect(episode.durationMinutes, greaterThan(0));
      expect(episode.isCompleted, false);
    }
  });

  Future<void> openListen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShellScreen()));
    await tester.tap(find.byKey(const Key('nav_Listen')));
    await tester.pumpAndSettle();
  }

  testWidgets('Listen reuses Home global navigation and shared heading',
      (tester) async {
    await openListen(tester);
    expect(find.byType(ListenScreen), findsOneWidget);
    final nav = tester.widget<AppBottomNavigation>(
      find.byType(AppBottomNavigation),
    );
    expect(nav.selectedIndex, 1);
    expect(nav.items.length, 5);
    final header = tester.widget<AppMainScreenHeader>(
      find.byType(AppMainScreenHeader),
    );
    expect(header.title, 'Listen');
    expect(AppTypography.mainScreenTitle.fontSize, 24);
    expect(AppTypography.mainScreenTitle.fontWeight, FontWeight.w700);
    expect(find.text(ListenDemoData.description), findsOneWidget);
    expect(find.byType(AppSvgIconButton), findsNWidgets(2));
    final icons = tester.widgetList<SvgPicture>(find.byType(SvgPicture)).toList();
    expect(
      icons.where((icon) => icon.width == 28 && icon.height == 28).length,
      2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Header and description use the required 10px spacing',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openListen(tester);
    final header = tester.getRect(find.byType(AppMainScreenHeader));
    final description =
        tester.getRect(find.text(ListenDemoData.description));
    expect(description.top - header.bottom, closeTo(10, 0.1));
  });

  testWidgets('Listen reuses the three Quick Access cards, taller than Home',
      (tester) async {
    await openListen(tester);
    final cards = tester.widgetList<HomeQuickAccessCard>(
      find.byType(HomeQuickAccessCard),
    ).toList();
    expect(cards.length, 3);
    expect(cards.map((item) => item.item.title),
        ['Podcast', 'Meditation', 'Prayer']);
    for (final item in cards) {
      expect(item.height, AppSpacing.listenQuickCardHeight);
    }
    expect(AppSpacing.listenQuickCardHeight,
        greaterThan(AppSpacing.homeQuickCardHeight));
    await tester.tap(find.byKey(const Key('quick_Podcast')));
    await tester.pump();
    expect(find.text('Podcast category UI is coming soon.'), findsOneWidget);
  });

  testWidgets('Four rows have 100px thumbnails and three dividers',
      (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openListen(tester);
    final items = tester.widgetList<ListenAudioListItem>(
      find.byType(ListenAudioListItem),
    ).toList();
    expect(items.length, 4);
    expect(find.byType(Divider), findsNWidgets(3));
    final images = tester.widgetList<AppAudioThumbnail>(
      find.byType(AppAudioThumbnail),
    ).toList();
    expect(images.length, 4);
    expect(images.every((image) => image.size == 100), isTrue);
    expect(find.byType(AppAudioContentRow), findsNWidgets(4));
    expect(find.text('Finding hope in difficult season'), findsNWidgets(4));
    expect(find.byType(AppCircularPlayButton), findsNWidgets(4));
    final row = tester.getRect(find.byType(ListenAudioListItem).first);
    final image = tester.getRect(find.byType(AppAudioThumbnail).first);
    expect(image.width, 100);
    expect(image.height, 100);
    expect(row.left, closeTo(20, 0.1));
  });

  testWidgets('Play button toggles only its local UI state', (tester) async {
    await openListen(tester);
    final buttons = find.byType(AppCircularPlayButton);
    expect(tester.widget<AppCircularPlayButton>(buttons.first).isPlaying, false);
    await tester.tap(buttons.first);
    await tester.pump();
    expect(tester.widget<AppCircularPlayButton>(buttons.first).isPlaying, true);
    await tester.tap(buttons.at(1));
    await tester.pump();
    expect(tester.widget<AppCircularPlayButton>(buttons.first).isPlaying, false);
    expect(tester.widget<AppCircularPlayButton>(buttons.at(1)).isPlaying, true);
  });

  testWidgets('Home and Listen keep their own state across tab switches',
      (tester) async {
    await openListen(tester);
    await tester.tap(find.byType(AppCircularPlayButton).first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('nav_Home')));
    await tester.pumpAndSettle();
    expect(find.text('Continue Where You Left Off'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav_Listen')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppCircularPlayButton>(
        find.byType(AppCircularPlayButton).first,
      ).isPlaying,
      true,
    );
    expect(
      tester.widget<AppBottomNavigation>(
        find.byType(AppBottomNavigation),
      ).selectedIndex,
      1,
    );
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 667),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Listen is responsive at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openListen(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      final navRect = tester.getRect(find.byType(AppBottomNavigation));
      final scaffold = tester.getRect(find.byType(Scaffold));
      expect(navRect.bottom, closeTo(scaffold.bottom, 1));
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ListenAudioListItem), findsNWidgets(4));
    });
  }
}
