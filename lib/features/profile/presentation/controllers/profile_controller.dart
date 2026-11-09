import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../data/profile_demo_data.dart';
import '../../domain/models/profile_models.dart';

/// Local, session-scoped profile state until the account backend is connected.
class ProfileController extends ChangeNotifier {
  ProfileUser _user = ProfileDemoData.user;

  ProfileUser get user => _user;

  void update({
    required String fullName,
    required String email,
    required String bio,
    Uint8List? photoBytes,
  }) {
    _user = _user.copyWith(
      fullName: fullName.trim(),
      email: email.trim(),
      about: bio.trim(),
      avatarBytes: photoBytes,
    );
    notifyListeners();
  }
}
