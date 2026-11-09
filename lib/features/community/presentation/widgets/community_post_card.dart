import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../data/community_demo_data.dart';
import '../../domain/models/community_post.dart';

/// One global-style card for both demo and newly created community posts.
class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    required this.post,
    required this.onHide,
    super.key,
  });

  final CommunityPost post;
  final ValueChanged<String> onHide;

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: ClipOval(
                  child: Image.asset(
                    post.avatarAsset,
                    key: Key('community_avatar_${post.id}'),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(
                          color: AppColors.podcastTile,
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 24,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        maxLines: 2,
                        style: AppTypography.cardTitle,
                      ),
                      const SizedBox(height: 5),
                      Text(post.timeLabel, style: AppTypography.homeSecondary),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                key: Key('community_more_${post.id}'),
                tooltip: 'Post options',
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                icon: SvgPicture.asset(
                  'assets/icons/community/community_more_vertical.svg',
                  width: 16,
                  height: 16,
                  semanticsLabel: 'More options',
                ),
                color: AppColors.outlinedButtonBackground,
                onSelected: (value) {
                  if (value == 'copy') {
                    Clipboard.setData(ClipboardData(text: post.body));
                  } else if (value == 'hide') {
                    onHide(post.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'copy',
                    child: Text('Copy post'),
                  ),
                  PopupMenuItem<String>(
                    value: 'hide',
                    child: Text(
                      post.authorId == CommunityDemoData.currentUserId
                          ? 'Remove post'
                          : 'Hide post',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            post.body,
            style: AppTypography.homeSecondary.copyWith(height: 1.25),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/community/community_reply_dot.svg',
                width: 5,
                height: 5,
                semanticsLabel: 'Replies',
              ),
              const SizedBox(width: 6),
              Text(
                '${post.replyCount} ${post.replyCount == 1 ? 'reply' : 'replies'}',
                style: AppTypography.homeSecondary.copyWith(
                  fontWeight: FontWeight.w400,
                  fontVariations: const [FontVariation('wght', 400)],
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
