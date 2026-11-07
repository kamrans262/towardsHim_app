import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../domain/models/home_models.dart';

class HomeFeaturedCard extends StatelessWidget {
  const HomeFeaturedCard({
    required this.content,
    required this.onPressed,
    super.key,
  });

  final HomeFeaturedContent content;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: content.title,
      child: InkWell(
        key: const Key('home_featured_card'),
        borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
        onTap: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.homeCardRadius),
          child: AppContentCard(
            minHeight: AppSpacing.homeFeaturedMinHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageWidth = constraints.maxWidth < 270 ? 72.0 : 104.0;
                final textRightPadding =
                    constraints.maxWidth < 270 ? 55.0 : 84.0;
                return Stack(
                  children: [
                    Positioned(
                      top: -20,
                      bottom: -20,
                      right: -20,
                      width: imageWidth,
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                          ],
                          stops: [0, 0.48],
                        ).createShader(bounds),
                        child: Image.asset(
                          content.imageAsset,
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: textRightPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.category,
                            style: AppTypography.homeAccent,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content.title,
                            style: AppTypography.featuredTitle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            content.description,
                            style: AppTypography.homeSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
