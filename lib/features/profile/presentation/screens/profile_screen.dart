
import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_main_screen_header.dart';
import '../../data/profile_demo_data.dart';
import '../../domain/models/profile_models.dart';
import '../widgets/profile_user_card.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_menu_card.dart';

/// Main-shell Profile page: the parent keeps the original five-tab bar fixed.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.controller,
    required this.onNotifications,
    required this.onNotice,
    required this.onLogout,
    super.key,
  });

  final ProfileController controller;
  final VoidCallback onNotifications;
  final ValueChanged<String> onNotice;
  final VoidCallback onLogout;

  void _activate(BuildContext context, ProfileMenuAction action) {
    switch (action) {
      case ProfileMenuAction.myProfile:
        Navigator.of(context).pushNamed(AppRoutes.editProfile, arguments: controller);
        return;
      case ProfileMenuAction.about:
        Navigator.of(context).pushNamed(AppRoutes.aboutTowardHim);
        return;
      case ProfileMenuAction.merchandise:
        onNotice('Merchandise Store URL is not configured yet.');
        return;
      case ProfileMenuAction.privacy:
        Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
        return;
      case ProfileMenuAction.terms:
        Navigator.of(context).pushNamed(AppRoutes.termsOfService);
        return;
      case ProfileMenuAction.deleteAccount:
        Navigator.of(context).pushNamed(AppRoutes.deleteAccount);
        return;
      case ProfileMenuAction.logout:
        onLogout();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SafeArea(
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
                        user: controller.user,
                        onEdit: () => Navigator.of(context).pushNamed(
                          AppRoutes.editProfile,
                          arguments: controller,
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
    ),
    );
  }
}
