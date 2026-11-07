import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/daily_challenge.dart';
import '../controllers/daily_challenge_selection_controller.dart';
import '../widgets/daily_challenge_option_card.dart';
import '../widgets/weekly_challenge_hero.dart';

/// Figma-based daily challenge detail using local mock state only.
class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({required this.challenge, super.key});

  final DailyChallenge challenge;

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late final DailyChallengeSelectionController _selection;

  @override
  void initState() {
    super.initState();
    _selection = DailyChallengeSelectionController(
      widget.challenge.initialSelectedOptionId,
    );
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('daily_challenge_scaffold'),
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _selection,
          builder: (context, _) => CustomScrollView(
            key: const Key('daily_challenge_scroll'),
            slivers: [
              SliverToBoxAdapter(
                child: WeeklyChallengeHero(
                  onBack: () => Navigator.of(context).maybePop(),
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
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          20,
                          AppSpacing.screenHorizontal,
                          AppSpacing.screenBottom +
                              MediaQuery.paddingOf(context).bottom,
                        ),
                        child: Column(
                          key: const Key('daily_challenge_content'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              widget.challenge.subtitle,
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
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.challenge.description,
                              style: AppTypography.homeSecondary,
                            ),
                            const SizedBox(height: 20),
                            for (var i = 0;
                                i < widget.challenge.options.length;
                                i++) ...[
                              if (i != 0)
                                const SizedBox(height: 15),
                              DailyChallengeOptionCard(
                                key: ValueKey(widget.challenge.options[i].id),
                                option: widget.challenge.options[i],
                                selected: _selection.isSelected(
                                  widget.challenge.options[i].id,
                                ),
                                onSelect: () => _selection.select(
                                  widget.challenge.options[i].id,
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
          ),
        ),
      ),
    );
  }
}
