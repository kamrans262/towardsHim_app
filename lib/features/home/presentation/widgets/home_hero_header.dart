import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header_actions.dart';
import '../../domain/models/home_models.dart';

class HomeHeroHeader extends StatelessWidget {
  const HomeHeroHeader({
    required this.profile,
    required this.onNotifications,
    required this.onProfile,
    super.key,
  });

  final HomeUserProfile profile;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppSpacing.homeContentMaxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '${profile.greeting}\n',
                            style: AppTypography.homeGreeting,
                          ),
                          TextSpan(
                            text: profile.firstName,
                            style: AppTypography.homeGreetingName,
                          ),
                        ]),
                        key: const Key('home_greeting'),
                        maxLines: 2,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppHeaderActions(
                    onNotifications: onNotifications,
                    onProfile: onProfile,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${profile.scripture}\n${profile.scriptureReference}',
                style: AppTypography.homeScripture,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
