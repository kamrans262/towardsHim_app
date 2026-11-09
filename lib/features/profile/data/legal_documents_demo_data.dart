import '../domain/models/legal_document.dart';

/// These are layout placeholders, NOT approved legal documents.
/// Replace with the organization's actual reviewed text before publishing.
abstract final class LegalDocumentsDemoData {
  static const draftNotice =
      'Draft content for UI preview only. Replace with an approved document '
      'before publishing the app.';

  static const privacy = LegalDocument(
    title: 'Privacy Policy',
    description:
        'Your privacy matters. This preview outlines the topics the '
        'final Toward HIM privacy policy will address.',
    sections: <LegalSection>[
      LegalSection(
        heading: 'Account and Profile',
        body:
            'The final policy will explain how names, email addresses, '
            'profile photos, and optional biographies are handled.',
      ),
      LegalSection(
        heading: 'Community Posts and Replies',
        body:
            'The final policy will explain who can see content you share '
            'with the community, and how posts and replies are moderated '
            'or removed.',
      ),
      LegalSection(
        heading: 'Listening and Challenge Progress',
        body:
            'The final policy will describe whether playback activity, '
            'saved content, challenge progress, and personal preferences '
            'are collected or retained.',
      ),
      LegalSection(
        heading: 'Notifications and Services',
        body:
            'The final policy will identify notification settings, '
            'third-party providers, and any information used to deliver '
            'app features.',
      ),
      LegalSection(
        heading: 'Your Choices and Contact',
        body:
            'The approved policy will explain available account-data '
            'controls, deletion requests, and verified contact details.',
      ),
    ],
  );

  static const terms = LegalDocument(
    title: 'Terms of Service',
    description:
        'Toward HIM is a space to listen, reflect, and encourage others. '
        'These sample sections show the intended Terms of Service layout.',
    sections: <LegalSection>[
      LegalSection(
        heading: 'Using Toward HIM',
        body:
            'The final terms will describe access to the app, account '
            'eligibility, and any conditions for using its features.',
      ),
      LegalSection(
        heading: 'Community Guidelines',
        body:
            'The final terms will set expectations for respectful '
            'participation, personal safety, and appropriate posts '
            'and replies.',
      ),
      LegalSection(
        heading: 'Content and Media',
        body:
            'The final terms will explain ownership and permitted use '
            'of podcasts, guided reflections, prayers, and other content.',
      ),
      LegalSection(
        heading: 'Accounts and Changes',
        body:
            'The final terms will clarify account responsibilities, '
            'deletion, service changes, and any applicable restrictions.',
      ),
      LegalSection(
        heading: 'Help and Contact',
        body:
            'The approved terms will provide a verified way to contact '
            'the organization with questions about the service.',
      ),
    ],
  );
}
