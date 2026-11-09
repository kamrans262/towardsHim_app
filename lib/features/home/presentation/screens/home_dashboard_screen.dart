import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../data/home_demo_data.dart';
import '../../domain/models/home_models.dart';
import '../widgets/home_continue_listening_card.dart';
import '../widgets/home_featured_card.dart';
import '../widgets/home_hero_header.dart';
import '../widgets/home_quick_access_card.dart';
import '../widgets/home_recent_activity_card.dart';

/// Scrollable Home content; kept alive by the parent IndexedStack.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    required this.onSelectTab,
    required this.onNotice,
    this.onNotifications,
    super.key,
  });

  final ValueChanged<HomeTab> onSelectTab;
  final ValueChanged<String> onNotice;
  final VoidCallback? onNotifications;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('home_dashboard_scroll'),
      slivers: [
        SliverToBoxAdapter(child: _hero(context)),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.homeContentMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.homeSectionGap,
                  AppSpacing.screenHorizontal,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppSectionHeading('Continue Where You Left Off'),
                    const SizedBox(height: AppSpacing.homeHeaderToCardGap),
                    HomeContinueListeningCard(
                      audio: HomeDemoData.listening,
                      isPlaying: _isPlaying,
                      onPlayPressed: () {
                        setState(() => _isPlaying = !_isPlaying);
                      },
                    ),
                    const SizedBox(height: AppSpacing.homeSectionGap),
                    const AppSectionHeading('Quick Access'),
                    const SizedBox(height: AppSpacing.homeSectionGap),
                    Row(
                      children: [
                        for (var i = 0;
                            i < HomeDemoData.quickAccess.length;
                            i++) ...[
                          if (i != 0)
                            const SizedBox(width: AppSpacing.homeQuickGap),
                          Expanded(
                            child: HomeQuickAccessCard(
                              item: HomeDemoData.quickAccess[i],
                              onPressed: () =>
                                  widget.onSelectTab(HomeTab.listen),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.homeSectionGap),
                    Row(
                      children: [
                        const Expanded(child: AppSectionHeading('Recent Activity')),
                        TextButton(
                          onPressed: () =>
                              widget.onNotice('Activity history UI is coming soon.'),
                          child: Text(
                            'See all',
                            style: AppTypography.homeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.homeHeaderToCardGap),
                    for (var i = 0;
                        i < HomeDemoData.recentActivities.length;
                        i++) ...[
                      if (i != 0)
                        const SizedBox(height: AppSpacing.homeHeaderToCardGap),
                      HomeRecentActivityCard(
                        activity: HomeDemoData.recentActivities[i],
                        onPressed: () =>
                            widget.onNotice('Activity detail UI is coming soon.'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hero(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: AppSpacing.homeHeroHeight,
          child: Image.asset(
            HomeDemoData.heroAsset,
            key: const Key('home_hero_image'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Column(
          children: [
            const SizedBox(height: AppSpacing.homeHeroCardTop),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.homeContentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: HomeFeaturedCard(
                    content: HomeDemoData.featured,
                    onPressed: () => widget.onNotice(
                      'Featured content UI is coming soon.',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + AppSpacing.screenTop,
          left: 0,
          right: 0,
          child: HomeHeroHeader(
            profile: HomeDemoData.profile,
            onNotifications: widget.onNotifications ??
                                    () => widget.onNotice(
                                      'Notifications UI is coming soon.',
                                    ),
            onProfile: () => widget.onNotice('Profile UI is coming soon.'),
          ),
        ),
      ],
    );
  }
}
