import 'package:flutter/material.dart';

import '../../data/legal_documents_demo_data.dart';
import '../widgets/legal_document_view.dart';

/// Terms of Service design preview; approved legal copy is pending.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentView(
      key: const Key('terms_of_service_screen'),
      document: LegalDocumentsDemoData.terms,
      onBack: () => Navigator.of(context).maybePop(),
    );
  }
}
