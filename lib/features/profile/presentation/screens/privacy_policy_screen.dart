import 'package:flutter/material.dart';

import '../../data/legal_documents_demo_data.dart';
import '../widgets/legal_document_view.dart';

/// Privacy Policy design preview; approved legal copy is pending.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentView(
      key: const Key('privacy_policy_screen'),
      document: LegalDocumentsDemoData.privacy,
      onBack: () => Navigator.of(context).maybePop(),
    );
  }
}
