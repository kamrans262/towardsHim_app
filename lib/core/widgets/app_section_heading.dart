import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

class AppSectionHeading extends StatelessWidget {
  const AppSectionHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.sectionHeading,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
