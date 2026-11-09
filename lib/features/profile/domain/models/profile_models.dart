import 'dart:typed_data';

/// UI-only profile and menu definitions, with no backend dependency.
class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarAsset,
    this.phone,
    this.about,
    this.avatarBytes,
  });

  final String id;
  final String fullName;
  final String email;
  final String avatarAsset;
  final String? phone;
  final String? about;
  final Uint8List? avatarBytes;

  ProfileUser copyWith({
    String? fullName,
    String? email,
    String? about,
    Uint8List? avatarBytes,
  }) => ProfileUser(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        avatarAsset: avatarAsset,
        phone: phone,
        about: about ?? this.about,
        avatarBytes: avatarBytes ?? this.avatarBytes,
      );
}

enum ProfileMenuAction {
  myProfile,
  about,
  merchandise,
  privacy,
  terms,
  deleteAccount,
  logout,
}

enum ProfileMenuIconTone { primary, danger }

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.action,
    required this.title,
    required this.description,
    required this.showChevron,
    this.iconAsset,
    this.tone = ProfileMenuIconTone.primary,
  });

  final ProfileMenuAction action;
  final String title;
  final String? description;
  final String? iconAsset;
  final ProfileMenuIconTone tone;
  final bool showChevron;
}
