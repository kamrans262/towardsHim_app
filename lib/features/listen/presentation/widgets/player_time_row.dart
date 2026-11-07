import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

class PlayerTimeRow extends StatelessWidget {
  const PlayerTimeRow({
    required this.current,
    required this.total,
    super.key,
  });

  final String current;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(current, style: AppTypography.playerTime),
        const Spacer(),
        Text(total, style: AppTypography.playerTime),
      ],
    );
  }
}
