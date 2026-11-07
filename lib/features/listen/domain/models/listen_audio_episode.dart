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
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailAsset;
  final String contentType;
  final int durationMinutes;
  final double playbackProgress;
  final bool isCompleted;
}
