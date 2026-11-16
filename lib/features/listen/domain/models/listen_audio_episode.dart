import '../../../../core/models/content_media.dart';

/// Listen content may include ordered text, image, audio, and video blocks.
class ListenAudioEpisode {
  const ListenAudioEpisode({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailAsset,
    required this.contentType,
    required this.durationMinutes,
    required this.playbackProgress,
    required this.isCompleted,
    this.playerTitle,
    this.playerDescription,
    this.coverAsset,
    this.timelineDurationSeconds,
    this.narrationText,
    this.narrationDurationSeconds,
    this.audioUrl,
    this.artworkUrl,
    this.media = const [],
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailAsset;
  final String contentType;
  final int durationMinutes;
  final double playbackProgress;
  final bool isCompleted;

  /// Optional detail-screen metadata. List titles and thumbnails remain
  /// unchanged when the Player displays the longer Figma copy/cover.
  final String? playerTitle;
  final String? playerDescription;
  final String? coverAsset;

  /// Optional preview timeline length when demo duration labels differ.
  final int? timelineDurationSeconds;

  /// Original spoken demo script; null for visual-only content.
  final String? narrationText;
  final int? narrationDurationSeconds;
  /// Server media URL; null for existing local/TTS fixtures.
  final String? audioUrl;
  final String? artworkUrl;
  final List<ContentMedia> media;

  factory ListenAudioEpisode.fromApi(Map<String, dynamic> json) {
    final category = json['category']?.toString() ?? 'podcast';
    const names = {'podcast': 'Podcast', 'meditation': 'Meditation', 'prayer': 'Prayer'};
    final rawSeconds = (json['duration_seconds'] as num?)?.toInt();
    final media = ContentMedia.parseList(json['media']);
    String? firstMediaUrl(ContentMediaType type) {
      for (final block in media) {
        if (block.type == type && block.hasPlayableFile) return block.url;
      }
      return null;
    }
    String? mediaUrl(dynamic value) {
      if (value is! String || value.isEmpty) return null;
      final parsed = Uri.tryParse(value);
      return parsed?.hasScheme == true ? value : null;
    }
    return ListenAudioEpisode(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
      coverAsset: 'assets/images/player/golden_mountain_valleys_dusk.webp',
      contentType: names[category] ?? 'Podcast',
      durationMinutes: rawSeconds == null ? 0 : (rawSeconds / 60).ceil(),
      timelineDurationSeconds: rawSeconds,
      playbackProgress: 0,
      isCompleted: false,
      audioUrl: mediaUrl(json['audio_url']) ?? firstMediaUrl(ContentMediaType.audio),
      artworkUrl: mediaUrl(json['artwork_url']) ?? firstMediaUrl(ContentMediaType.image),
      media: media,
    );
  }
}
