
import '../../community/data/community_demo_data.dart';
import '../domain/models/profile_models.dart';

/// Static profile design fixture; values can be replaced in a later API phase.
abstract final class ProfileDemoData {
  static const user = ProfileUser(
    id: CommunityDemoData.currentUserId,
    fullName: CommunityDemoData.currentUserName,
    email: 'sarah@gmail.com',
    avatarAsset: CommunityDemoData.avatarAsset,
    phone: '',
    about: '',
  );

  static const description =
      'Your all information regarding toward HIM is here';

  static const menu = <ProfileMenuItem>[
    ProfileMenuItem(
      action: ProfileMenuAction.myProfile,
      title: 'My Profile',
      description: 'Name, email, phone and photo',
      showChevron: true,
    ),
    ProfileMenuItem(
      action: ProfileMenuAction.about,
      title: 'About toward HIM',
      description: 'Our missions, values and vision',
      showChevron: true,
    ),
    ProfileMenuItem(
      action: ProfileMenuAction.merchandise,
      title: 'Merchendise Service',
      description: 'Shop faith inspired products',
      showChevron: true,
    ),
    ProfileMenuItem(
      action: ProfileMenuAction.privacy,
      title: 'Privacy Policy',
      description: 'Password, and active sessions',
      showChevron: true,
    ),
    ProfileMenuItem(
      action: ProfileMenuAction.terms,
      title: 'Terms of service',
      description: 'Password, and active sessions',
      showChevron: true,
    ),
    ProfileMenuItem(
      action: ProfileMenuAction.deleteAccount,
      title: 'Delete Account',
      description: 'Permanently delete your account',
      showChevron: true,
      tone: ProfileMenuIconTone.danger,
    ),
    ProfileMenuItem(
      action: ProfileMenuAction.logout,
      title: 'Log Out',
      description: null,
      showChevron: false,
    ),
  ];
}
