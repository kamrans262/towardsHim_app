import 'dart:async';

/// Prevents a stuck Android Keystore/secure-storage read from keeping the
/// splash screen visible forever. The reader returns null on failure and
/// never publishes credentials from a read that finishes after timeout.
Future<List<String?>?> readStoredSessionValues({
  required Future<String?> Function(String key) read,
  required String tokenKey,
  required String userKey,
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    return await Future.wait<String?>([
      read(tokenKey),
      read(userKey),
    ]).timeout(timeout);
  } catch (_) {
    // An unavailable keystore is not a reason to block access to Welcome.
    // No saved credentials are deleted here; the member can retry login.
    return null;
  }
}
