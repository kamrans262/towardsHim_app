import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../data/weekly_challenge_detail_demo_data.dart';
import '../../domain/models/weekly_challenge.dart';
import '../controllers/weekly_challenge_detail_controller.dart';

/// UI-only weekly detail; the main five-tab navigation stays on the list.
class WeeklyChallengeDetailScreen extends StatefulWidget {
  const WeeklyChallengeDetailScreen({
    required this.challenge,
    super.key,
  });

  final WeeklyChallenge challenge;

  @override
  State<WeeklyChallengeDetailScreen> createState() =>
      _WeeklyChallengeDetailScreenState();
}

class _WeeklyChallengeDetailScreenState
    extends State<WeeklyChallengeDetailScreen> {
  late final WeeklyChallengeDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WeeklyChallengeDetailController(
      totalDays: widget.challenge.totalDays,
      initiallyCompleted: widget.challenge.status ==
              WeeklyChallengeStatus.completed
          ? {for (var day = 1; day <= widget.challenge.totalDays; day++) day}
          : WeeklyChallengeDetailDemoData.initiallyCompletedDays,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topSafeInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('weekly_detail_scaffold'),
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomScrollView(
              key: const Key('weekly_detail_scroll'),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: WeeklyChallengeDetailDemoData.heroVisibleHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: WeeklyChallengeDetailDemoData.heroImageHeight,
                          child: Image.asset(
                            WeeklyChallengeDetailDemoData.heroAsset,
                            key: const Key('weekly_detail_hero'),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                        Positioned(
                          top: topSafeInset + AppSpacing.screenTop,
                          left: AppSpacing.screenHorizontal,
                          child: AppBackButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.homeContentMaxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            20,
                            AppSpacing.screenHorizontal,
                            AppSpacing.screenBottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Weekly',
                                style: AppTypography.playerTag.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.challenge.title,
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                WeeklyChallengeDetailDemoData.dates,
                                style: AppTypography.homeSecondary,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                WeeklyChallengeDetailDemoData.description,
                                style: AppTypography.homeSecondary,
                              ),
                              const SizedBox(height: 20),
                              _ProgressCard(controller: _controller),
                              const SizedBox(height: 20),
                              const Text(
                                'Daily Activities',
                                style: AppTypography.sectionHeading,
                              ),
                              const SizedBox(height: 15),
                              for (final activity
                                  in WeeklyChallengeDetailDemoData.activities) ...[
                                _DailyActivityCard(
                                  activity: activity,
                                  completed: _controller.isCompleted(
                                    activity.day,
                                  ),
                                  onToggle: () => _controller.toggle(
                                    activity.day,
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.controller});

  final WeeklyChallengeDetailController controller;

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Your Progress',
            style: AppTypography.sectionHeading,
          ),
          const SizedBox(height: 10),
          AppProgressBar(
            progress: controller.progress,
            height: AppSpacing.weeklyProgressHeight,
            semanticsLabel: 'Weekly challenge progress',
          ),
          const SizedBox(height: AppSpacing.weeklyProgressLabelGap),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              controller.progressLabel,
              key: const Key('weekly_detail_progress_label'),
              style: AppTypography.playerTime.copyWith(
                fontWeight: FontWeight.w400,
                fontVariations: const [FontVariation('wght', 400)],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.check_box_rounded,
                size: 20,
                color: Color(0xFF226935),
              ),
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  'Progress automatically saved',
                  style: AppTypography.homeSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyActivityCard extends StatelessWidget {
  const _DailyActivityCard({
    required this.activity,
    required this.completed,
    required this.onToggle,
  });

  final WeeklyDailyActivity activity;
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.podcastTile,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 12,
              ),
              child: Text(
                'Day '+activity.day.toString(),
                style: AppTypography.homeAccent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity.text,
              style: AppTypography.homeSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            checked: completed,
            label: 'Day '+activity.day.toString()+' complete',
            child: InkWell(
              key: Key('weekly_day_toggle_'+activity.day.toString()),
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: completed
                          ? AppColors.primaryOrange
                          : AppColors.secondaryText,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
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
