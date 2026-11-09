enum AboutSectionType { mission, vision, values }

class AboutSection {
  const AboutSection({
    required this.type,
    required this.title,
    required this.description,
  });

  final AboutSectionType type;
  final String title;
  final String description;
}

class AboutSocial {
  const AboutSocial({required this.name, required this.asset});
  final String name;
  final String asset;
}
