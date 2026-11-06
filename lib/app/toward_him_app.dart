import 'package:flutter/material.dart';

import '../core/navigation/app_router.dart';
import '../core/theme/app_theme.dart';

class TowardHimApp extends StatelessWidget {
  const TowardHimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toward HIM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
