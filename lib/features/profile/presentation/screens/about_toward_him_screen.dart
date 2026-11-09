import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/about_toward_him_demo_data.dart';
import '../../domain/models/about_toward_him.dart';
import '../widgets/about_contact_card.dart';
import '../widgets/about_hero_header.dart';
import '../widgets/about_section_card.dart';

/// About Toward HIM, built from shared Flutter components and Figma copy.
/// Deliberately separate from the app shell: no bottom bar on this detail page.
class AboutTowardHimScreen extends StatelessWidget {
  const AboutTowardHimScreen({super.key});

  void _notice(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  void _openSection(BuildContext context, AboutSection section) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.title, style: AppTypography.sectionHeading),
              const SizedBox(height: 15),
              Text(
                section.description,
                style: AppTypography.homeSecondary,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('about_toward_him_scaffold'),
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          key: const Key('about_toward_him_scroll'),
          slivers: [
            SliverToBoxAdapter(
              child: AboutHeroHeader(
                onBack: () => Navigator.of(context).maybePop(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.homeContentMaxWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenBottom +
                            MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        key: const Key('about_toward_him_content'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AboutTowardHimDemoData.title,
                            style: AppTypography.mainScreenTitle.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AboutTowardHimDemoData.subtitle,
                            style: AppTypography.homeSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AboutTowardHimDemoData.description,
                            style: AppTypography.homeSecondary,
                          ),
                          const SizedBox(height: 25),
                          for (var index = 0;
                              index < AboutTowardHimDemoData.sections.length;
                              index++) ...[
                            if (index != 0) const SizedBox(height: 15),
                            AboutSectionCard(
                              key: ValueKey(
                                AboutTowardHimDemoData.sections[index].type,
                              ),
                              section: AboutTowardHimDemoData.sections[index],
                              onPressed: () => _openSection(
                                context,
                                AboutTowardHimDemoData.sections[index],
                              ),
                            ),
                          ],
                          const SizedBox(height: 15),
                          AboutContactCard(
                            onNotice: (message) => _notice(context, message),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
