import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../../auth/data/auth_repository.dart';
import '../../data/profile_demo_data.dart';
import '../../domain/models/profile_models.dart';

/// Profile state backed by the member API. Screen layout stays unchanged.
class ProfileController extends ChangeNotifier {
  ProfileController() {
    final profile = AuthRepository.instance.user;
    if (profile != null) _user = _fromApi(profile);
  }

  ProfileUser _user = ProfileDemoData.user;
  ProfileUser get user => _user;

  ProfileUser _fromApi(Map<String, dynamic> data) => ProfileUser(
        id: data['id']?.toString() ?? '',
        fullName: data['name']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        avatarAsset: ProfileDemoData.user.avatarAsset,
        about: data['bio']?.toString() ?? '',
        avatarUrl: data['avatar_url']?.toString(),
      );

  Future<void> update({
    required String fullName,
    required String email,
    required String bio,
    Uint8List? photoBytes,
  }) async {
    if (AuthRepository.instance.isAuthenticated) {
      var updated = await AuthRepository.instance.updateProfile(
        name: fullName,
        email: email,
        bio: bio,
      );
      if (photoBytes != null) {
        updated = await AuthRepository.instance.uploadAvatar(photoBytes);
      }
      _user = _fromApi(updated).copyWith(avatarBytes: photoBytes);
    } else {
      // Guests retain the same local-only preview behavior.
      _user = _user.copyWith(
        fullName: fullName.trim(),
        email: email.trim(),
        about: bio.trim(),
        avatarBytes: photoBytes,
      );
    }
    notifyListeners();
  }
}
