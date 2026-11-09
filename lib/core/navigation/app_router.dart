import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/create_account_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/community/presentation/screens/community_create_post_screen.dart';
import '../../features/listen/domain/models/listen_audio_episode.dart';
import '../../features/weekly_challenges/domain/models/weekly_challenge.dart';
import '../../features/weekly_challenges/domain/models/daily_challenge.dart';
import '../../features/weekly_challenges/presentation/screens/daily_challenge_screen.dart';
import '../../features/weekly_challenges/presentation/screens/weekly_challenge_detail_screen.dart';
import '../../features/listen/presentation/screens/audio_player_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const createAccount = '/create-account';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const player = '/player';
  static const weeklyChallengeDetail = '/weekly-challenge-detail';
  static const dailyChallengeDetail = '/daily-challenge-detail';
  static const communityCreatePost = '/community/create-post';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Post creation returns a String to the Community screen; unlike
    // standard void routes, it must use MaterialPageRoute<String>.
    if (settings.name == AppRoutes.communityCreatePost) {
      return MaterialPageRoute<String>(
        settings: settings,
        builder: (_) => const CommunityCreatePostScreen(),
      );
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => switch (settings.name) {
        AppRoutes.splash => SplashScreen(
            onFinished: () => Navigator.of(context)
                .pushReplacementNamed(AppRoutes.welcome),
          ),
        AppRoutes.welcome => WelcomeScreen(
            onCreateAccount: () =>
                Navigator.of(context).pushNamed(AppRoutes.createAccount),
            onLogin: () => Navigator.of(context).pushNamed(AppRoutes.login),
            onContinueAsGuest: () => _notifyFutureModule(
              context,
              'Guest Home',
            ),
          ),
        AppRoutes.createAccount => CreateAccountScreen(
            onBack: () => Navigator.of(context).maybePop(),
            onLogin: () => Navigator.of(context).pushNamed(AppRoutes.login),
          ),
        AppRoutes.login => LoginScreen(
            onLogin: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
            onBack: () => Navigator.of(context).maybePop(),
            onCreateAccount: () =>
                Navigator.of(context).pushNamed(AppRoutes.createAccount),
            onForgotPassword: () =>
                Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
          ),
        AppRoutes.home => const HomeShellScreen(),
        AppRoutes.dailyChallengeDetail => settings.arguments is DailyChallenge
            ? DailyChallengeScreen(
                challenge: settings.arguments! as DailyChallenge,
              )
            : const WelcomeScreen(),
        AppRoutes.weeklyChallengeDetail => settings.arguments is WeeklyChallenge
            ? WeeklyChallengeDetailScreen(
                challenge: settings.arguments! as WeeklyChallenge,
              )
            : const WelcomeScreen(),
        AppRoutes.player => settings.arguments is ListenAudioEpisode
            ? AudioPlayerScreen(
                episode: settings.arguments! as ListenAudioEpisode,
              )
            : const WelcomeScreen(),
        AppRoutes.forgotPassword => ForgotPasswordScreen(
            onBack: () => Navigator.of(context).maybePop(),
            onBackToLogin: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.login),
          ),
        _ => const WelcomeScreen(),
      },
    );
  }

  // UI-only phase: destinations are replaced by their approved module screens.
  static void _notifyFutureModule(BuildContext context, String destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$destination UI is planned for a later module.')),
    );
  }
}
