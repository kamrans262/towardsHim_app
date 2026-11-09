import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_main_screen_header.dart';
import '../../data/community_demo_data.dart';
import '../controllers/community_controller.dart';
import '../widgets/community_create_post_sheet.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_segmented_tabs.dart';

/// Community main tab. The existing Home shell owns the fixed navigation bar.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({required this.onNotice, super.key});

  final ValueChanged<String> onNotice;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final CommunityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CommunityController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CommunityCreatePostSheet(),
    );
    if (!mounted || text == null || text.trim().isEmpty) return;
    _controller.createPost(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final posts = _controller.visiblePosts;
          return Stack(
            children: [
              CustomScrollView(
                key: const PageStorageKey<String>('community_scroll'),
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
                            100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppMainScreenHeader(
                                title: 'Community',
                                onNotifications: () => widget.onNotice(
                                  'Notifications UI is coming soon.',
                                ),
                                onProfile: () => widget.onNotice(
                                  'Profile UI is coming soon.',
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                CommunityDemoData.description,
                                style: AppTypography.description.copyWith(
                                  fontSize: 14,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 25),
                              CommunitySegmentedTabs(
                                selected: _controller.selectedTab,
                                onChanged: _controller.selectTab,
                              ),
                              const SizedBox(height: 25),
                              if (posts.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 30),
                                  child: Text(
                                    'No posts yet',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.homeSecondary,
                                  ),
                                ),
                              for (var i = 0; i < posts.length; i++) ...[
                                if (i != 0) const SizedBox(height: 15),
                                CommunityPostCard(
                                  key: ValueKey(posts[i].id),
                                  post: posts[i],
                                  onHide: _controller.hidePost,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: AppSpacing.screenHorizontal,
                bottom: 20,
                child: Material(
                  color: AppColors.primaryOrange,
                  shape: const CircleBorder(),
                  elevation: 5,
                  shadowColor: AppColors.backShadow,
                  child: InkWell(
                    key: const Key('community_add_post'),
                    customBorder: const CircleBorder(),
                    onTap: _createPost,
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.add_rounded,
                        size: 24,
                        color: AppColors.white,
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
}
