import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/data/auth_repository.dart';
import '../../../profile/data/platform_content_store.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../notifications/data/notification_repository.dart';
import '../../../notifications/services/push_registration_service.dart';
import '../../data/home_demo_data.dart';
import '../../domain/models/home_models.dart';
import '../controllers/home_navigation_controller.dart';
import 'home_dashboard_screen.dart';
import '../../../listen/presentation/screens/listen_screen.dart';
import '../../../listen/domain/models/listen_audio_episode.dart';
import '../../../listen/data/audio_catalog_repository.dart';
import '../../../weekly_challenges/presentation/screens/weekly_challenges_screen.dart';
import '../../../weekly_challenges/data/challenge_repository.dart';
import '../../../weekly_challenges/domain/models/weekly_challenge.dart';
import '../../../community/presentation/screens/community_screen.dart';
import '../../../community/data/community_repository.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

/// Existing main shell, preserving approved widgets and navigation.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({this.guestMode = false, this.initialTab = HomeTab.home,
    this.challengeRepository, this.communityRepository,
    this.notificationRepository, this.audioRepository, super.key});

  final bool guestMode;
  final HomeTab initialTab;
  final ChallengeRepository? challengeRepository;
  final CommunityRepository? communityRepository;
  final NotificationRepository? notificationRepository;
  final AudioCatalogRepository? audioRepository;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late final HomeNavigationController _navigation;
  late final NotificationsController _notifications;
  late final ProfileController _profile;
  late final Listenable _shellListeners;
  bool _showProfile = false;
  HomeQuickType? _listenCategory;
  late final ChallengeRepository _challengeRepository;
  WeeklyChallenge? _currentChallenge;
  List<ListenAudioEpisode> _publishedAudio = const [];
  bool _homeAudioLoading = true;
  String? _homeAudioError;

  @override
  void initState() {
    super.initState();
    _navigation = HomeNavigationController()..select(widget.initialTab);
    _notifications = NotificationsController(repository: widget.notificationRepository);
    _profile = ProfileController();
    unawaited(PlatformContentStore.instance.load());
    unawaited(_refreshHomeAudio());
    _challengeRepository = widget.challengeRepository ?? ChallengeRepository.instance;
    _challengeRepository.addListener(_refreshCurrentChallenge);
    _refreshCurrentChallenge();
    _shellListeners = Listenable.merge([_navigation, _profile]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.guestMode) return;
      unawaited(PushRegistrationService.instance.start(
        onMessage: () => unawaited(_notifications.load()),
        onOpenAudio: (id) => unawaited(_openPushedAudio(id)),
      ));
    });
  }

  @override
  void dispose() {
    _navigation.dispose();
    _notifications.dispose();
    _profile.dispose();
    _challengeRepository.removeListener(_refreshCurrentChallenge);
    unawaited(PushRegistrationService.instance.stop(unregister: false));
    super.dispose();
  }

  Future<void> _refreshHomeAudio() async {
    try {
      final items = await (widget.audioRepository ??
          const AudioCatalogRepository()).fetchPublished();
      if (!mounted) return;
      setState(() {
        _publishedAudio = items;
        _homeAudioError = null;
        _homeAudioLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _homeAudioError = error.toString();
        _homeAudioLoading = false;
      });
    }
  }

  void _openAudio(ListenAudioEpisode episode) {
    Navigator.of(context).pushNamed(
      AppRoutes.player,
      arguments: episode,
    );
  }

  Future<void> _refreshCurrentChallenge() async {
    if (widget.guestMode || !AuthRepository.instance.isAuthenticated) return;
    try {
      final items = await _challengeRepository.list();
      if (!mounted) return;
      setState(() {
        for (final item in items) {
          if (item.category == WeeklyChallengeCategory.featured) {
            _currentChallenge = item;
            return;
          }
        }
        _currentChallenge = null;
      });
    } catch (_) {
      // The home remains usable when the challenge service is unavailable.
    }
  }

  void _openChallenge(WeeklyChallenge challenge) {
    Navigator.of(context).pushNamed(
      AppRoutes.weeklyChallengeDetail,
      arguments: WeeklyChallengeNavigationArgs(
        challenge: challenge,
        repository: widget.challengeRepository,
      ),
    );
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openPushedAudio(String id) async {
    try {
      final episode = await (widget.notificationRepository ??
          const NotificationRepository()).fetchAudio(id);
      if (!mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.player, arguments: episode);
    } catch (_) {
      if (mounted) _showNotice('The selected audio is no longer available.');
    }
  }

  void _openNotifications() {
    if (widget.guestMode) {
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }
    Navigator.of(context).pushNamed(
      AppRoutes.notifications,
      arguments: _notifications,
    );
  }

  void _openQuickMedia(HomeQuickType type) {
    setState(() {
      _listenCategory = type;
      _showProfile = false;
    });
    _navigation.select(HomeTab.listen);
  }

  void _openProfile() {
    if (_showProfile) return;
    setState(() => _showProfile = true);
  }

  Future<void> _logout() async {
    await PushRegistrationService.instance.stop();
    try {
      await AuthRepository.instance.logout();
    } catch (_) {
      // Local token is cleared even when the network is unavailable.
    }
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.welcome,
      (route) => false,
    );
  }

  Future<void> _openStore() async {
    // Keep the existing immediate placeholder behavior if no store URL is set.
    // The public content loads separately in the shell and Welcome screen.
    if (!mounted) return;
    final raw = PlatformContentStore.instance.content.storeUrl;
    final url = raw == null ? null : Uri.tryParse(raw.trim());
    if (url == null || url.scheme != 'https' || url.host.isEmpty) {
      _showNotice('Merchandise Store URL has not been configured.');
      return;
    }
    try {
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened && mounted) _showNotice('Unable to open the store.');
    } catch (_) {
      if (mounted) _showNotice('Unable to open the store.');
    }
  }

  void _select(HomeTab tab) {
    if (tab == HomeTab.store) {
      unawaited(_openStore());
      return;
    }
    if (widget.guestMode &&
        (tab == HomeTab.towardHimThree || tab == HomeTab.community)) {
      Navigator.of(context).pushNamed(AppRoutes.login, arguments: tab);
      return;
    }
    _navigation.select(tab);
    if (tab == HomeTab.home) unawaited(_refreshHomeAudio());
    if (_showProfile) setState(() => _showProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AnimatedBuilder(
        animation: _shellListeners,
        builder: (context, _) {
          final selected = _navigation.selected;
          return Scaffold(
            key: const Key('home_shell'),
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                Offstage(
                  offstage: _showProfile,
                  child: IndexedStack(
                    index: selected.index,
              children: [
                HomeDashboardScreen(
                  firstName: widget.guestMode || !AuthRepository.instance.isAuthenticated
                      ? 'Friend'
                      : _profile.user.fullName.trim().split(RegExp(r'\s+')).first,
                  guestMode: widget.guestMode || !AuthRepository.instance.isAuthenticated,
                  currentChallenge: _currentChallenge,
                  publishedAudio: _publishedAudio,
                  audioLoading: _homeAudioLoading,
                  audioError: _homeAudioError,
                  onRefreshAudio: () => unawaited(_refreshHomeAudio()),
                  onOpenAudio: _openAudio,
                  onLoginRequired: () => Navigator.of(context).pushNamed(
                    AppRoutes.login, arguments: HomeTab.towardHimThree,
                  ),
                  onOpenChallenge: _openChallenge,
                  onSelectTab: _select,
                  onOpenQuickMedia: _openQuickMedia,
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                ),
                ListenScreen(
                  repository: widget.audioRepository,
                  selectedCategory: _listenCategory,
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                  onOpenQuickMedia: _openQuickMedia,
                  onOpenEpisode: (ListenAudioEpisode episode) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.player,
                      arguments: episode,
                    );
                  },
                ),
                WeeklyChallengesScreen(
                  active: selected == HomeTab.towardHimThree,
                  repository: widget.challengeRepository,
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                  onOpenChallenge: _openChallenge,
                ),
                CommunityScreen(
                  repository: widget.communityRepository,
                  active: selected == HomeTab.community,
                  onNotice: _showNotice,
                  onNotifications: _openNotifications,
                  onProfile: _openProfile,
                ),
                const _UpcomingTab(
                  title: 'Store',
                  message: 'Merchandise Store URL has not been configured.',
                ),
                  ],
                ),
              ),
              if (_showProfile)
                ProfileScreen(
                  controller: _profile,
                  onNotifications: _openNotifications,
                  onNotice: _showNotice,
                  onLogout: _logout,
                ),
              ],
            ),
            bottomNavigationBar: AppBottomNavigation(
              items: [
                for (final item in HomeDemoData.navigation)
                  AppBottomNavigationDestination(
                    label: item.label,
                    iconAsset: item.iconAsset,
                  ),
              ],
              selectedIndex: selected.index,
              onSelected: (index) {
                final tab = HomeDemoData.navigation[index].tab;
                // No external store URL was supplied; a local placeholder
                // is shown instead of inventing an outbound destination.
                _select(tab);
              },
            ),
          );
        },
      ),
    );
  }
}

class _UpcomingTab extends StatelessWidget {
  const _UpcomingTab({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.homeContentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: AppTypography.description,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
