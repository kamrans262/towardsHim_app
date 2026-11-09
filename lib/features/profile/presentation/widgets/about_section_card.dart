import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../domain/models/about_toward_him.dart';

/// Same content surface and left-icon/card-chevron treatment as Profile.
class AboutSectionCard extends StatelessWidget {
  const AboutSectionCard({
    required this.section,
    required this.onPressed,
    super.key,
  });

  final AboutSection section;
  final VoidCallback onPressed;

  IconData get _icon => switch (section.type) {
        AboutSectionType.mission => Icons.fact_check_outlined,
        AboutSectionType.vision => Icons.update_rounded,
        AboutSectionType.values => Icons.favorite_border_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('about_section_${section.type.name}'),
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: AppContentCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
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
                  Text(
                    section.title,
                    style: AppTypography.cardTitle,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    section.description,
                    style: AppTypography.playerTime.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
