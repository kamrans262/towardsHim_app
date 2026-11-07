import 'package:flutter/foundation.dart';

import '../../domain/models/listen_audio_episode.dart';

/// Ephemeral, screen-scoped presentation state. Does not stream or play audio.
class AudioPlayerUiController extends ChangeNotifier {
  AudioPlayerUiController(this.episode)
      : _positionSeconds = (episode.playbackProgress *
                (episode.timelineDurationSeconds ??
                    episode.durationMinutes * 60))
            .round()
            .clamp(0, episode.timelineDurationSeconds ??
                episode.durationMinutes * 60)
            .toInt();

  final ListenAudioEpisode episode;
  int _positionSeconds;
  bool _isPlaying = true;
  double _speed = 1.0;

  int get durationSeconds =>
      episode.timelineDurationSeconds ?? episode.durationMinutes * 60;
  int get positionSeconds => _positionSeconds;
  bool get isPlaying => _isPlaying;
  double get speed => _speed;
  double get progress =>
      durationSeconds == 0 ? 0 : _positionSeconds / durationSeconds;

  String get currentTime => _formatTime(_positionSeconds);
  String get totalTime => _formatTime(durationSeconds);

  static String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void skipSeconds(int offset) {
    _setPosition((_positionSeconds + offset).clamp(0, durationSeconds).toInt());
  }

  void seekFraction(double fraction) {
    _setPosition(
      (fraction.clamp(0.0, 1.0) * durationSeconds).round(),
    );
  }

  void setSpeed(double nextSpeed) {
    if (nextSpeed == _speed) return;
    _speed = nextSpeed;
    notifyListeners();
  }

  void _setPosition(int seconds) {
    if (seconds == _positionSeconds) return;
    _positionSeconds = seconds;
    notifyListeners();
  }
}
