import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_content_card.dart';
import '../../data/about_toward_him_demo_data.dart';
import '../../domain/models/about_toward_him.dart';

/// Exact approved contact copy and supplied social SVG artwork.
/// Outbound URLs have not been supplied: the UI does not invent them.
class AboutContactCard extends StatelessWidget {
  const AboutContactCard({required this.onNotice, super.key});

  final ValueChanged<String> onNotice;

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    onNotice('$label copied');
  }

  @override
  Widget build(BuildContext context) {
    return AppContentCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Get in Touch',
            style: AppTypography.cardTitle,
          ),
          const SizedBox(height: 12),
          _contactRow(
            key: const Key('about_contact_primary_email'),
            icon: Icons.mail_outline_rounded,
            iconAsset: 'assets/icons/wpf_message-outline.svg',
            value: AboutTowardHimDemoData.primaryEmail,
            onTap: () => _copy(AboutTowardHimDemoData.primaryEmail, 'Email'),
          ),
          const SizedBox(height: 12),
          _contactRow(
            key: const Key('about_contact_address'),
            icon: Icons.location_on_outlined,
            value: AboutTowardHimDemoData.address,
            onTap: () => _copy(AboutTowardHimDemoData.address, 'Address'),
          ),
          const SizedBox(height: 15),
          const Text(
            'Stay Connected',
            style: AppTypography.cardTitle,
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final social in AboutTowardHimDemoData.socials)
                _socialIcon(social),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            AboutTowardHimDemoData.socialNames,
            style: AppTypography.homeSecondary.copyWith(
              fontWeight: FontWeight.w400,
              fontVariations: const [FontVariation('wght', 400)],
              height: 1.35,
            ),
          ),
          const SizedBox(height: 15),
          _contactRow(
            key: const Key('about_contact_secondary_email'),
            icon: Icons.mail_outline_rounded,
            iconAsset: 'assets/icons/wpf_message-outline.svg',
            value: AboutTowardHimDemoData.secondaryEmail,
            onTap: () => _copy(AboutTowardHimDemoData.secondaryEmail, 'Email'),
          ),
          const SizedBox(height: 12),
          _contactRow(
            key: const Key('about_contact_website'),
            icon: Icons.language_rounded,
            value: AboutTowardHimDemoData.website,
            valueColor: AppColors.primaryOrange,
            onTap: () => _copy(AboutTowardHimDemoData.website, 'Website'),
          ),
        ],
      ),
    );
  }

  Widget _contactRow({
    required Key key,
    required IconData icon,
    String? iconAsset,
    required String value,
    required VoidCallback onTap,
    Color? valueColor,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconAsset != null)
            SvgPicture.asset(iconAsset, width: 16, height: 16)
          else
            Icon(
              icon,
              size: 16,
              color: AppColors.primaryOrange,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: AppTypography.homeSecondary.copyWith(
                color: valueColor ?? AppColors.secondaryText,
                fontWeight: FontWeight.w400,
                fontVariations: const [FontVariation('wght', 400)],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(AboutSocial social) {
    return Tooltip(
      message: social.name,
      child: InkWell(
        key: Key('about_social_${social.name.toLowerCase()}'),
        onTap: () => onNotice(
          '${social.name} link will be configured in a later phase.',
        ),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SvgPicture.asset(
              social.asset,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              semanticsLabel: social.name,
            ),
          ),
        ),
      ),
    );
  }
}
