import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_media_view.dart';
import '../../../../core/models/content_media.dart';
import '../../../listen/domain/models/listen_audio_episode.dart';
import '../../../listen/presentation/screens/audio_player_screen.dart';
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

  bool get _hasPlayableMedia => widget.challenge.media.any(
        (item) =>
            item.hasPlayableFile &&
            (item.type == ContentMediaType.audio ||
                item.type == ContentMediaType.video),
      );

  ListenAudioEpisode get _playerEpisode {
    String? firstUrl(ContentMediaType type) {
      for (final item in widget.challenge.media) {
        if (item.type == type && item.hasPlayableFile) return item.url;
      }
      return null;
    }

    return ListenAudioEpisode(
      id: widget.challenge.id,
      title: widget.challenge.title,
      // This is used for native sharing only. The day already renders this
      // description once above the media and it is not repeated in Player.
      description: widget.challenge.description,
      thumbnailAsset: 'assets/images/home/golden_hour_meditation.webp',
      contentType: 'Daily Challenge',
      durationMinutes: 0,
      playbackProgress: 0,
      isCompleted: false,
      artworkUrl: firstUrl(ContentMediaType.image),
      audioUrl: firstUrl(ContentMediaType.audio),
      videoUrl: firstUrl(ContentMediaType.video),
      media: widget.challenge.media
          .where((item) => item.type != ContentMediaType.text)
          .toList(growable: false),
    );
  }

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
                    child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.homeContentMaxWidth,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          0,
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
                            if (_hasPlayableMedia) ...[
                              const SizedBox(height: 12),
                              AudioPlayerScreen(
                                key: ValueKey('day_player_${widget.challenge.id}'),
                                episode: _playerEpisode,
                                embedded: true,
                              ),
                            ] else if (widget.challenge.media.any(
                              (item) => item.type == ContentMediaType.image &&
                                  item.hasPlayableFile,
                            )) ...[
                              const SizedBox(height: 12),
                              AppContentMediaView(
                                items: widget.challenge.media
                                    .where((item) =>
                                        item.type == ContentMediaType.image &&
                                        item.hasPlayableFile)
                                    .map((item) => ContentMedia(
                                          id: item.id,
                                          type: item.type,
                                          url: item.url,
                                        ))
                                    .toList(growable: false),
                              ),
                            ],
                            SizedBox(height: _hasPlayableMedia ? 12 : 20),
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
