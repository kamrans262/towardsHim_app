import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_main_screen_header.dart';
import '../../../home/data/home_demo_data.dart';
import '../../../home/domain/models/home_models.dart';
import '../../../home/presentation/widgets/home_quick_access_card.dart';
import '../../data/listen_demo_data.dart';
import '../../data/audio_catalog_repository.dart';
import '../../domain/models/listen_audio_episode.dart';
import '../widgets/listen_audio_list_item.dart';

/// Existing Listen screen with live published audio and unchanged visual layout.
class ListenScreen extends StatefulWidget {
  const ListenScreen({
    required this.onNotice,
    this.onNotifications,
    this.onProfile,
    this.onOpenQuickMedia,
    required this.onOpenEpisode,
    this.selectedCategory,
    this.repository,
    super.key,
  });

  final ValueChanged<String> onNotice;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;
  final ValueChanged<HomeQuickType>? onOpenQuickMedia;
  final ValueChanged<ListenAudioEpisode> onOpenEpisode;
  final HomeQuickType? selectedCategory;
  final AudioCatalogRepository? repository;

  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen> {
  List<ListenAudioEpisode> _episodes = const [];
  bool _loading = true;
  String? _loadError;
  HomeQuickType? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _loadAudio();
  }

  @override
  void didUpdateWidget(covariant ListenScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      setState(() => _category = widget.selectedCategory);
    }
  }

  Future<void> _loadAudio() async {
    try {
      final items = await (widget.repository ?? const AudioCatalogRepository())
          .fetchPublished();
      if (mounted) {
        setState(() {
          _episodes = items;
          _loading = false;
          _loadError = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = error.toString();
        });
      }
    }
  }

  void _refreshAudio() {
    if (_loading) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    _loadAudio();
  }

  List<ListenAudioEpisode> get _visibleEpisodes {
    if (_category == null) return _episodes;
    final type = switch (_category!) {
      HomeQuickType.podcast => 'Podcast',
      HomeQuickType.meditation => 'Meditation',
      HomeQuickType.prayer => 'Prayer',
    };
    return _episodes.where((item) => item.contentType == type).toList();
  }

  String? _playingEpisodeId;

  void _openEpisode(ListenAudioEpisode episode) {
    setState(() => _playingEpisodeId = episode.id);
    widget.onOpenEpisode(episode);
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
                        onNotifications: widget.onNotifications ??
                                    () => widget.onNotice(
                                      'Notifications UI is coming soon.',
                                    ),
                        onProfile: widget.onProfile ??
                                    () => widget.onNotice(
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
                                onPressed: () {
                                  final type = HomeDemoData.quickAccess[i].type;
                                  setState(() {
                                    _category = _category == type ? null : type;
                                  });
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.homeSectionGap),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_loadError != null)
                        Column(
                          children: [
                            Text(_loadError!, style: AppTypography.homeSecondary),
                            TextButton(onPressed: _refreshAudio, child: const Text('Retry')),
                          ],
                        )
                      else if (_visibleEpisodes.isEmpty)
                        Column(
                          children: [
                            const Text('No audio published yet.', style: AppTypography.homeSecondary),
                            TextButton(onPressed: _refreshAudio, child: const Text('Refresh')),
                          ],
                        )
                      else
                        for (var i = 0; i < _visibleEpisodes.length; i++) ...[
                          if (i != 0) ...[
                            const SizedBox(height: AppSpacing.listenDividerGap),
                            const Divider(height: 1, thickness: 1, color: AppColors.divider),
                            const SizedBox(height: AppSpacing.listenDividerGap),
                          ],
                          ListenAudioListItem(
                            key: ValueKey(_visibleEpisodes[i].id),
                            episode: _visibleEpisodes[i],
                            isPlaying: _playingEpisodeId == _visibleEpisodes[i].id,
                            onPlayPressed: () => _openEpisode(_visibleEpisodes[i]),
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
