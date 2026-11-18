import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart' as ja;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_audio_seek_bar.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_content_type_tag.dart';
import '../../../../core/widgets/app_content_media_view.dart';
import '../widgets/listen_media_carousel.dart';
import '../models/video_playback_snapshot.dart';
import '../../../../core/models/content_media.dart';
import '../../domain/models/listen_audio_episode.dart';
import '../../domain/models/listen_share_content.dart';
import '../controllers/audio_player_ui_controller.dart';
import '../services/narration_engine.dart';
import '../widgets/player_playback_controls.dart';
import '../widgets/player_secondary_action.dart';
import '../widgets/player_time_row.dart';

/// Preserves approved Player UI for both server audio and local TTS fixtures.
class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({
    required this.episode,
    this.narrationEngine,
    this.shareAction,
    this.embedded = false,
    super.key,
  });

  final ListenAudioEpisode episode;
  final NarrationEngine? narrationEngine;
  /// Compact, metadata-free mode for daily challenges. Playback logic,
  /// progress, speed and More actions remain shared with the Listen Player.
  final bool embedded;
  /// Test seam for the native system share sheet; production uses share_plus.
  final Future<void> Function(String text, Rect position)? shareAction;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayerUiController _player;
  NarrationEngine? _narration;
  ja.AudioPlayer? _remotePlayer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<ja.PlayerState>? _stateSubscription;
  StreamSubscription<ja.PlayerException>? _errorSubscription;
  final GlobalKey<ListenMediaCarouselState> _coverKey =
      GlobalKey<ListenMediaCarouselState>();
  bool _audioMayAutoplay = true;
  late final List<ListenMediaSlide> _mediaSlides;
  int _activeMediaIndex = 0;
  VideoPlaybackSnapshot _videoState = const VideoPlaybackSnapshot();

  bool get _videoSelected =>
      _mediaSlides[_activeMediaIndex].kind == ListenMediaKind.video;

  bool get _hasAudio =>
      widget.episode.audioUrl != null || widget.episode.narrationText != null;

  void _mediaChanged(int index, ListenMediaKind kind) {
    if (kind == ListenMediaKind.video) _pauseAudioForVideo();
    if (!mounted) return;
    setState(() {
      _activeMediaIndex = index;
      _videoState = const VideoPlaybackSnapshot();
    });
  }

  void _onVideoState(int index, VideoPlaybackSnapshot state) {
    if (!mounted || !_videoSelected || _activeMediaIndex != index ||
        _videoState == state) return;
    setState(() => _videoState = state);
  }

  void _togglePlayback() {
    if (!_videoSelected) {
      _toggleAudioPlayback();
      return;
    }
    if (_videoState.hasError) {
      _showNotice('Video playback is unavailable.');
      return;
    }
    if (!_videoState.isReady) {
      _showNotice('Video is loading.');
      return;
    }
    _coverKey.currentState?.toggleSelectedVideo();
  }

  void _seekPlayback(double fraction) {
    if (_videoSelected) {
      if (_videoState.isReady) _coverKey.currentState?.seekSelectedVideo(fraction);
      return;
    }
    _player.seekFraction(fraction);
    final voice = _narration;
    if (voice != null) unawaited(voice.seek(fraction));
    final remote = _remotePlayer;
    if (remote != null) {
      unawaited(remote.seek(Duration(seconds: _player.positionSeconds)));
    }
  }

  void _skipPlayback(int seconds) {
    if (_videoSelected) {
      if (_videoState.isReady) _coverKey.currentState?.skipSelectedVideo(seconds);
    } else {
      _skip(seconds);
    }
  }

  void _pauseAudioForVideo() {
    // A delayed network audio initialization must not resume after video starts.
    _audioMayAutoplay = false;
    _player.togglePlayPauseIfPlaying();
    final remote = _remotePlayer;
    if (remote != null) unawaited(remote.pause());
    final narration = _narration;
    if (narration != null) unawaited(narration.pause());
  }

  void _toggleAudioPlayback() {
    // The swipeable cover and existing playback controls share this action.
    _coverKey.currentState?.pauseVideos();
    _player.togglePlayPause();
    _audioMayAutoplay = _player.isPlaying;

    final narration = _narration;
    if (narration != null) {
      if (_player.isPlaying) {
        unawaited(narration.resume());
      } else {
        unawaited(narration.pause());
      }
    }
    final remote = _remotePlayer;
    if (remote != null) {
      if (_player.isPlaying) {
        if (remote.processingState == ja.ProcessingState.completed) {
          unawaited(remote.seek(Duration.zero));
        }
        unawaited(remote.play());
      } else {
        unawaited(remote.pause());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayerUiController(widget.episode);
    _mediaSlides = ListenMediaSlide.forEpisode(widget.episode);
    if (widget.embedded) {
      _activeMediaIndex = ListenMediaCarouselState.preferredSlideIndex(_mediaSlides);
      if (_mediaSlides[_activeMediaIndex].kind == ListenMediaKind.video) {
        // A day with both video and audio must not start hidden audio behind
        // the selected video.
        _audioMayAutoplay = false;
        _player.togglePlayPauseIfPlaying();
      }
    }
    final mediaUrl = widget.episode.audioUrl;
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      unawaited(_openRemote(mediaUrl));
    }
    final script = mediaUrl == null ? widget.episode.narrationText : null;
    if (script != null && script.isNotEmpty) {
      _narration = widget.narrationEngine ?? DeviceNarrationEngine();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_audioMayAutoplay) return;
        unawaited(_narration!.start(
          script,
          onProgress: (fraction) {
            if (mounted) _player.updateNarrationProgress(fraction);
          },
          onComplete: () {
            if (mounted) _player.finishNarration();
          },
          onError: (message) {
            if (mounted) {
              _player.togglePlayPauseIfPlaying();
              _showNotice('Audio playback is unavailable: $message');
            }
          },
        ));
      });
    }
  }

  Future<void> _openRemote(String url) async {
    final player = ja.AudioPlayer();
    _remotePlayer = player;
    _positionSubscription = player.positionStream.listen((position) {
      if (!mounted) return;
      final duration = _player.durationSeconds;
      if (duration > 0) {
        _player.updateNarrationProgress(
          position.inMilliseconds / (duration * 1000),
        );
      }
    });
    _durationSubscription = player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        _player.setDurationSeconds(duration.inSeconds);
      }
    });
    _stateSubscription = player.playerStateStream.listen((state) {
      if (mounted && state.processingState == ja.ProcessingState.completed) {
        _player.finishNarration();
      }
    });
    _errorSubscription = player.errorStream.listen((error) {
      if (mounted) {
        _player.togglePlayPauseIfPlaying();
        _showNotice('Audio playback is unavailable: ${error.message ?? 'Unknown error'}');
      }
    });
    try {
      final duration = await player.setUrl(url);
      if (!mounted) return;
      if (duration != null) _player.setDurationSeconds(duration.inSeconds);
      if (_audioMayAutoplay) unawaited(player.play());
    } catch (_) {
      if (mounted) {
        _player.togglePlayPauseIfPlaying();
        _showNotice('Unable to load audio. Check your internet connection.');
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _errorSubscription?.cancel();
    final remote = _remotePlayer;
    if (remote != null) unawaited(remote.dispose());
    final voice = _narration;
    if (voice != null) unawaited(voice.stop());
    _player.dispose();
    super.dispose();
  }

  void _skip(int seconds) {
    _player.skipSeconds(seconds);
    final voice = _narration;
    if (voice != null) unawaited(voice.seek(_player.progress));
    final remote = _remotePlayer;
    if (remote != null) {
      unawaited(remote.seek(Duration(seconds: _player.positionSeconds)));
    }
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSpeedPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.screenBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Playback Speed',
                  style: AppTypography.sectionHeading,
                ),
                const SizedBox(height: 15),
                for (final speed in const [0.75, 1.0, 1.25, 1.5, 2.0])
                  ListTile(
                    title: Text(
                      '$speed×',
                      style: AppTypography.quickAccessLabel,
                    ),
                    trailing: speed == _player.speed
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryOrange,
                          )
                        : null,
                    onTap: () {
                      _player.setSpeed(speed);
                      final voice = _narration;
                      if (voice != null) unawaited(voice.setSpeed(speed));
                      final remote = _remotePlayer;
                      if (remote != null) unawaited(remote.setSpeed(speed));
                      _coverKey.currentState?.setVideoSpeed(speed);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Rect _shareOrigin(BuildContext sheetContext) {
    final renderObject = sheetContext.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.localToGlobal(Offset.zero) & renderObject.size;
    }
    final screen = MediaQuery.sizeOf(context);
    return Rect.fromLTWH(screen.width / 2, screen.height / 2, 1, 1);
  }

  Future<void> _shareContent(String message, Rect origin) async {
    try {
      final action = widget.shareAction;
      if (action != null) {
        await action(message, origin);
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: message,
            title: widget.episode.playerTitle ?? widget.episode.title,
            subject: widget.episode.playerTitle ?? widget.episode.title,
            sharePositionOrigin: origin,
          ),
        );
      }
    } catch (_) {
      if (mounted) _showNotice('Unable to share this content.');
    }
  }

  Future<void> _copyContent(String value, bool isLink) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (mounted) _showNotice(isLink ? 'Link copied.' : 'Details copied.');
    } catch (_) {
      if (mounted) _showNotice('Unable to copy this content.');
    }
  }

  void _showMoreOptions() {
    final content = ListenShareContent.forEpisode(widget.episode);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              20,
              AppSpacing.screenHorizontal,
              AppSpacing.screenBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('More', style: AppTypography.sectionHeading),
                const SizedBox(height: 16),
                ListTile(
                  key: const Key('player_more_share'),
                  leading: const Icon(
                    Icons.share_outlined,
                    color: AppColors.primaryOrange,
                  ),
                  title: const Text('Share', style: AppTypography.quickAccessLabel),
                  onTap: () {
                    final origin = _shareOrigin(sheetContext);
                    Navigator.of(sheetContext).pop();
                    unawaited(_shareContent(content.message, origin));
                  },
                ),
                ListTile(
                  key: const Key('player_more_copy'),
                  leading: const Icon(
                    Icons.copy_outlined,
                    color: AppColors.primaryOrange,
                  ),
                  title: Text(
                    content.mediaUrl == null ? 'Copy Details' : 'Copy Link',
                    style: AppTypography.quickAccessLabel,
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(_copyContent(
                      content.mediaUrl ?? content.message,
                      content.mediaUrl != null,
                    ));
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCover({required bool compact}) {
    return AspectRatio(
      aspectRatio: compact ? 2 : AppSpacing.playerCoverAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.playerCoverRadius),
        child: ListenMediaCarousel(
          key: _coverKey,
          episode: widget.episode,
          onVideoPlay: _pauseAudioForVideo,
          onSelectionChanged: _mediaChanged,
          onVideoStateChanged: _onVideoState,
          preferPlayable: widget.embedded,
        ),
      ),
    );
  }

  Widget _buildPlaybackControls({required bool compact}) {
    return AnimatedBuilder(
      animation: _player,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppAudioSeekBar(
            progress: _videoSelected
                ? _videoState.progress
                : _player.progress,
            onChanged: _seekPlayback,
          ),
          SizedBox(height: compact ? 4 : AppSpacing.playerProgressToTimes),
          PlayerTimeRow(
            current: _videoSelected
                ? _videoState.currentTime
                : _player.currentTime,
            total: _videoSelected
                ? _videoState.totalTime
                : _player.totalTime,
          ),
          SizedBox(height: compact ? 10 : AppSpacing.playerTimesToControls),
          PlayerPlaybackControls(
            isPlaying: _videoSelected
                ? _videoState.isPlaying
                : _player.isPlaying,
            onToggle: _togglePlayback,
            onRewind: () => _skipPlayback(-10),
            onForward: () => _skipPlayback(10),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        Expanded(
          child: PlayerSecondaryAction(
            label: 'Speed',
            pngAsset: 'assets/icons/player/playback_speed.png',
            onPressed: _showSpeedPicker,
          ),
        ),
        Expanded(
          child: PlayerSecondaryAction(
            label: 'Download',
            svgAsset: 'assets/icons/player/download.svg',
            onPressed: () => _showNotice(
              'Downloading will be available after the UI phase.',
            ),
          ),
        ),
        Expanded(
          child: PlayerSecondaryAction(
            label: 'More',
            svgAsset: 'assets/icons/player/more.svg',
            onPressed: _showMoreOptions,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreOnly() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 100,
        child: PlayerSecondaryAction(
          label: 'More',
          svgAsset: 'assets/icons/player/more.svg',
          onPressed: _showMoreOptions,
        ),
      ),
    );
  }

  Widget _buildEmbeddedPlayer() {
    // In this mode the day heading and instructions are already on screen:
    // no Player header, duplicate description or default media caption.
    return Column(
      key: const Key('daily_challenge_embedded_player'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCover(compact: true),
        const SizedBox(height: 8),
        if (_hasAudio || _videoSelected) ...[
          _buildPlaybackControls(compact: true),
          const SizedBox(height: 10),
          _buildSecondaryActions(),
        ] else
          _buildMoreOnly(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildEmbeddedPlayer();
    final episode = widget.episode;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          key: const Key('player_scroll'),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenTop,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.homeContentMaxWidth -
                    2 * AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: AppSpacing.backButtonSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'Player',
                            style: AppTypography.mainScreenTitle,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppBackButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.playerHeaderToCover),
                  _buildCover(compact: false),
                  const SizedBox(height: AppSpacing.playerCoverToTag),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppContentTypeTag(label: episode.contentType),
                  ),
                  const SizedBox(height: AppSpacing.playerTagToTitle),
                  Text(
                    episode.playerTitle ?? episode.title,
                    style: AppTypography.sectionHeading,
                  ),
                  const SizedBox(height: AppSpacing.playerTitleToDuration),
                  Text(
                    episode.narrationText != null
                        ? 'Spoken demo · about 1 min'
                        : episode.audioUrl == null
                            ? 'Multimedia content'
                            : episode.durationMinutes == 0
                                ? 'Audio'
                                : '${episode.durationMinutes} min',
                    style: AppTypography.homeSecondary,
                  ),
                  const SizedBox(height: AppSpacing.playerDurationToDescription),
                  Text(
                    episode.playerDescription ?? episode.description,
                    style: AppTypography.homeSecondary,
                  ),
                  if (_hasAudio || _videoSelected) ...[
                    const SizedBox(height: AppSpacing.playerDescriptionToProgress),
                    _buildPlaybackControls(compact: false),
                    const SizedBox(height: AppSpacing.playerControlsToActions),
                    _buildSecondaryActions(),
                  ],
                  // Visual-only and written items still offer real sharing.
                  if (!_hasAudio && !_videoSelected) ...[
                    const SizedBox(height: 24),
                    _buildMoreOnly(),
                  ],
                  // Rich text remains below the audio controls. All images,
                  // videos and audio are shown in the top swipeable media area.
                  if (episode.media.any(
                    (block) => block.type == ContentMediaType.text,
                  )) ...[
                    const SizedBox(height: 20),
                    AppContentMediaView(
                      items: episode.media
                          .where((block) => block.type == ContentMediaType.text)
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
