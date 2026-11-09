
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_main_screen_header.dart';
import '../../data/profile_demo_data.dart';
import '../../domain/models/profile_models.dart';
import '../widgets/profile_user_card.dart';
import '../widgets/profile_menu_card.dart';

/// Main-shell Profile page: the parent keeps the original five-tab bar fixed.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.onNotifications,
    required this.onNotice,
    required this.onLogout,
    super.key,
  });

  final VoidCallback onNotifications;
  final ValueChanged<String> onNotice;
  final VoidCallback onLogout;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.outlinedButtonBackground,
        title: const Text(
          'Delete Account?',
          style: AppTypography.sectionHeading,
        ),
        content: const Text(
          'Account deletion is permanent. This is a UI demo; '
          'confirming will not delete your account or any data.',
          style: AppTypography.homeSecondary,
        ),
        actions: [
          TextButton(
            key: const Key('profile_delete_cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('profile_delete_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Color(0xFFE32222)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onNotice('Demo only: no account or data was deleted.');
    }
  }

  void _activate(BuildContext context, ProfileMenuAction action) {
    switch (action) {
      case ProfileMenuAction.myProfile:
        onNotice('My Profile details UI is coming soon.');
        return;
      case ProfileMenuAction.about:
        onNotice('About toward HIM UI is coming soon.');
        return;
      case ProfileMenuAction.merchandise:
        onNotice('Merchandise Store URL is not configured yet.');
        return;
      case ProfileMenuAction.privacy:
        onNotice('Privacy Policy UI is coming soon.');
        return;
      case ProfileMenuAction.terms:
        onNotice('Terms of Service UI is coming soon.');
        return;
      case ProfileMenuAction.deleteAccount:
        _confirmDelete(context);
        return;
      case ProfileMenuAction.logout:
        onLogout();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const Key('profile_scroll'),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.homeContentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.screenTop,
                    AppSpacing.screenHorizontal,
                    AppSpacing.screenBottom,
                  ),
                  child: Column(
                    key: const Key('profile_screen'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppMainScreenHeader(
                        title: 'Profile',
                        onNotifications: onNotifications,
                        onProfile: () {},
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ProfileDemoData.description,
                        style: AppTypography.description.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ProfileUserCard(
                        user: ProfileDemoData.user,
                        onEdit: () => onNotice(
                          'Edit Profile UI is coming soon.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (var index = 0;
                          index < ProfileDemoData.menu.length;
                          index++) ...[
                        if (index > 0) const SizedBox(height: 20),
                        ProfileMenuCard(
                          key: ValueKey(ProfileDemoData.menu[index].action),
                          item: ProfileDemoData.menu[index],
                          onPressed: () => _activate(
                            context,
                            ProfileDemoData.menu[index].action,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
