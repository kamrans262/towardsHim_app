import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => switch (settings.name) {
        AppRoutes.splash => SplashScreen(
            onFinished: () => Navigator.of(context)
                .pushReplacementNamed(AppRoutes.welcome),
          ),
        AppRoutes.welcome => WelcomeScreen(
            onCreateAccount: () => _notifyFutureModule(
              context,
              'Create Account',
            ),
            onLogin: () => _notifyFutureModule(context, 'Login'),
            onContinueAsGuest: () => _notifyFutureModule(
              context,
              'Guest Home',
            ),
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
