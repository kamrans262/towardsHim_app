import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/navigation/app_router.dart';
import '../../data/home_demo_data.dart';
import '../../domain/models/home_models.dart';
import '../controllers/home_navigation_controller.dart';
import 'home_dashboard_screen.dart';
import '../../../listen/presentation/screens/listen_screen.dart';
import '../../../listen/domain/models/listen_audio_episode.dart';
import '../../../weekly_challenges/presentation/screens/weekly_challenges_screen.dart';
import '../../../weekly_challenges/domain/models/weekly_challenge.dart';
import '../../../community/presentation/screens/community_screen.dart';

/// UI-only shell with a fixed bottom bar and preserved tab widget states.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late final HomeNavigationController _navigation;

  @override
  void initState() {
    super.initState();
    _navigation = HomeNavigationController();
  }

  @override
  void dispose() {
    _navigation.dispose();
    super.dispose();
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _select(HomeTab tab) {
    _navigation.select(tab);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AnimatedBuilder(
        animation: _navigation,
        builder: (context, _) {
          final selected = _navigation.selected;
          return Scaffold(
            key: const Key('home_shell'),
            backgroundColor: AppColors.background,
            body: IndexedStack(
              index: selected.index,
              children: [
                HomeDashboardScreen(
                  onSelectTab: _select,
                  onNotice: _showNotice,
                ),
                ListenScreen(
                  onNotice: _showNotice,
                  onOpenEpisode: (ListenAudioEpisode episode) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.player,
                      arguments: episode,
                    );
                  },
                ),
                WeeklyChallengesScreen(
                  onNotice: _showNotice,
                  onOpenChallenge: (WeeklyChallenge challenge) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.weeklyChallengeDetail,
                      arguments: challenge,
                    );
                  },
                ),
                CommunityScreen(onNotice: _showNotice),
                const _UpcomingTab(
                  title: 'Store',
                  message: 'Merchandise Store URL has not been configured.',
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
