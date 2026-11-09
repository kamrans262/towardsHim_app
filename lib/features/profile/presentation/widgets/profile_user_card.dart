
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_user_avatar.dart';
import '../../domain/models/profile_models.dart';

/// Reuses the same card and 48px Community avatar with an editable affordance.
class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    required this.user,
    required this.onEdit,
    super.key,
  });

  final ProfileUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          AppUserAvatar(
            key: const Key('profile_user_avatar'),
            asset: user.avatarAsset,
            bytes: user.avatarBytes,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: AppTypography.cardTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      key: const Key('profile_edit_button'),
                      tooltip: 'Edit Profile',
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 44,
                        height: 44,
                      ),
                      icon: SvgPicture.asset(
                        'assets/icons/profile/edit_profile.svg',
                        width: 24,
                        height: 24,
                        semanticsLabel: 'Edit Profile',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  user.email,
                  style: AppTypography.playerTime,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((user.about ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    user.about!,
                    key: const Key('profile_display_bio'),
                    style: AppTypography.homeSecondary,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
