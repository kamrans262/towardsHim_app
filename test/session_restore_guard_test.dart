import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:towards_him_app/features/auth/data/session_restore_guard.dart';

void main() {
  test('restores the token and member profile when storage works', () async {
    final keys = <String>[];
    final values = await readStoredSessionValues(
      read: (key) async {
        keys.add(key);
        return key == 'token' ? 'member-token' : '{"name":"Member"}';
      },
      tokenKey: 'token',
      userKey: 'user',
    );

    expect(keys, containsAll(['token', 'user']));
    expect(values, ['member-token', '{"name":"Member"}']);
  });

  test('does not block startup if Android secure storage throws', () async {
    final values = await readStoredSessionValues(
      read: (key) async => throw StateError('Keystore unavailable'),
      tokenKey: 'token',
      userKey: 'user',
    );

    expect(values, isNull);
  });

  test('does not block startup if a secure storage read never completes',
      () async {
    final hangingRead = Completer<String?>();
    final values = await readStoredSessionValues(
      read: (key) => key == 'token'
          ? hangingRead.future
          : Future<String?>.value('cached-user'),
      tokenKey: 'token',
      userKey: 'user',
      timeout: const Duration(milliseconds: 20),
    );

    expect(values, isNull);
    // The delayed read cannot inject a token into the already returned result.
    hangingRead.complete('late-token');
    await Future<void>.delayed(Duration.zero);
    expect(values, isNull);
  });
}
