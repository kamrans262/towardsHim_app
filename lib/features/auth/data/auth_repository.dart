import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// A pending email code check. This is deliberately not a signed-in session.
class LoginOtpChallenge {
  const LoginOtpChallenge({
    required this.challenge,
    required this.email,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
  });

  final String challenge;
  final String email;
  final int expiresInSeconds;
  final int resendAfterSeconds;

  factory LoginOtpChallenge.fromApi(Map<String, dynamic> data) {
    final challenge = data['challenge'];
    final email = data['email'];
    if (challenge is! String || challenge.length != 64 || email is! String) {
      throw const AuthFailure('Incomplete verification response.');
    }
    return LoginOtpChallenge(
      challenge: challenge,
      email: email,
      expiresInSeconds: (data['expires_in_seconds'] as num?)?.toInt() ?? 600,
      resendAfterSeconds: (data['resend_after_seconds'] as num?)?.toInt() ?? 60,
    );
  }
}

/// A shared authentication gateway; no networking or token handling in widgets.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository._();
  static final instance = AuthRepository._();

  static const String baseUrl = String.fromEnvironment(
    'TOWARD_HIM_API_URL',
    defaultValue: 'https://chocolate-goldfish-405384.hostingersite.com/api/v1',
  );
  static const String googleWebClientId = String.fromEnvironment(
    'TOWARD_HIM_GOOGLE_WEB_CLIENT_ID',
  );
  static const String appleServiceId = String.fromEnvironment(
    'TOWARD_HIM_APPLE_SERVICE_ID',
  );
  static const String appleRedirectUri = String.fromEnvironment(
    'TOWARD_HIM_APPLE_REDIRECT_URI',
  );

  static const _tokenKey = 'toward_him_member_token';
  static const _userKey = 'toward_him_member_user';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  Map<String, dynamic>? _user;
  bool _googleInitialized = false;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  Map<String, dynamic>? get user => _user == null ? null : Map.unmodifiable(_user!);

  /// Restore session before showing an already signed-in member the home UI.
  Future<bool> restoreSession() async {
    _token = await _storage.read(key: _tokenKey);
    final storedUser = await _storage.read(key: _userKey);
    if (storedUser != null) {
      try {
        _user = Map<String, dynamic>.from(jsonDecode(storedUser) as Map);
      } catch (_) {
        _user = null;
      }
    }
    return isAuthenticated;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authorized = false,
  }) async {
    final uri = Uri.parse('$baseUrl/$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (authorized && isAuthenticated) 'Authorization': 'Bearer $_token',
    };
    final encoded = body == null ? null : jsonEncode(body);

    try {
      final Future<http.Response> pending = switch (method) {
        'POST' => http.post(uri, headers: headers, body: encoded),
        'PATCH' => http.patch(uri, headers: headers, body: encoded),
        'PUT' => http.put(uri, headers: headers, body: encoded),
        'DELETE' => http.delete(uri, headers: headers, body: encoded),
        _ => http.get(uri, headers: headers),
      };
      final response = await pending.timeout(const Duration(seconds: 20));
      final decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (decoded is! Map) {
        throw const AuthFailure('Unexpected server response.');
      }
      final payload = Map<String, dynamic>.from(decoded);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (authorized && response.statusCode == 401) {
          await _clearLocal();
        }
        final errors = payload['errors'];
        String message = payload['message']?.toString() ?? 'Request failed.';
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        }
        throw AuthFailure(message);
      }
      return payload;
    } on AuthFailure {
      rethrow;
    } on FormatException {
      throw const AuthFailure('Unexpected server response.');
    } catch (_) {
      throw const AuthFailure('Unable to connect. Check your internet connection.');
    }
  }

  /// Shared authenticated requests for member features.
  Future<Map<String, dynamic>> memberRequest(
    String method, String path, {Map<String, dynamic>? body}
  ) {
    if (!isAuthenticated) {
      throw const AuthFailure('Please sign in to use this feature.');
    }
    return _request(method, path, body: body, authorized: true);
  }

  Future<void> _storeLogin(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(payload['data'] as Map);
    final token = data['token'];
    final user = data['user'];
    if (token is! String || user is! Map) {
      throw const AuthFailure('Incomplete authentication response.');
    }
    _token = token;
    _user = Map<String, dynamic>.from(user);
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(_user));
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await _request('POST', 'auth/register', body: {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': confirmPassword,
    });
    await _storeLogin(result);
  }

  Future<LoginOtpChallenge> login({
    required String email,
    required String password,
  }) async {
    final result = await _request('POST', 'auth/login', body: {
      'email': email.trim(),
      'password': password,
    });
    // The password step must not store a token; only OTP verify issues one.
    return LoginOtpChallenge.fromApi(
      Map<String, dynamic>.from(result['data'] as Map),
    );
  }

  Future<void> verifyLoginOtp({
    required String challenge,
    required String code,
  }) async {
    final result = await _request('POST', 'auth/login/verify', body: {
      'challenge': challenge,
      'code': code.trim(),
    });
    await _storeLogin(result);
  }

  Future<int> resendLoginOtp({required String challenge}) async {
    final result = await _request('POST', 'auth/login/resend', body: {
      'challenge': challenge,
    });
    final data = Map<String, dynamic>.from(result['data'] as Map);
    return (data['resend_after_seconds'] as num?)?.toInt() ?? 60;
  }

  Future<String> _googleIdentityToken() async {
    final signIn = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await signIn.initialize(
        serverClientId: googleWebClientId.isEmpty ? null : googleWebClientId,
      );
      _googleInitialized = true;
    }
    if (!signIn.supportsAuthenticate()) {
      throw const AuthFailure('Google sign-in is not supported on this device.');
    }
    final account = await signIn.authenticate();
    final identityToken = account.authentication.idToken;
    if (identityToken == null) {
      throw const AuthFailure('Google identity token unavailable. Check provider setup.');
    }
    return identityToken;
  }

  Future<void> signInWithGoogle() async {
    final identityToken = await _googleIdentityToken();
    final response = await _request(
      'POST',
      'auth/google',
      body: {'identity_token': identityToken},
    );
    await _storeLogin(response);
  }

  Future<String> _appleIdentityToken() async {
    final requiresWeb = defaultTargetPlatform == TargetPlatform.android;
    if (requiresWeb && (appleServiceId.isEmpty || appleRedirectUri.isEmpty)) {
      throw const AuthFailure('Apple sign-in setup is not connected yet.');
    }
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      webAuthenticationOptions: requiresWeb
          ? WebAuthenticationOptions(
              clientId: appleServiceId,
              redirectUri: Uri.parse(appleRedirectUri),
            )
          : null,
    );
    final identityToken = credential.identityToken;
    if (identityToken == null) {
      throw const AuthFailure('Apple identity token unavailable.');
    }
    return identityToken;
  }

  Future<void> signInWithApple() async {
    final identityToken = await _appleIdentityToken();
    final response = await _request(
      'POST',
      'auth/apple',
      body: {'identity_token': identityToken},
    );
    await _storeLogin(response);
  }

  Future<void> deleteSocialAccount(String provider) async {
    if (!isAuthenticated) {
      throw const AuthFailure('Sign in to delete your account.');
    }
    final identityToken = provider == 'google'
        ? await _googleIdentityToken()
        : await _appleIdentityToken();
    await _request('POST', 'auth/account/revoke-social',
        authorized: true,
        body: {'provider': provider, 'identity_token': identityToken});
    await _clearLocal();
  }

  Future<void> sendRecoveryCode(String email) async {
    await _request('POST', 'auth/password/send-code', body: {
      'email': email.trim(),
    });
  }

  Future<String> verifyRecoveryCode(String email, String code) async {
    final result = await _request('POST', 'auth/password/verify-code', body: {
      'email': email.trim(),
      'code': code.trim(),
    });
    return (result['data'] as Map)['reset_ticket'] as String;
  }

  Future<void> resetPassword({
    required String email,
    required String ticket,
    required String password,
    required String confirmation,
  }) async {
    await _request('POST', 'auth/password/reset', body: {
      'email': email.trim(),
      'reset_ticket': ticket,
      'password': password,
      'password_confirmation': confirmation,
    });
  }

  Future<Map<String, dynamic>> refreshProfile() async {
    final result = await _request('GET', 'auth/me', authorized: true);
    _user = Map<String, dynamic>.from(result['data'] as Map);
    await _storage.write(key: _userKey, value: jsonEncode(_user));
    return _user!;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String bio,
  }) async {
    final result = await _request('PATCH', 'auth/profile', authorized: true, body: {
      'name': name.trim(),
      'email': email.trim(),
      'bio': bio.trim(),
    });
    _user = Map<String, dynamic>.from(result['data'] as Map);
    await _storage.write(key: _userKey, value: jsonEncode(_user));
    return _user!;
  }

  Future<Map<String, dynamic>> uploadAvatar(Uint8List bytes) async {
    if (!isAuthenticated) throw const AuthFailure('Sign in to save your profile photo.');
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/avatar'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });
      request.files.add(http.MultipartFile.fromBytes('avatar', bytes, filename: 'avatar.jpg'));
      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      final payload = jsonDecode(response.body) as Map;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AuthFailure(payload['message']?.toString() ?? 'Photo upload failed.');
      }
      _user = Map<String, dynamic>.from(payload['data'] as Map);
      await _storage.write(key: _userKey, value: jsonEncode(_user));
      return _user!;
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Unable to upload profile photo.');
    }
  }

  Future<void> deleteAccount(String password) async {
    await _request('DELETE', 'auth/account', authorized: true, body: {
      'password': password,
    });
    await _clearLocal();
  }

  Future<void> logout() async {
    try {
      if (isAuthenticated) await _request('POST', 'auth/logout', authorized: true);
    } finally {
      await _clearLocal();
    }
  }

  Future<void> _clearLocal() async {
    _token = null;
    _user = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
