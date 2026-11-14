import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../auth/data/auth_repository.dart';

/// Firebase hooks are prewired but opt-in until provider credentials are added.
/// Enables native Android/iOS pushes without changing existing UI.
class PushRegistrationService {
  PushRegistrationService._();
  static final instance = PushRegistrationService._();

  static const enabled = bool.fromEnvironment(
    'TOWARD_HIM_PUSH_ENABLED', defaultValue: false,
  );

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openSubscription;
  String? _token;
  bool _started = false;

  Future<void> start({
    required VoidCallback onMessage,
    required ValueChanged<String> onOpenAudio,
  }) async {
    if (!enabled || _started || !AuthRepository.instance.isAuthenticated) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) return;

    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      final permission = await messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );
      if (permission.authorizationStatus == AuthorizationStatus.denied) return;

      _token = await messaging.getToken();
      if (_token != null) await _register(_token!);

      _tokenSubscription = messaging.onTokenRefresh.listen((token) {
        _token = token;
        unawaited(_register(token));
      });

      _messageSubscription = FirebaseMessaging.onMessage.listen((message) {
        onMessage();
      });
      _openSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final audioId = message.data['audio_id'];
        if (audioId is String && audioId.isNotEmpty) onOpenAudio(audioId);
      });
      final initial = await messaging.getInitialMessage();
      final initialAudioId = initial?.data['audio_id'];
      if (initialAudioId is String && initialAudioId.isNotEmpty) {
        onOpenAudio(initialAudioId);
      }
      _started = true;
    } catch (_) {
      // No provider files until Firebase is deliberately connected.
      await stop(unregister: false);
    }
  }

  Future<void> _register(String token) async {
    try {
      if (!AuthRepository.instance.isAuthenticated) return;
      await AuthRepository.instance.memberRequest(
        'POST', 'devices/push',
        body: {
          'token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        },
      );
    } catch (_) {
      // In-app notifications continue even when FCM cannot be registered.
    }
  }

  Future<void> stop({bool unregister = true}) async {
    final token = _token;
    if (unregister && token != null && AuthRepository.instance.isAuthenticated) {
      try {
        await AuthRepository.instance.memberRequest(
          'DELETE', 'devices/push', body: {'token': token},
        );
      } catch (_) {}
    }
    await _tokenSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openSubscription?.cancel();
    _tokenSubscription = null;
    _messageSubscription = null;
    _openSubscription = null;
    _started = false;
    _token = null;
  }
}
