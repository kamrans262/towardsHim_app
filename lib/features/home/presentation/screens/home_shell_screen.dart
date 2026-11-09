import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../data/home_demo_data.dart';
import '../../domain/models/home_models.dart';
import '../controllers/home_navigation_controller.dart';
import 'home_dashboard_screen.dart';
import '../../../listen/presentation/screens/listen_screen.dart';
import '../../../listen/data/spoken_demo_data.dart';
import '../../../listen/domain/models/listen_audio_episode.dart';
import '../../../weekly_challenges/presentation/screens/weekly_challenges_screen.dart';
import '../../../weekly_challenges/domain/models/weekly_challenge.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

/// UI-only shell with a fixed bottom bar and preserved tab widget states.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late final HomeNavigationController _navigation;
  late final NotificationsController _notifications;
  late final ProfileController _profile;
  late final Listenable _shellListeners;
  bool _showProfile = false;

  @override
  void initState() {
    super.initState();
    _navigation = HomeNavigationController();
    _notifications = NotificationsController();
    _profile = ProfileController();
    _shellListeners = Listenable.merge([_navigation, _profile]);
  }

  @override
  void dispose() {
    _navigation.dispose();
    _notifications.dispose();
    _profile.dispose();
    super.dispose();
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openNotifications() {
    Navigator.of(context).pushNamed(
      AppRoutes.notifications,
      arguments: _notifications,
    );
  }

  void _openQuickMedia(HomeQuickType type) {
    Navigator.of(context).pushNamed(
      AppRoutes.player,
      arguments: SpokenDemoData.forCategory(type),
    );
  }

  void _openProfile() {
    if (_showProfile) return;
    setState(() => _showProfile = true);
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.welcome,
      (route) => false,
    );
  }

  void _select(HomeTab tab) {
    _navigation.select(tab);
    if (_showProfile) setState(() => _showProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AnimatedBuilder(
        animation: _shellListeners,
        builder: (context, _) {
          final selected = _navigation.selected;
          return Scaffold(
            key: const Key('home_shell'),
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                Offstage(
                  offstage: _showProfile,
                  child: IndexedStack(
                    index: selected.index,
              children: [
                HomeDashboardScreen(
                  firstName: _profile.user.fullName.trim().split(RegExp(r'\s+')).first,
                  onSelectTab: _select,
                  onOpenQuickMedia: _openQuickMedia,
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                ),
                ListenScreen(
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                  onOpenQuickMedia: _openQuickMedia,
                  onOpenEpisode: (ListenAudioEpisode episode) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.player,
                      arguments: episode,
                    );
                  },
                ),
                WeeklyChallengesScreen(
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                  onOpenChallenge: (WeeklyChallenge challenge) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.weeklyChallengeDetail,
                      arguments: challenge,
                    );
                  },
                ),
                CommunityScreen(
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                ),
                const _UpcomingTab(
                  title: 'Store',
                  message: 'Merchandise Store URL has not been configured.',
                ),
                  ],
                ),
              ),
              if (_showProfile)
                ProfileScreen(
                  controller: _profile,
                  onNotifications: _openNotifications,
                  onNotice: _showNotice,
                  onLogout: _logout,
                ),
              ],
            ),
            bottomNavigationBar: AppBottomNavigation(
              items: [
                for (final item in HomeDemoData.navigation)
                  AppBottomNavigationDestination(
                    label: item.label,
                    iconAsset: item.iconAsset,
                  ),
              ],
              selectedIndex: selected.index,
              onSelected: (index) {
                final tab = HomeDemoData.navigation[index].tab;
                // No external store URL was supplied; a local placeholder
                // is shown instead of inventing an outbound destination.
                _select(tab);
              },
            ),
          );
        },
      ),
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  const _UpcomingTab({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.homeContentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: AppTypography.description,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
