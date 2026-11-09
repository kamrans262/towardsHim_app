import '../../home/data/home_demo_data.dart';
import '../../home/domain/models/home_models.dart';
import '../domain/models/listen_audio_episode.dart';

/// Original short spoken demonstrations, narrated by the device (offline
/// where a language voice is installed). These are not recorded podcasts.
abstract final class SpokenDemoData {
  static const podcastScript =
      'Welcome to Toward HIM. Today we are talking about finding hope in '
      'difficult seasons. When life feels uncertain, we can take one small '
      'step at a time. You do not need all the answers right now. '
      'Pause, breathe, and remember that God is near. '
      'Reach out to someone who cares about you, spend a quiet moment in '
      'prayer, and look for one simple reason to be thankful today. '
      'Thank you for joining us. May you carry hope into the rest of your day.';

  static const meditationScript =
      'Welcome to a quiet moment with God. Find a comfortable position. '
      'Relax your shoulders. Breathe in slowly, and breathe out. '
      'Notice the ground beneath you. You are here, in this moment. '
      'Give yourself permission to slow down. '
      'In the stillness, remember the words: Be still, and know that I am God. '
      'As you breathe, let go of one worry you have been carrying. '
      'Rest in patience, peace, and the knowledge that you are loved. '
      'Take another gentle breath. When you are ready, open your eyes.';

  static const prayerScript =
      'Let us pray. Heavenly Father, thank You for this day. '
      'Thank You for Your patience, care, and unfailing love. '
      'When we feel worried, give us peace. '
      'When we feel tired, give us strength. '
      'When we have choices to make, guide us toward wisdom and kindness. '
      'Help us to see the needs of others and to share encouragement. '
      'Teach us to trust You even when the way ahead is unclear. '
      'May our words and actions reflect Your love today. Amen.';

  static const podcast = ListenAudioEpisode(
    id: 'spoken-podcast-demo',
    title: 'Finding hope in difficult seasons',
    description: 'A short spoken encouragement about trusting God.',
    thumbnailAsset: HomeDemoData.meditationAsset,
    contentType: 'Podcast',
    durationMinutes: 1,
    timelineDurationSeconds: 70,
    playbackProgress: 0,
    isCompleted: false,
    playerTitle: 'Finding hope in difficult seasons',
    coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
    narrationText: podcastScript,
    narrationDurationSeconds: 70,
  );

  static const meditation = ListenAudioEpisode(
    id: 'spoken-meditation-demo',
    title: 'Be Still in His Presence',
    description: 'A guided faith-based moment of quiet reflection.',
    thumbnailAsset: HomeDemoData.meditationAsset,
    contentType: 'Meditation',
    durationMinutes: 1,
    timelineDurationSeconds: 70,
    playbackProgress: 0,
    isCompleted: false,
    coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
    narrationText: meditationScript,
    narrationDurationSeconds: 70,
  );

  static const prayer = ListenAudioEpisode(
    id: 'spoken-prayer-demo',
    title: 'A Prayer for Peace and Strength',
    description: 'A short prayer for guidance, gratitude, and peace.',
    thumbnailAsset: HomeDemoData.meditationAsset,
    contentType: 'Prayer',
    durationMinutes: 1,
    timelineDurationSeconds: 60,
    playbackProgress: 0,
    isCompleted: false,
    coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
    narrationText: prayerScript,
    narrationDurationSeconds: 60,
  );

  static ListenAudioEpisode forCategory(HomeQuickType type) => switch (type) {
        HomeQuickType.podcast => podcast,
        HomeQuickType.meditation => meditation,
        HomeQuickType.prayer => prayer,
      };
}
