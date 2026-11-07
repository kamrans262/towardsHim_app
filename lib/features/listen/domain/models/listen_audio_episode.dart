/// Local Listen audio episode model, prepared for a future data repository.
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
}
