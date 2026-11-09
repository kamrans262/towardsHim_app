/// Display-only legal-page structure.
///
/// The content in this milestone is sample text pending approval; it does not
/// purport to be a published legal policy or a statement of implemented APIs.
class LegalSection {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.description,
    required this.sections,
  });

  final String title;
  final String description;
  final List<LegalSection> sections;
}
