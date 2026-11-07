import '../../home/data/home_demo_data.dart';
import '../domain/models/listen_audio_episode.dart';

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
      durationMinutes: 22,
      playbackProgress: 0,
      isCompleted: false,
    ),
    ListenAudioEpisode(
      id: 'finding-hope-02',
      title: 'Finding hope in difficult season',
      description: 'A conversation about trusting god when life feels uncertain',
      thumbnailAsset: HomeDemoData.meditationAsset,
      contentType: 'Podcast',
      durationMinutes: 24,
      playbackProgress: 0,
      isCompleted: false,
    ),
    ListenAudioEpisode(
      id: 'finding-hope-03',
      title: 'Finding hope in difficult season',
      description: 'A conversation about trusting god when life feels uncertain',
      thumbnailAsset: HomeDemoData.meditationAsset,
      contentType: 'Podcast',
      durationMinutes: 19,
      playbackProgress: 0,
      isCompleted: false,
    ),
    ListenAudioEpisode(
      id: 'finding-hope-04',
      title: 'Finding hope in difficult season',
      description: 'A conversation about trusting god when life feels uncertain',
      thumbnailAsset: HomeDemoData.meditationAsset,
      contentType: 'Podcast',
      durationMinutes: 21,
      playbackProgress: 0,
      isCompleted: false,
    ),
  ];
}
