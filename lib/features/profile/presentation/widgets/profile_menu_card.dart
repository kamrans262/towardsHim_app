
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../domain/models/profile_models.dart';

/// Configurable October 8-style menu row using the global content card.
class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    required this.item,
    required this.onPressed,
    super.key,
  });

  final ProfileMenuItem item;
  final VoidCallback onPressed;

  IconData get _icon => switch (item.action) {
        ProfileMenuAction.myProfile => Icons.manage_accounts_outlined,
        ProfileMenuAction.about => Icons.info_outline_rounded,
        ProfileMenuAction.merchandise => Icons.tune_rounded,
        ProfileMenuAction.privacy => Icons.shield_outlined,
        ProfileMenuAction.terms => Icons.description_outlined,
        ProfileMenuAction.deleteAccount => Icons.delete_outline_rounded,
        ProfileMenuAction.logout => Icons.logout_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final danger = item.tone == ProfileMenuIconTone.danger;
    return InkWell(
      key: Key('profile_menu_${item.action.name}'),
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: AppContentCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: danger ? const Color(0x14E92D2D) : AppColors.podcastTile,
              ),
              child: Icon(
                _icon,
                size: 24,
                color: danger
                    ? const Color(0xFFE32222)
                    : AppColors.primaryOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.cardTitle.copyWith(height: 1),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.description!,
                      style: AppTypography.playerTime,
                    ),
                  ],
                ],
              ),
            ),
            if (item.showChevron) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.secondaryText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
