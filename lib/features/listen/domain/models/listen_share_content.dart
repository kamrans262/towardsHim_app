import '../../../../core/models/content_media.dart';
import 'listen_audio_episode.dart';

/// Share content without claiming that an in-app episode web page exists.
/// The server currently exposes public media URLs, not episode permalinks.
class ListenShareContent {
  const ListenShareContent({required this.message, this.mediaUrl});

  final String message;
  final String? mediaUrl;

  static ListenShareContent forEpisode(ListenAudioEpisode episode) {
    final title = (episode.playerTitle ?? episode.title).trim();
    final description = (episode.playerDescription ?? episode.description).trim();
    final mediaUrl = _firstPublicUrl(episode);

    final parts = <String>[
      if (title.isNotEmpty) title,
      if (description.isNotEmpty) description,
      if (mediaUrl != null) mediaUrl,
      'Toward HIM',
    ];

    return ListenShareContent(
      message: parts.join('\n\n'),
      mediaUrl: mediaUrl,
    );
  }

  static String? _firstPublicUrl(ListenAudioEpisode episode) {
    final urls = <String?>[
      episode.videoUrl,
      episode.audioUrl,
      for (final type in const [
        ContentMediaType.video,
        ContentMediaType.audio,
        ContentMediaType.image,
      ])
        ...episode.media
            .where((media) => media.type == type)
            .map((media) => media.url),
      episode.artworkUrl,
    ];

    for (final raw in urls) {
      if (raw == null) continue;
      final uri = Uri.tryParse(raw);
      if (uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty) {
        return raw;
      }
    }
    return null;
  }
}
