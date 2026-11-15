import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../data/home_demo_data.dart';
import '../../domain/models/home_models.dart';
import '../../../weekly_challenges/domain/models/weekly_challenge.dart';
import '../../../listen/domain/models/listen_audio_episode.dart';
import '../widgets/home_continue_listening_card.dart';
import '../widgets/home_featured_card.dart';
import '../widgets/home_hero_header.dart';
import '../widgets/home_quick_access_card.dart';
import '../widgets/home_recent_activity_card.dart';

/// Scrollable Home content; kept alive by the parent IndexedStack.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    required this.onSelectTab,
    this.firstName,
    this.currentChallenge,
    this.onOpenChallenge,
    this.publishedAudio = const [],
    this.audioLoading = false,
    this.audioError,
    this.onRefreshAudio,
    this.onOpenAudio,
    this.guestMode = false,
    this.onLoginRequired,
    required this.onNotice,
    this.onNotifications,
    this.onProfile,
    this.onOpenQuickMedia,
    super.key,
  });

  final ValueChanged<HomeTab> onSelectTab;
  final String? firstName;
  final WeeklyChallenge? currentChallenge;
  final ValueChanged<WeeklyChallenge>? onOpenChallenge;
  final List<ListenAudioEpisode> publishedAudio;
  final bool audioLoading;
  final String? audioError;
  final VoidCallback? onRefreshAudio;
  final ValueChanged<ListenAudioEpisode>? onOpenAudio;
  final bool guestMode;
  final VoidCallback? onLoginRequired;
  final ValueChanged<String> onNotice;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;
  final ValueChanged<HomeQuickType>? onOpenQuickMedia;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {

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
                    const AppSectionHeading('Latest Audio'),
                    const SizedBox(height: AppSpacing.homeHeaderToCardGap),
                    if (widget.audioLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (widget.audioError != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unable to load audio right now.',
                              style: AppTypography.homeSecondary),
                          TextButton(
                            onPressed: widget.onRefreshAudio,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    else if (widget.publishedAudio.isEmpty)
                      const Text('No audio published yet.',
                          style: AppTypography.homeSecondary)
                    else
                      HomeContinueListeningCard(
                        audio: HomeListeningProgress(
                          id: widget.publishedAudio.first.id,
                          title: widget.publishedAudio.first.title,
                          type: widget.publishedAudio.first.contentType,
                          minutesRemaining: widget.publishedAudio.first.durationMinutes,
                          progress: 0,
                          imageAsset: widget.publishedAudio.first.thumbnailAsset,
                          imageUrl: widget.publishedAudio.first.artworkUrl,
                        ),
                        isPlaying: false,
                        onPlayPressed: () {
                          final episode = widget.publishedAudio.first;
                          if (widget.onOpenAudio != null) {
                            widget.onOpenAudio!(episode);
                          } else {
                            widget.onSelectTab(HomeTab.listen);
                          }
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
                              onPressed: () {
                                final action = widget.onOpenQuickMedia;
                                if (action != null) {
                                  action(HomeDemoData.quickAccess[i].type);
                                } else {
                                  widget.onSelectTab(HomeTab.listen);
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.homeSectionGap),
                    if (widget.publishedAudio.length > 1) ...[
                      Row(
                        children: [
                          const Expanded(
                            child: AppSectionHeading('Recently Published'),
                          ),
                          TextButton(
                            onPressed: () => widget.onSelectTab(HomeTab.listen),
                            child: Text('See all', style: AppTypography.homeAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.homeHeaderToCardGap),
                      for (var i = 1;
                          i < widget.publishedAudio.length && i < 3;
                          i++) ...[
                        if (i != 1)
                          const SizedBox(height: AppSpacing.homeHeaderToCardGap),
                        HomeRecentActivityCard(
                          activity: HomeRecentActivity(
                            id: widget.publishedAudio[i].id,
                            title: widget.publishedAudio[i].title,
                            type: widget.publishedAudio[i].contentType,
                            status: 'Available',
                            imageAsset: widget.publishedAudio[i].thumbnailAsset,
                            imageUrl: widget.publishedAudio[i].artworkUrl,
                            showCompletedIcon: false,
                          ),
                          onPressed: () {
                            if (widget.onOpenAudio != null) {
                              widget.onOpenAudio!(widget.publishedAudio[i]);
                            } else {
                              widget.onSelectTab(HomeTab.listen);
                            }
                          },
                        ),
                      ],
                    ],
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
                    content: widget.currentChallenge == null
                        ? HomeFeaturedContent(
                            id: 'challenge-information',
                            category: 'Weekly Toward HIM 3',
                            title: widget.guestMode
                                ? 'Start Your Weekly Journey'
                                : 'No Current Challenge',
                            description: widget.guestMode
                                ? 'Sign in to take part and track your progress.'
                                : 'Check back for the next weekly challenge.',
                            imageAsset: HomeDemoData.heroAsset,
                          )
                        : HomeFeaturedContent(
                            id: widget.currentChallenge!.id,
                            category: 'Weekly Toward HIM 3',
                            title: widget.currentChallenge!.title,
                            description:
                                widget.currentChallenge!.completedDays.toString() +
                                ' of 7 days completed · ' +
                                widget.currentChallenge!.description,
                            imageAsset: HomeDemoData.featured.imageAsset,
                          ),
                    onPressed: () {
                      final challenge = widget.currentChallenge;
                      if (challenge != null && widget.onOpenChallenge != null) {
                        widget.onOpenChallenge!(challenge);
                      } else {
                        if (widget.guestMode) {
                          widget.onLoginRequired?.call();
                        } else {
                          widget.onSelectTab(HomeTab.towardHimThree);
                        }
                      }
                    },
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
            profile: HomeUserProfile(
              firstName: widget.firstName ?? (widget.guestMode ? 'Friend' : HomeDemoData.profile.firstName),
              greeting: HomeDemoData.profile.greeting,
              scripture: HomeDemoData.profile.scripture,
              scriptureReference: HomeDemoData.profile.scriptureReference,
            ),
            onNotifications: widget.onNotifications ??
                                    () => widget.onNotice(
                                      'Notifications UI is coming soon.',
                                    ),
            onProfile: widget.onProfile ??
                                    () => widget.onNotice(
                                      'Profile UI is coming soon.',
                                    ),
          ),
        ),
      ],
    );
  }
}
