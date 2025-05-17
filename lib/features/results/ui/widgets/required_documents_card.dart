import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:travel_assistant/common/models/response/required_documents.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';

class RequiredDocumentsCard extends StatelessWidget {
  const RequiredDocumentsCard({required this.requiredDocument, super.key});

  final RequiredDocuments requiredDocument;

  @override
  Widget build(BuildContext context) {
    return TravelCard(
      icon: icon,
      title: 'Required Documents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document message
          GptMarkdown(requiredDocument.message, style: Theme.of(context).textTheme.bodyMedium),

          // Document steps if available
          if (requiredDocument.steps != null && requiredDocument.steps!.isNotEmpty) _buildSteps(context),

          // More information if available
          if (requiredDocument.moreInformation != null) ...[
            const SizedBox(height: 16),
            GptMarkdown(requiredDocument.moreInformation!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  IconData get icon => switch (requiredDocument.documentType) {
    RequiredDocumentType.passport => Icons.book,
    RequiredDocumentType.visa => Icons.confirmation_num,
    RequiredDocumentType.eVisa => Icons.confirmation_num,
    RequiredDocumentType.idCard => Icons.credit_card,
    _ => Icons.description,
  };

  // switch (requiredDocument.documentType) {
  //     case RequiredDocumentType.passport:
  //       docIcon = Icons.book;
  //       break;
  //     case RequiredDocumentType.visa:
  //     case RequiredDocumentType.eVisa:
  //       docIcon = Icons.article;
  //       break;
  //     case RequiredDocumentType.idCard:
  //       docIcon = Icons.credit_card;
  //       break;
  //     default:
  //       docIcon = Icons.description;
  //   }

  Widget _buildSteps(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text('Required Steps:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...requiredDocument.steps!.map((step) => _buildListItem(context, step)),
      ],
    );
  }

  // Helper method to build a list item with a bullet point
  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Text(text))],
      ),
    );
  }
}
