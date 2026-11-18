import 'package:flutter/foundation.dart';

/// Immutable video state for the existing bottom player controls.
@immutable
class VideoPlaybackSnapshot {
  const VideoPlaybackSnapshot({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isReady = false,
    this.hasError = false,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isReady;
  final bool hasError;

  double get progress {
    final total = duration.inMilliseconds;
    if (total <= 0) return 0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  String get currentTime => formatTime(position);
  String get totalTime => formatTime(duration);

  Duration seekToFraction(double fraction) {
    final length = duration.inMilliseconds;
    if (length <= 0) return Duration.zero;
    return Duration(
      milliseconds: (length * fraction.clamp(0.0, 1.0)).round(),
    );
  }

  Duration skipSeconds(int seconds) {
    final length = duration.inMilliseconds;
    return Duration(
      milliseconds: (position.inMilliseconds + seconds * 1000)
          .clamp(0, length).toInt(),
    );
  }

  static String formatTime(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 2147483647).toInt();
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      other is VideoPlaybackSnapshot &&
      other.position == position &&
      other.duration == duration &&
      other.isPlaying == isPlaying &&
      other.isReady == isReady &&
      other.hasError == hasError;

  @override
  int get hashCode =>
      Object.hash(position, duration, isPlaying, isReady, hasError);
}
