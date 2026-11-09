import 'package:flutter_tts/flutter_tts.dart';

/// Small injectable interface so widget tests can use a fake voice engine.
abstract class NarrationEngine {
  Future<void> start(
    String text, {
    required void Function(double progress) onProgress,
    required void Function() onComplete,
    required void Function(String message) onError,
  });

  Future<void> pause();
  Future<void> resume();
  Future<void> seek(double fraction);
  Future<void> setSpeed(double value);
  Future<void> stop();
}

/// Plays real spoken audio using iOS/Android's text-to-speech voice.
/// No external URL or server is necessary.
class DeviceNarrationEngine implements NarrationEngine {
  final FlutterTts _tts = FlutterTts();
  String _text = '';
  int _offset = 0;
  double _speed = 1;
  bool _paused = false;
  bool _stopped = false;
  void Function(double progress)? _onProgress;
  void Function()? _onComplete;
  void Function(String message)? _onError;

  @override
  Future<void> start(
    String text, {
    required void Function(double progress) onProgress,
    required void Function() onComplete,
    required void Function(String message) onError,
  }) async {
    _text = text;
    _offset = 0;
    _paused = false;
    _stopped = false;
    _onProgress = onProgress;
    _onComplete = onComplete;
    _onError = onError;
    _tts.setProgressHandler((_, start, end, word) {
      if (_stopped || _paused || _text.isEmpty) return;
      _offset = (_speechStart + end).clamp(0, _text.length).toInt();
      _onProgress?.call(_offset / _text.length);
    });
    _tts.setCompletionHandler(() {
      if (!_paused && !_stopped) {
        _offset = _text.length;
        _onProgress?.call(1);
        _onComplete?.call();
      }
    });
    _tts.setErrorHandler((message) {
      if (!_stopped) _onError?.call(message.toString());
    });
    try {
      await _tts.setLanguage('en-US');
      await _tts.setVolume(1);
      await _tts.setPitch(1);
      await _tts.setSpeechRate(0.46 * _speed);
      if (!_stopped) await _speakFromOffset();
    } catch (error) {
      if (!_stopped) _onError?.call(error.toString());
    }
  }

  int _speechStart = 0;

  Future<void> _speakFromOffset() async {
    if (_stopped || _paused || _offset >= _text.length) return;
    _speechStart = _offset;
    try {
      await _tts.speak(_text.substring(_offset));
    } catch (error) {
      if (!_stopped) _onError?.call(error.toString());
    }
  }

  @override
  Future<void> pause() async {
    _paused = true;
    try {
      await _tts.stop();
    } catch (error) {
      if (!_stopped) _onError?.call(error.toString());
    }
  }

  @override
  Future<void> resume() async {
    if (_stopped || _text.isEmpty) return;
    if (_offset >= _text.length) _offset = 0;
    _paused = false;
    await _speakFromOffset();
  }

  @override
  Future<void> seek(double fraction) async {
    if (_stopped || _text.isEmpty) return;
    _offset = (_text.length * fraction.clamp(0.0, 1.0)).round();
    try {
      await _tts.stop();
    } catch (error) {
      if (!_stopped) _onError?.call(error.toString());
      return;
    }
    if (!_paused) await _speakFromOffset();
  }

  @override
  Future<void> setSpeed(double value) async {
    _speed = value;
    try {
      await _tts.setSpeechRate((0.46 * value).clamp(0.1, 1.0).toDouble());
    } catch (error) {
      if (!_stopped) _onError?.call(error.toString());
      return;
    }
    if (_stopped || _paused || _text.isEmpty) return;
    try {
      await _tts.stop();
    } catch (error) {
      if (!_stopped) _onError?.call(error.toString());
      return;
    }
    await _speakFromOffset();
  }

  @override
  Future<void> stop() async {
    _stopped = true;
    _paused = true;
    _onProgress = null;
    _onComplete = null;
    _onError = null;
    try {
      await _tts.stop();
    } catch (_) {
      // The plugin is optional in widget tests; disposal must stay safe.
    }
  }
}
