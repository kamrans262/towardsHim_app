import '../domain/models/profile_models.dart';

/// Figma text fixtures for the UI-only delete-account flow.
abstract final class DeleteAccountDemoData {
  static const warningItem = ProfileMenuItem(
    action: ProfileMenuAction.deleteAccount,
    title: 'This action cannot be undone',
    description:
        'Deleting your account will permanently remove your data and '
        'activity. This action cannot be undone.',
    showChevron: true,
    tone: ProfileMenuIconTone.danger,
  );

  static const bullets = <String>[
    'You will lose access to all voice content, challenges and community features',
    'Your progress and saved contents will be permanently deleted',
    'This action cannot be reversed',
  ];

  static const informationItem = ProfileMenuItem(
    action: ProfileMenuAction.about,
    title:
        'If you change your mind you can always create new account in future',
    description: null,
    showChevron: true,
  );

  static const confirmationTitle = 'Delete Account?';
  static const confirmationDescription =
      'Are you sure you want to permanently delete your account? '
      'This action cannot be undone.';
  static const demoNotice = 'Demo only: no account or data was deleted.';
}
