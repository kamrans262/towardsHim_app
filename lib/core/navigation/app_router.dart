import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/create_account_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_placeholder_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const createAccount = '/create-account';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
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
            onBack: () => Navigator.of(context).maybePop(),
            onCreateAccount: () =>
                Navigator.of(context).pushNamed(AppRoutes.createAccount),
            onForgotPassword: () =>
                Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
          ),
        AppRoutes.forgotPassword => const ForgotPasswordPlaceholderScreen(),
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
