import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:video_player/video_player.dart';

import '../models/content_media.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_content_card.dart';

/// Reuses the approved Toward HIM card style for inline content.
class AppContentMediaView extends StatelessWidget {
  const AppContentMediaView({
    required this.items,
    this.onVideoPlay,
    super.key,
  });

  final List<ContentMedia> items;
  /// Pauses the parent audio player before a video starts.
  final VoidCallback? onVideoPlay;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('multimedia_content_blocks'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index != 0) const SizedBox(height: 15),
          _MediaBlock(
            key: ValueKey('content_block_$index'),
            item: items[index],
            onVideoPlay: onVideoPlay,
          ),
        ],
      ],
    );
  }
}

class _MediaBlock extends StatelessWidget {
  const _MediaBlock({required this.item, this.onVideoPlay, super.key});
  final ContentMedia item;
  final VoidCallback? onVideoPlay;

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case ContentMediaType.text:
        return Text(item.text ?? '', style: AppTypography.homeSecondary);
      case ContentMediaType.image:
        return AppContentCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item.hasPlayableFile)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.url!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Text(
                      'Image unavailable',
                      style: AppTypography.homeSecondary,
                    ),
                  ),
                ),
              if (item.text?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Text(item.text!, style: AppTypography.homeSecondary),
              ],
            ],
          ),
        );
      case ContentMediaType.audio:
        return _InlineAudioPlayer(url: item.url, caption: item.text);
      case ContentMediaType.video:
        return _InlineVideoPlayer(
          url: item.url,
          caption: item.text,
          onVideoPlay: onVideoPlay,
        );
    }
  }
}

class _InlineAudioPlayer extends StatefulWidget {
  const _InlineAudioPlayer({required this.url, this.caption});
  final String? url;
  final String? caption;

  @override
  State<_InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<_InlineAudioPlayer> {
  late final ja.AudioPlayer _player;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = ja.AudioPlayer();
  }

  Future<void> _toggle() async {
    if (_busy || widget.url == null) return;
    if (_player.playing) {
      await _player.pause();
      return;
    }
    if (_player.processingState == ja.ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    if (_player.audioSource != null) {
      unawaited(_player.play());
      return;
    }
    setState(() {_busy = true; _error = null;});
    try {
      await _player.setUrl(widget.url!);
      if (!mounted) return;
      unawaited(_player.play());
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load audio.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StreamBuilder<ja.PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return IconButton.filled(
                    tooltip: playing ? 'Pause audio' : 'Play audio',
                    onPressed: _busy || widget.url == null ? null : _toggle,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                    ),
                    icon: _busy
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(
                widget.caption?.isNotEmpty == true ? widget.caption! : 'Audio',
                style: AppTypography.homeSecondary,
              )),
            ],
          ),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final total = _player.duration ?? Duration.zero;
              if (total == Duration.zero) return const SizedBox.shrink();
              final current = snapshot.data ?? Duration.zero;
              return Slider(
                min: 0,
                max: total.inMilliseconds.toDouble(),
                value: current.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                activeColor: AppColors.primaryOrange,
                onChanged: (value) => unawaited(
                  _player.seek(Duration(milliseconds: value.round())),
                ),
              );
            },
          ),
          if (_error != null)
            Text(_error!, style: AppTypography.homeSecondary),
        ],
      ),
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  const _InlineVideoPlayer({required this.url, this.caption, this.onVideoPlay});
  final String? url;
  final String? caption;
  final VoidCallback? onVideoPlay;

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _player;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.url != null) unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final player = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    _player = player;
    try {
      await player.initialize();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _error = 'Video unavailable.');
    }
  }

  @override
  void dispose() {
    final player = _player;
    if (player != null) unawaited(player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    return AppContentCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: _ready && player != null &&
                player.value.aspectRatio > 0 ? player.value.aspectRatio : 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: !_ready || player == null
                  ? Center(
                      child: _error != null
                          ? Text(_error!, style: AppTypography.homeSecondary)
                          : const CircularProgressIndicator(
                              color: AppColors.primaryOrange,
                            ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(player),
                        Center(
                          child: IconButton.filled(
                            tooltip: 'Play or pause video',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                            ),
                            onPressed: () {
                              if (player.value.isPlaying) {
                                unawaited(player.pause());
                              } else {
                                widget.onVideoPlay?.call();
                                unawaited(player.play());
                              }
                              setState(() {});
                            },
                            icon: Icon(
                              player.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (_ready && player != null)
            VideoProgressIndicator(
              player,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.primaryOrange,
              ),
            ),
          if (widget.caption?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(widget.caption!, style: AppTypography.homeSecondary),
          ],
        ],
      ),
    );
  }
}
