import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header_actions.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../data/weekly_challenge_demo_data.dart';
import '../../data/challenge_repository.dart';
import '../../domain/models/weekly_challenge.dart';
import '../controllers/weekly_challenge_search_controller.dart';
import '../widgets/weekly_challenge_card.dart';

/// Approved Weekly tab using real member challenges and saved progress.
class WeeklyChallengesScreen extends StatefulWidget {
  const WeeklyChallengesScreen({required this.onNotice,
    this.onNotifications,
    this.onProfile, required this.onOpenChallenge,
    this.repository, this.active = true, super.key});
  final ValueChanged<String> onNotice;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;
  final ValueChanged<WeeklyChallenge> onOpenChallenge;
  final ChallengeRepository? repository;
  final bool active;

  @override
  State<WeeklyChallengesScreen> createState() => _WeeklyChallengesScreenState();
}

class _WeeklyChallengesScreenState extends State<WeeklyChallengesScreen> {
  late final TextEditingController _searchText;
  late final WeeklyChallengeSearchController _challenges;
  late final ChallengeRepository _repository;
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchText = TextEditingController();
    _repository = widget.repository ?? ChallengeRepository.instance;
    _challenges = WeeklyChallengeSearchController([]);
    _repository.addListener(_refreshAfterProgress);
    if (widget.active) _refresh();

  }

  @override
  void didUpdateWidget(covariant WeeklyChallengesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) _refresh();
  }

  void _refreshAfterProgress() {
    if (_loaded && !_loading) _refresh();
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repository.list();
      if (!mounted) return;
      _challenges.replaceChallenges(list);
      _loaded = true;
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _repository.removeListener(_refreshAfterProgress);

    _searchText.dispose();
    _challenges.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _challenges,
        builder: (context, _) {
          final featured =
              _challenges.forCategory(WeeklyChallengeCategory.featured);
          final previous =
              _challenges.forCategory(WeeklyChallengeCategory.previous);
          return CustomScrollView(
            key: const PageStorageKey<String>('weekly_challenges_scroll'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        key: const Key('weekly_challenges_screen'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppSearchField(
                                  controller: _searchText,
                                  onChanged: _challenges.setQuery,
                                ),
                              ),
                              const SizedBox(width: 12),
                              AppHeaderActions(
                                onNotifications: widget.onNotifications ??
                                    () => widget.onNotice(
                                      'Notifications UI is coming soon.',
                                    ),
                                onProfile: widget.onProfile ??
                                    () => widget.onNotice(
                                      'Profile UI is coming soon.',
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.weeklyHeaderToTitle),
                          Text(
                            'Weekly Toward HIM 3',
                            style: AppTypography.heading.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            WeeklyChallengeDemoData.description,
                            style: AppTypography.description.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          if (_loading)
                            const Center(child: CircularProgressIndicator())
                          else if (_error != null)
                            Column(
                              children: [
                                Text(_error!, style: AppTypography.homeSecondary),
                                TextButton(onPressed: _refresh, child: const Text('Retry')),
                              ],
                            ),
                          if (!_loading && _error == null)
                          for (var i = 0; i < featured.length; i++) ...[
                            if (i != 0)
                              const SizedBox(height: AppSpacing.weeklyCardGap),
                            WeeklyChallengeCard(
                              key: ValueKey(featured[i].id),
                              challenge: featured[i],
                              onPressed: () => _openChallenge(featured[i]),
                            ),
                          ],
                          if (!_loading && _error == null && previous.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const AppSectionHeading('Previous Toward HIM 3'),
                            const SizedBox(height: 15),
                            for (var i = 0; i < previous.length; i++) ...[
                              if (i != 0)
                                const SizedBox(height: AppSpacing.weeklyCardGap),
                              WeeklyChallengeCard(
                                key: ValueKey(previous[i].id),
                                challenge: previous[i],
                                compact: true,
                                onPressed: () => _openChallenge(previous[i]),
                              ),
                            ],
                          ],
                          if (!_loading && _error == null && featured.isEmpty && previous.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No challenges found',
                                textAlign: TextAlign.center,
                                style: AppTypography.homeSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openChallenge(WeeklyChallenge challenge) {
    widget.onOpenChallenge(challenge);
  }
}
