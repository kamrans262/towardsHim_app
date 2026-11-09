import '../domain/models/about_toward_him.dart';

/// User-provided Figma copy, preserved in the UI-only fixture.
abstract final class AboutTowardHimDemoData {
  static const title = 'About Toward HIM';
  static const subtitle = 'A journey of faith. a journey with god';
  static const description =
      'Moving toward HIM is not about becoming perfect or having all the '
      'answers; it is about turning to Him, even when your heart feels '
      'heavy and your faith feels small.';

  static const sectionDescription =
      'To help people everywhere grow closer to god in your everyday life';

  static const sections = <AboutSection>[
    AboutSection(
      type: AboutSectionType.mission,
      title: 'Our Mission',
      description: sectionDescription,
    ),
    AboutSection(
      type: AboutSectionType.vision,
      title: 'Our Vision',
      description: sectionDescription,
    ),
    AboutSection(
      type: AboutSectionType.coreValues,
      title: 'Our Values',
      description: sectionDescription,
    ),
  ];

  static const primaryEmail = 'Hello.towardHIM@gmail.com';
  static const secondaryEmail = 'Hello.towardHIM@gmail.com';
  static const address = '269 walker st., STE 211 Detroit, MI 48270';
  static const website = 'TowardHIM.com';
  static const socialNames =
      'Facebook · Instagram · TikTok · YouTube · Spotify · Apple Podcasts';

  static const socials = <AboutSocial>[
    AboutSocial(name: 'Facebook', asset: 'assets/icons/profile/facebook.svg'),
    AboutSocial(name: 'Instagram', asset: 'assets/icons/profile/instagram.svg'),
    AboutSocial(name: 'TikTok', asset: 'assets/icons/profile/tiktok.svg'),
    AboutSocial(name: 'YouTube', asset: 'assets/icons/profile/youtube.svg'),
  ];
}
