import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_main_screen_header.dart';
import '../../../home/data/home_demo_data.dart';
import '../../../home/presentation/widgets/home_quick_access_card.dart';
import '../../data/listen_demo_data.dart';
import '../widgets/listen_audio_list_item.dart';

/// UI-only Listen tab. The parent IndexedStack preserves the scroll and
/// visual play state when the user returns from another tab.
class ListenScreen extends StatefulWidget {
  const ListenScreen({
    required this.onNotice,
    super.key,
  });

  final ValueChanged<String> onNotice;

  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen> {
  String? _playingEpisodeId;

  void _toggleEpisode(String episodeId) {
    setState(() {
      _playingEpisodeId = _playingEpisodeId == episodeId ? null : episodeId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        key: const PageStorageKey<String>('listen_scroll'),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppMainScreenHeader(
                        title: 'Listen',
                        onNotifications: () => widget.onNotice(
                          'Notifications UI is coming soon.',
                        ),
                        onProfile: () => widget.onNotice(
                          'Profile UI is coming soon.',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.listenHeaderToDescription),
                      const Text(
                        ListenDemoData.description,
                        style: AppTypography.description,
                      ),
                      const SizedBox(height: AppSpacing.homeSectionGap),
                      Row(
                        children: [
                          for (var i = 0;
                              i < HomeDemoData.quickAccess.length;
                              i++) ...[
                            if (i != 0)
                              const SizedBox(width: AppSpacing.homeQuickGap),
                            Expanded(
                              child: HomeQuickAccessCard(
                                item: HomeDemoData.quickAccess[i],
                                height: AppSpacing.listenQuickCardHeight,
                                onPressed: () => widget.onNotice(
                                  '${HomeDemoData.quickAccess[i].title} category UI is coming soon.',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.homeSectionGap),
                      for (var i = 0; i < ListenDemoData.episodes.length; i++) ...[
                        if (i != 0) ...[
                          const SizedBox(height: AppSpacing.listenDividerGap),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.divider,
                          ),
                          const SizedBox(height: AppSpacing.listenDividerGap),
                        ],
                        ListenAudioListItem(
                          key: ValueKey(ListenDemoData.episodes[i].id),
                          episode: ListenDemoData.episodes[i],
                          isPlaying: _playingEpisodeId ==
                              ListenDemoData.episodes[i].id,
                          onPlayPressed: () =>
                              _toggleEpisode(ListenDemoData.episodes[i].id),
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
    );
  }
}
