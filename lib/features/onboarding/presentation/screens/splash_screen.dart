import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/toward_him_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    this.onFinished,
    this.duration = const Duration(milliseconds: 1600),
    super.key,
  });

  final VoidCallback? onFinished;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.onFinished != null) {
      _timer = Timer(widget.duration, () {
        if (mounted) widget.onFinished?.call();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: TowardHimLogo()),
    );
  }
}
