import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_content_media_view.dart';
import '../../data/weekly_challenge_detail_demo_data.dart';
import '../../data/challenge_repository.dart';
import '../../domain/models/weekly_challenge.dart';
import '../../domain/models/daily_challenge.dart';
import '../controllers/weekly_challenge_detail_controller.dart';
import '../widgets/weekly_challenge_hero.dart';

/// Existing Weekly detail UI with server-saved personal activity progress.
class WeeklyChallengeDetailScreen extends StatefulWidget {
  const WeeklyChallengeDetailScreen({
    required this.challenge,
    this.repository,
    super.key,
  });

  final WeeklyChallenge challenge;
  final ChallengeRepository? repository;

  @override
  State<WeeklyChallengeDetailScreen> createState() =>
      _WeeklyChallengeDetailScreenState();
}

class _WeeklyChallengeDetailScreenState
    extends State<WeeklyChallengeDetailScreen> {
  late final WeeklyChallengeDetailController _controller;
  late final ChallengeRepository _repository;
  late WeeklyChallenge _challenge;
  List<WeeklyChallengeDay> _days = const [];
  bool _loading = false;
  String? _error;
  final Set<int> _saving = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ChallengeRepository.instance;
    _challenge = widget.challenge;
    _days = _challenge.days;
    _controller = WeeklyChallengeDetailController(
      totalDays: _challenge.totalDays,
      initiallyCompleted: _challenge.completedDayNumbers,
    );
    if (_days.isEmpty) _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final challenge = await _repository.detail(widget.challenge.id);
      if (!mounted) return;
      _controller.replaceCompleted(challenge.completedDayNumbers);
      setState(() {
        _challenge = challenge;
        _days = challenge.days;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(int day) async {
    if (_saving.contains(day) || _loading) return;
    final next = !_controller.isCompleted(day);
    _saving.add(day);
    _controller.toggle(day);
    try {
      await _repository.setCompleted(_challenge.id, day, next);
    } catch (error) {
      if (!mounted) return;
      _controller.toggle(day);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save progress: $error')),
      );
    } finally {
      _saving.remove(day);
    }
  }

  void _openDay(WeeklyChallengeDay day) {
    // The approved daily page's three choice cards remain presentation-only.
    // The weekly checkbox is the authoritative completion state.
    Navigator.of(context).pushNamed(
      AppRoutes.dailyChallengeDetail,
      arguments: DailyChallenge(
        id: 'challenge-' + _challenge.id + '-day-' + day.day.toString(),
        subtitle: 'Day ' + day.day.toString() + ' – Daily Challenge',
        title: _challenge.title,
        description: day.text,
        initialSelectedOptionId: 'share',
        options: const [],
        media: day.media,
      ),
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
                                _challenge.title,
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _challenge.datesLabel,
                                style: AppTypography.homeSecondary,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _challenge.description,
                                style: AppTypography.homeSecondary,
                              ),
                              if (_challenge.media.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                AppContentMediaView(items: _challenge.media),
                              ],
                              const SizedBox(height: 20),
                              _ProgressCard(controller: _controller),
                              const SizedBox(height: 20),
                              const Text(
                                'Daily Activities',
                                style: AppTypography.sectionHeading,
                              ),
                              const SizedBox(height: 15),
                              if (_loading)
                                const Center(child: CircularProgressIndicator())
                              else if (_error != null)
                                Column(
                                  children: [
                                    Text(_error!, style: AppTypography.homeSecondary),
                                    TextButton(onPressed: _load, child: const Text('Retry')),
                                  ],
                                )
                              else
                                for (var index = 0; index < _days.length; index++) ...[
                                  if (index != 0) const SizedBox(height: 20),
                                  _DailyActivityCard(
                                    activity: WeeklyDailyActivity(
                                      day: _days[index].day,
                                      text: _days[index].text,
                                    ),
                                    completed: _controller.isCompleted(_days[index].day),
                                    onToggle: () => _toggle(_days[index].day),
                                    onOpen: () => _openDay(_days[index]),
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
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
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
