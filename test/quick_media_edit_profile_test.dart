import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:towards_him_app/core/navigation/app_router.dart';
import 'package:towards_him_app/core/widgets/app_user_avatar.dart';
import 'package:towards_him_app/features/home/data/home_demo_data.dart';
import 'package:towards_him_app/features/home/domain/models/home_models.dart';
import 'package:towards_him_app/features/home/presentation/screens/home_shell_screen.dart';
import 'package:towards_him_app/features/listen/data/spoken_demo_data.dart';
import 'package:towards_him_app/features/listen/presentation/screens/audio_player_screen.dart';
import 'package:towards_him_app/features/listen/presentation/services/narration_engine.dart';
import 'package:towards_him_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:towards_him_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:towards_him_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:towards_him_app/features/profile/presentation/services/profile_photo_picker.dart';

class TestVoice implements NarrationEngine {
  int starts = 0;
  int pauses = 0;
  int resumes = 0;
  int stops = 0;
  double? seekTo;
  double? speed;
  String? spokenText;

  @override
  Future<void> start(
    String text, {
    required void Function(double) onProgress,
    required void Function() onComplete,
    required void Function(String) onError,
  }) async {
    starts++;
    spokenText = text;
  }

  @override
  Future<void> pause() async { pauses++; }
  @override
  Future<void> resume() async { resumes++; }
  @override
  Future<void> stop() async { stops++; }
  @override
  Future<void> seek(double fraction) async { seekTo = fraction; }
  @override
  Future<void> setSpeed(double value) async { speed = value; }
}

class TestPhotoPicker implements ProfilePhotoPicker {
  final Uint8List image = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jR+0AAAAASUVORK5CYII=',
  );
  int picks = 0;
  @override
  Future<Uint8List?> pick() async {
    picks++;
    return image;
  }
}

void main() {
  test('Three original voice scripts have distinct categories', () {
    final items = HomeDemoData.quickAccess;
    expect(items.map((e) => e.type), [
      HomeQuickType.podcast, HomeQuickType.meditation, HomeQuickType.prayer,
    ]);
    final media = items.map((item) =>
        SpokenDemoData.forCategory(item.type)).toList();
    expect(media.map((e) => e.contentType), ['Podcast', 'Meditation', 'Prayer']);
    expect(media.every((e) => (e.narrationText ?? '').length > 100), isTrue);
    expect(media.map((e) => e.narrationText).toSet().length, 3);
  });

  testWidgets('Quick Podcast opens related Player from Home', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    final quick = find.byKey(const Key('quick_Podcast'));
    await tester.ensureVisible(quick);
    await tester.pumpAndSettle();
    await tester.tap(quick);
    await tester.pumpAndSettle();
    final player = tester.widget<AudioPlayerScreen>(find.byType(AudioPlayerScreen));
    expect(player.episode.id, SpokenDemoData.podcast.id);
    expect(player.episode.narrationText, SpokenDemoData.podcastScript);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Listen Meditation and Prayer shortcuts open related tracks',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byKey(const Key('nav_Listen')));
    await tester.pumpAndSettle();
    for (final type in [HomeQuickType.meditation, HomeQuickType.prayer]) {
      final title = type == HomeQuickType.meditation ? 'Meditation' : 'Prayer';
      await tester.tap(find.byKey(Key('quick_$title')));
      await tester.pumpAndSettle();
      final player = tester.widget<AudioPlayerScreen>(
        find.byType(AudioPlayerScreen),
      );
      expect(player.episode.contentType, title);
      expect(player.episode.narrationText, isNotEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Voice controller starts, pauses, resumes, seeks and stops',
      (tester) async {
    final voice = TestVoice();
    await tester.pumpWidget(MaterialApp(
      home: AudioPlayerScreen(
        episode: SpokenDemoData.prayer,
        narrationEngine: voice,
      ),
    ));
    await tester.pump();
    expect(voice.starts, 1);
    expect(voice.spokenText, SpokenDemoData.prayerScript);
    await tester.tap(find.byKey(const Key('player_primary_play')));
    await tester.pump();
    expect(voice.pauses, 1);
    await tester.tap(find.byKey(const Key('player_primary_play')));
    await tester.pump();
    expect(voice.resumes, 1);
    await tester.tap(find.byKey(const Key('player_forward')));
    await tester.pump();
    expect(voice.seekTo, isNotNull);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    expect(voice.stops, 1);
  });

  test('ProfileController updates text and photo without a backend', () {
    final controller = ProfileController();
    addTearDown(controller.dispose);
    final oldId = controller.user.id;
    final bytes = Uint8List.fromList([1, 2, 3]);
    controller.update(
      fullName: ' Grace Lane ',
      email: ' grace@example.com ',
      bio: '  Growing in faith  ',
      photoBytes: bytes,
    );
    expect(controller.user.id, oldId);
    expect(controller.user.fullName, 'Grace Lane');
    expect(controller.user.email, 'grace@example.com');
    expect(controller.user.about, 'Growing in faith');
    expect(controller.user.avatarBytes, bytes);
  });

  testWidgets('Edit Profile saves name, email and bio to Profile screen',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const HomeShellScreen(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    ));
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile_edit_button')));
    await tester.pumpAndSettle();
    expect(find.byType(EditProfileScreen), findsOneWidget);
    await tester.enterText(find.byKey(const Key('edit_profile_name')), 'Grace Lane');
    await tester.enterText(find.byKey(const Key('edit_profile_email')), 'grace@example.com');
    await tester.ensureVisible(find.byKey(const Key('edit_profile_bio')));
    await tester.enterText(find.byKey(const Key('edit_profile_bio')), 'Growing in faith');
    await tester.ensureVisible(find.byKey(const Key('edit_profile_save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit_profile_save')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Grace Lane'), findsOneWidget);
    expect(find.text('grace@example.com'), findsOneWidget);
    expect(find.text('Growing in faith'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Photo picker updates portrait without uploading anything',
      (tester) async {
    final controller = ProfileController();
    addTearDown(controller.dispose);
    final picker = TestPhotoPicker();
    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(controller: controller, photoPicker: picker),
    ));
    await tester.tap(find.byKey(const Key('edit_profile_change_photo')));
    await tester.pumpAndSettle();
    expect(picker.picks, 1);
    expect(
      tester.widget<AppUserAvatar>(
        find.byKey(const Key('edit_profile_avatar')),
      ).bytes,
      picker.image,
    );
    expect(controller.user.avatarBytes, isNull); // Not saved until requested.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Save refuses invalid email and empty name', (tester) async {
    final controller = ProfileController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(controller: controller),
    ));
    await tester.enterText(find.byKey(const Key('edit_profile_name')), '');
    await tester.tap(find.byKey(const Key('edit_profile_save')));
    await tester.pump();
    expect(find.text('Please enter your name.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('edit_profile_name')), 'Grace');
    await tester.enterText(find.byKey(const Key('edit_profile_email')), 'invalid');
    await tester.tap(find.byKey(const Key('edit_profile_save')));
    await tester.pump();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(controller.user.fullName, 'Sarah Johnson');
  });

  for (final size in [
    const Size(320, 568),
    const Size(430, 932),
    const Size(820, 1180),
  ]) {
    testWidgets('Edit Profile scrolls at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = ProfileController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(
        home: EditProfileScreen(controller: controller),
      ));
      expect(find.byKey(const Key('edit_profile_scroll')), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('edit_profile_scroll')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
