import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header_actions.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../data/weekly_challenge_demo_data.dart';
import '../../domain/models/weekly_challenge.dart';
import '../controllers/weekly_challenge_search_controller.dart';
import '../widgets/weekly_challenge_card.dart';

/// UI-only Weekly tab; the existing Home shell keeps its fixed five-item nav.
class WeeklyChallengesScreen extends StatefulWidget {
  const WeeklyChallengesScreen({required this.onNotice, super.key});
  final ValueChanged<String> onNotice;

  @override
  State<WeeklyChallengesScreen> createState() => _WeeklyChallengesScreenState();
}

class _WeeklyChallengesScreenState extends State<WeeklyChallengesScreen> {
  late final TextEditingController _searchText;
  late final WeeklyChallengeSearchController _challenges;

  @override
  void initState() {
    super.initState();
    _searchText = TextEditingController();
    _challenges =
        WeeklyChallengeSearchController(WeeklyChallengeDemoData.challenges);
  }

  @override
  void dispose() {
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
                                onNotifications: () => widget.onNotice(
                                  'Notifications UI is coming soon.',
                                ),
                                onProfile: () => widget.onNotice(
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
                          for (var i = 0; i < featured.length; i++) ...[
                            if (i != 0)
                              const SizedBox(height: AppSpacing.weeklyCardGap),
                            WeeklyChallengeCard(
                              key: ValueKey(featured[i].id),
                              challenge: featured[i],
                              onPressed: () => _openChallenge(featured[i]),
                            ),
                          ],
                          if (previous.isNotEmpty) ...[
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
                          if (featured.isEmpty && previous.isEmpty)
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
    // A detail route can replace this notice when that screen is available.
    widget.onNotice(challenge.title + ' details UI is coming soon.');
  }
}
