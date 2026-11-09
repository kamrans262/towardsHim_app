import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../../../core/widgets/app_detail_page_header.dart';
import '../../data/legal_documents_demo_data.dart';
import '../../domain/models/legal_document.dart';

/// Shared standalone legal layout, consistent with Profile detail pages.
/// Both documents are local preview content: no API and no bottom navigation.
class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    required this.document,
    required this.onBack,
    super.key,
  });

  final LegalDocument document;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: const Key('legal_document_scaffold'),
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            key: const Key('legal_document_scroll'),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.homeContentMaxWidth,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenTop,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenBottom +
                            MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppDetailPageHeader(
                            title: document.title,
                            onBack: onBack,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            document.description,
                            key: const Key('legal_document_intro'),
                            style: AppTypography.homeSecondary.copyWith(
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppContentCard(
                            backgroundColor: AppColors.podcastTile,
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primaryOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    LegalDocumentsDemoData.draftNotice,
                                    key: const Key('legal_draft_notice'),
                                    style: AppTypography.homeSecondary.copyWith(
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          for (var index = 0;
                              index < document.sections.length;
                              index++) ...[
                            if (index > 0) const SizedBox(height: 15),
                            AppContentCard(
                              key: Key('legal_section_$index'),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    document.sections[index].heading,
                                    style: AppTypography.cardTitle,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    document.sections[index].body,
                                    style: AppTypography.homeSecondary.copyWith(
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
