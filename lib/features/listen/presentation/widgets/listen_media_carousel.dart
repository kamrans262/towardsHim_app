import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/models/content_media.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_circular_play_button.dart';
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

/// Replaces the Player's original cover image, with exactly the same bounds
/// and rounded parent container. Audio controls below the cover are unchanged.
class ListenMediaCarousel extends StatefulWidget {
  const ListenMediaCarousel({
    required this.episode,
    required this.onVideoPlay,
    super.key,
  });

  final ListenAudioEpisode episode;
  final VoidCallback onVideoPlay;

  @override
  State<ListenMediaCarousel> createState() => ListenMediaCarouselState();
}

class ListenMediaCarouselState extends State<ListenMediaCarousel> {
  late final PageController _pageController;
  late final List<ListenMediaSlide> _slides;
  late final Map<int, GlobalKey<_CoverVideoState>> _videoKeys;
  int _selected = 0;

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

  void _onPageChanged(int index) {
    pauseVideos();
    setState(() => _selected = index);
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

/// A single visible video. Controller is created only on the selected slide
/// and disposed when navigating away, leaving the rest of the Player intact.
class _CoverVideo extends StatefulWidget {
  const _CoverVideo({
    required this.url,
    required this.onPlay,
    super.key,
  });

  final String url;
  final VoidCallback onPlay;

  @override
  State<_CoverVideo> createState() => _CoverVideoState();
}

class _CoverVideoState extends State<_CoverVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    try {
      await _controller.initialize();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void pause() {
    if (_ready && _controller.value.isPlaying) {
      unawaited(_controller.pause());
    }
  }

  void _toggle() {
    if (!_ready) return;
    if (_controller.value.isPlaying) {
      unawaited(_controller.pause());
    } else {
      // Pause the main audio before video playback is allowed.
      widget.onPlay();
      unawaited(_controller.play());
    }
  }

  @override
  void dispose() {
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final size = _controller.value.size;
        final playing = _controller.value.isPlaying;
        return ColoredBox(
          color: AppColors.heading,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (size.width > 0 && size.height > 0)
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('player_cover_video_action'),
                  onTap: _toggle,
                  child: playing
                      ? const SizedBox.expand()
                      : Center(
                          child: AppCircularPlayButton(
                            isPlaying: false,
                            onPressed: _toggle,
                            diameter: AppSpacing.playerMainPlayDiameter,
                            iconSize: AppSpacing.playerMainPlayIcon,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 8,
                right: 8,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primaryOrange,
                    bufferedColor: AppColors.secondaryText,
                    backgroundColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
