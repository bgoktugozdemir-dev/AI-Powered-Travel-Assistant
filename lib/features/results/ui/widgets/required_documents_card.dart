import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:travel_assistant/common/models/response/required_documents.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  static const String bulletPoint = '•';
}

class RequiredDocumentsCard extends StatelessWidget {
  const RequiredDocumentsCard({required this.requiredDocument, super.key});

  final RequiredDocuments requiredDocument;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TravelCard(
      icon: icon,
      title: l10n.requiredDocumentsTitle,
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
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(l10n.requiredStepsLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...requiredDocument.steps!.map((step) => _buildListItem(context, step)),
      ],
    );
  }

  // Helper method to build a list item with a bullet point
  Widget _buildListItem(BuildContext context, String text) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(text: '${_Constants.bulletPoint} ', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
