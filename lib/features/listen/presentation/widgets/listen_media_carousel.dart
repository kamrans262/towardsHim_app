import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/models/content_media.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/video_playback_snapshot.dart';
import '../../domain/models/listen_audio_episode.dart';

enum ListenMediaKind { artwork, video, audio }

/// One swipeable page for each available media file, in Artwork → Video → Audio
/// order. No placeholder artwork page is added if the item has real media but
/// no artwork. Older local/demo entries keep their approved fallback cover.
class ListenMediaSlide {
  const ListenMediaSlide(this.kind, {this.url, this.caption});

  final ListenMediaKind kind;
  final String? url;
  final String? caption;

  static List<ListenMediaSlide> forEpisode(ListenAudioEpisode episode) {
    final artwork = <ListenMediaSlide>[];
    final videos = <ListenMediaSlide>[];
    final audio = <ListenMediaSlide>[];
    final seenImages = <String>{};
    final seenVideos = <String>{};

    void image(String? url, [String? caption]) {
      if (url != null && seenImages.add(url)) {
        artwork.add(ListenMediaSlide(
          ListenMediaKind.artwork,
          url: url,
          caption: caption,
        ));
      }
    }

    void video(String? url, [String? caption]) {
      if (url != null && seenVideos.add(url)) {
        videos.add(ListenMediaSlide(
          ListenMediaKind.video,
          url: url,
          caption: caption,
        ));
      }
    }

    image(episode.artworkUrl);
    video(episode.videoUrl);
    for (final block in episode.media) {
      switch (block.type) {
        case ContentMediaType.image:
          image(block.url, block.text);
        case ContentMediaType.video:
          video(block.url, block.text);
        case ContentMediaType.audio:
        case ContentMediaType.text:
          break;
      }
    }

    if (episode.audioUrl != null || episode.narrationText != null) {
      audio.add(const ListenMediaSlide(ListenMediaKind.audio));
    }

    // Keep the exact cover of the approved Player for local fixtures and
    // text-only items. Live audio/video-only entries need no imaginary artwork.
    if (artwork.isEmpty && videos.isEmpty && episode.audioUrl == null) {
      artwork.add(const ListenMediaSlide(ListenMediaKind.artwork));
    }

    return [...artwork, ...videos, ...audio];
  }
}

/// Replaces the original cover within the same bounds. The approved
/// bottom Player controls handle video and audio; the cover has no controls.
class ListenMediaCarousel extends StatefulWidget {
  const ListenMediaCarousel({
    required this.episode,
    required this.onVideoPlay,
    this.onSelectionChanged,
    this.onVideoStateChanged,
    super.key,
  });

  final ListenAudioEpisode episode;
  final VoidCallback onVideoPlay;
  final void Function(int index, ListenMediaKind kind)? onSelectionChanged;
  final void Function(int index, VideoPlaybackSnapshot snapshot)?
      onVideoStateChanged;

  @override
  State<ListenMediaCarousel> createState() => ListenMediaCarouselState();
}

class ListenMediaCarouselState extends State<ListenMediaCarousel> {
  late final PageController _pageController;
  late final List<ListenMediaSlide> _slides;
  late final Map<int, GlobalKey<_CoverVideoState>> _videoKeys;
  int _selected = 0;
  double _playbackSpeed = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slides = ListenMediaSlide.forEpisode(widget.episode);
    _videoKeys = {
      for (var i = 0; i < _slides.length; i++)
        if (_slides[i].kind == ListenMediaKind.video)
          i: GlobalKey<_CoverVideoState>(),
    };
  }

  void pauseVideos() {
    for (final key in _videoKeys.values) {
      key.currentState?.pause();
    }
  }

  void toggleSelectedVideo() => _videoKeys[_selected]?.currentState?.toggle();

  void seekSelectedVideo(double fraction) =>
      _videoKeys[_selected]?.currentState?.seekFraction(fraction);

  void skipSelectedVideo(int seconds) =>
      _videoKeys[_selected]?.currentState?.skip(seconds);

  void setVideoSpeed(double speed) {
    _playbackSpeed = speed;
    _videoKeys[_selected]?.currentState?.setSpeed(speed);
  }

  void _onPageChanged(int index) {
    if (index == _selected) return;
    pauseVideos();
    setState(() => _selected = index);
    widget.onSelectionChanged?.call(index, _slides[index].kind);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _image(ListenMediaSlide slide) {
    final url = slide.url;
    if (url == null) {
      return Image.asset(
        widget.episode.coverAsset ?? widget.episode.thumbnailAsset,
        key: const Key('player_cover_image'),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      key: const Key('player_cover_image'),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, trace) => Image.asset(
        widget.episode.coverAsset ?? widget.episode.thumbnailAsset,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _audio() {
    // The cover is decorative for audio: the existing playback controls
    // below remain the only audio play/pause action.
    return const ColoredBox(
      color: AppColors.outlinedButtonBackground,
      child: Center(
        child: Icon(
          Icons.headphones_rounded,
          key: Key('player_cover_headphones'),
          color: AppColors.primaryOrange,
          size: 72,
        ),
      ),
    );
  }

  Widget _video(int index, ListenMediaSlide slide) {
    if (index != _selected) {
      // Do not initialize/network-buffer inactive video pages.
      return const ColoredBox(
        color: AppColors.heading,
        child: Center(
          child: Icon(
            Icons.play_circle_outline_rounded,
            size: 56,
            color: AppColors.white,
          ),
        ),
      );
    }
    return _CoverVideo(
      key: _videoKeys[index],
      url: slide.url!,
      onPlay: widget.onVideoPlay,
      playbackSpeed: _playbackSpeed,
      onChanged: (snapshot) => widget.onVideoStateChanged?.call(index, snapshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const Key('player_media_viewport'),
      fit: StackFit.expand,
      children: [
        if (_slides.length == 1)
          _buildSlide(0, _slides.first)
        else
          PageView.builder(
            key: const Key('player_media_pager'),
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) => _buildSlide(index, _slides[index]),
          ),
        if (_slides.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 9,
            child: Row(
              key: const Key('player_media_page_indicator'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < _slides.length; index++)
                  AnimatedContainer(
                    key: Key('player_media_dot_$index'),
                    duration: const Duration(milliseconds: 150),
                    width: index == _selected ? 18 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: index == _selected
                          ? AppColors.primaryOrange
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSlide(int index, ListenMediaSlide slide) {
    switch (slide.kind) {
      case ListenMediaKind.artwork:
        return _image(slide);
      case ListenMediaKind.video:
        return _video(index, slide);
      case ListenMediaKind.audio:
        return _audio();
    }
  }
}

/// The selected video is rendered without its own playback toolbar.
class _CoverVideo extends StatefulWidget {
  const _CoverVideo({
    required this.url,
    required this.onPlay,
    required this.onChanged,
    required this.playbackSpeed,
    super.key,
  });

  final String url;
  final VoidCallback onPlay;
  final ValueChanged<VideoPlaybackSnapshot> onChanged;
  final double playbackSpeed;

  @override
  State<_CoverVideo> createState() => _CoverVideoState();
}

class _CoverVideoState extends State<_CoverVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;
  VideoPlaybackSnapshot? _lastSent;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.addListener(_report);
    unawaited(_prepare());
  }

  void _report() {
    if (!mounted) return;
    final value = _controller.value;
    final snapshot = VideoPlaybackSnapshot(
      position: value.position,
      duration: value.duration,
      isPlaying: value.isPlaying,
      isReady: _ready && value.isInitialized,
      hasError: _failed || value.hasError,
    );
    if (snapshot == _lastSent) return;
    _lastSent = snapshot;
    widget.onChanged(snapshot);
  }

  Future<void> _prepare() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() => _ready = true);
      await _controller.setPlaybackSpeed(widget.playbackSpeed);
      _report();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
      _report();
    }
  }

  void pause() {
    if (_ready && _controller.value.isPlaying) {
      unawaited(_controller.pause());
    }
  }

  Future<void> _restartAndPlay() async {
    if (_controller.value.duration > Duration.zero &&
        _controller.value.position >= _controller.value.duration) {
      await _controller.seekTo(Duration.zero);
    }
    if (mounted) await _controller.play();
  }

  void toggle() {
    if (!_ready || _failed) return;
    if (_controller.value.isPlaying) {
      unawaited(_controller.pause());
    } else {
      widget.onPlay();
      unawaited(_restartAndPlay());
    }
  }

  void seekFraction(double fraction) {
    if (!_ready || _failed) return;
    final snapshot = VideoPlaybackSnapshot(
      position: _controller.value.position,
      duration: _controller.value.duration,
    );
    unawaited(_controller.seekTo(snapshot.seekToFraction(fraction)));
  }

  void skip(int seconds) {
    if (!_ready || _failed) return;
    final snapshot = VideoPlaybackSnapshot(
      position: _controller.value.position,
      duration: _controller.value.duration,
    );
    unawaited(_controller.seekTo(snapshot.skipSeconds(seconds)));
  }

  void setSpeed(double speed) {
    if (_ready && !_failed) {
      unawaited(_controller.setPlaybackSpeed(speed));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_report);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const ColoredBox(
        color: AppColors.heading,
        child: Center(
          child: Text(
            'Video unavailable',
            style: TextStyle(color: AppColors.white),
          ),
        ),
      );
    }
    if (!_ready) {
      return const ColoredBox(
        color: AppColors.heading,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    final size = _controller.value.size;
    return ColoredBox(
      color: AppColors.heading,
      child: size.width > 0 && size.height > 0
          ? FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: VideoPlayer(_controller),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            ),
    );
  }
}
