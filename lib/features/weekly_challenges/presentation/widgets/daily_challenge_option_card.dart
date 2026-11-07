import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../domain/models/daily_challenge.dart';

/// A selectable option row with the shared card surface and a radio indicator.
class DailyChallengeOptionCard extends StatelessWidget {
  const DailyChallengeOptionCard({
    required this.option,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final DailyChallengeOption option;
  final bool selected;
  final VoidCallback onSelect;

  IconData get _icon => switch (option.type) {
        DailyChallengeOptionType.taste => Icons.star_border_rounded,
        DailyChallengeOptionType.see => Icons.visibility_outlined,
        DailyChallengeOptionType.share => Icons.share_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: option.title,
      child: InkWell(
        key: Key('daily_option_' + option.id),
        onTap: onSelect,
        borderRadius: BorderRadius.circular(10),
        child: AppContentCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.podcastTile,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _icon,
                  size: 24,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title, style: AppTypography.cardTitle),
                    const SizedBox(height: 5),
                    Text(
                      option.description,
                      style: AppTypography.homeSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryOrange,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const CircleAvatar(
                        radius: 6,
                        backgroundColor: AppColors.primaryOrange,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
