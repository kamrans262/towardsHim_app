import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/community_post.dart';

/// Two equally sized, responsive Figma-style Community tabs.
class CommunitySegmentedTabs extends StatelessWidget {
  const CommunitySegmentedTabs({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final CommunityFeedTab selected;
  final ValueChanged<CommunityFeedTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('community_tabs'),
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.podcastTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('All Posts', CommunityFeedTab.allPosts),
          _tab('My Posts', CommunityFeedTab.myPosts),
        ],
      ),
    );
  }

  Widget _tab(String text, CommunityFeedTab tab) {
    final active = selected == tab;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('community_tab_${tab.name}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(tab),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.primaryOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: AppTypography.homeAccent.copyWith(
                fontSize: 18,
                height: 1,
                color: active ? AppColors.white : AppColors.primaryOrange,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
