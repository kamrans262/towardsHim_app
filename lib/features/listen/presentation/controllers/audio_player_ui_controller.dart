import 'package:flutter/foundation.dart';

import '../../domain/models/listen_audio_episode.dart';

/// Player presentation state; narration engine updates this for playable tracks.
class AudioPlayerUiController extends ChangeNotifier {
  AudioPlayerUiController(this.episode)
      : _positionSeconds = ((episode.narrationText == null
                ? episode.playbackProgress
                : 0.0) *
                (episode.narrationDurationSeconds ??
                    episode.timelineDurationSeconds ??
                    episode.durationMinutes * 60))
            .round()
            .clamp(0, episode.narrationDurationSeconds ??
                episode.timelineDurationSeconds ??
                episode.durationMinutes * 60)
            .toInt();

  final ListenAudioEpisode episode;
  int _positionSeconds;
  bool _isPlaying = true;
  double _speed = 1.0;

  int get durationSeconds =>
      episode.narrationDurationSeconds ??
      episode.timelineDurationSeconds ??
      episode.durationMinutes * 60;
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

  void finishNarration() {
    _positionSeconds = durationSeconds;
    _isPlaying = false;
    notifyListeners();
  }

  void updateNarrationProgress(double fraction) {
    final seconds = (fraction.clamp(0.0, 1.0) * durationSeconds).round();
    _setPosition(seconds);
  }

  void togglePlayPauseIfPlaying() {
    if (_isPlaying) {
      _isPlaying = false;
      notifyListeners();
    }
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
