import '../../home/data/home_demo_data.dart';
import '../domain/models/listen_audio_episode.dart';
import 'spoken_demo_data.dart';

/// Reference content is intentionally repeated to match the supplied Figma.
abstract final class ListenDemoData {
  static const description =
      'Explore Podcasts, Prayers, Meditation and grow in faith and draw closer to HIM';

  static const episodes = <ListenAudioEpisode>[
    ListenAudioEpisode(
      id: 'finding-hope-01',
      title: 'Finding hope in difficult season',
      description: 'A conversation about trusting god when life feels uncertain',
      thumbnailAsset: HomeDemoData.meditationAsset,
      contentType: 'Podcast',
      narrationText: SpokenDemoData.podcastScript,
      narrationDurationSeconds: 70,
      durationMinutes: 28,
      // The supplied Figma shows a 28m episode with a 24m demo timeline.
      timelineDurationSeconds: 1440,
      playbackProgress: 750 / 1440,
      isCompleted: false,
      playerTitle: 'Finding hope in difficult seasons',
      playerDescription:
          'In this we talk about how to hold on to hope when life feels uncertain. we are going to discover practical encouragement from god’s words and real life examples of faith in the hard seasons',
      coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
    ),
    ListenAudioEpisode(
      id: 'finding-hope-02',
      title: 'Finding hope in difficult season',
      description: 'A conversation about trusting god when life feels uncertain',
      thumbnailAsset: HomeDemoData.meditationAsset,
      contentType: 'Podcast',
      narrationText: SpokenDemoData.podcastScript,
      narrationDurationSeconds: 70,
      durationMinutes: 24,
      playbackProgress: 0,
      isCompleted: false,
      playerTitle: 'Finding hope in difficult seasons',
      playerDescription:
          'In this we talk about how to hold on to hope when life feels uncertain. we are going to discover practical encouragement from god’s words and real life examples of faith in the hard seasons',
      coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
    ),
    ListenAudioEpisode(
      id: 'finding-hope-03',
      title: 'Finding hope in difficult season',
      description: 'A conversation about trusting god when life feels uncertain',
      thumbnailAsset: HomeDemoData.meditationAsset,
      contentType: 'Podcast',
      narrationText: SpokenDemoData.podcastScript,
      narrationDurationSeconds: 70,
      durationMinutes: 19,
      playbackProgress: 0,
      isCompleted: false,
      playerTitle: 'Finding hope in difficult seasons',
      playerDescription:
          'In this we talk about how to hold on to hope when life feels uncertain. we are going to discover practical encouragement from god’s words and real life examples of faith in the hard seasons',
      coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
    ),
    ListenAudioEpisode(
      id: 'finding-hope-04',
      title: 'Finding hope in difficult season',
      description: 'A conversation about trusting god when life feels uncertain',
      thumbnailAsset: HomeDemoData.meditationAsset,
      contentType: 'Podcast',
      narrationText: SpokenDemoData.podcastScript,
      narrationDurationSeconds: 70,
      durationMinutes: 21,
      playbackProgress: 0,
      isCompleted: false,
      playerTitle: 'Finding hope in difficult seasons',
      playerDescription:
          'In this we talk about how to hold on to hope when life feels uncertain. we are going to discover practical encouragement from god’s words and real life examples of faith in the hard seasons',
      coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
    ),
  ];
}
