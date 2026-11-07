import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../data/weekly_challenge_detail_demo_data.dart';
import '../../data/daily_challenge_demo_data.dart';
import '../../domain/models/weekly_challenge.dart';
import '../controllers/weekly_challenge_detail_controller.dart';
import '../widgets/weekly_challenge_hero.dart';

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
                  child: WeeklyChallengeHero(
                    onBack: () => Navigator.of(context).maybePop(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.homeContentMaxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            0,
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
                              for (var index = 0;
                                  index < WeeklyChallengeDetailDemoData.activities.length;
                                  index++) ...[
                                if (index != 0) const SizedBox(height: 20),
                                _DailyActivityCard(
                                  activity: WeeklyChallengeDetailDemoData.activities[index],
                                  completed: _controller.isCompleted(
                                    WeeklyChallengeDetailDemoData.activities[index].day,
                                  ),
                                  onToggle: () => _controller.toggle(
                                    WeeklyChallengeDetailDemoData.activities[index].day,
                                  ),
                                  onOpen: () => Navigator.of(context).pushNamed(
                                    AppRoutes.dailyChallengeDetail,
                                    arguments: DailyChallengeDemoData.forDay(
                                      WeeklyChallengeDetailDemoData.activities[index].day,
                                    ),
                                  ),
                                ),
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
          Text(
            'Your Progress',
            style: AppTypography.sectionHeading.copyWith(
              fontWeight: FontWeight.w600,
              fontVariations: const [FontVariation('wght', 600)],
            ),
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.check_box_rounded,
                size: 18,
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
    required this.onOpen,
  });

  final WeeklyDailyActivity activity;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final dayLabel = 'Day ' + activity.day.toString();

    return AppContentCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: Key('weekly_day_open_' + activity.day.toString()),
              onTap: onOpen,
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.podcastTile,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      dayLabel,
                      style: AppTypography.playerTag,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      activity.text,
                      style: AppTypography.homeSecondary.copyWith(height: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            checked: completed,
            label: dayLabel + ' complete',
            child: InkWell(
              key: Key('weekly_day_toggle_' + activity.day.toString()),
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
