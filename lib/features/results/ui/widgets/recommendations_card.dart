import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class RecommendationsCard extends StatelessWidget {
  const RecommendationsCard({
    required this.recommendations,
    super.key,
  });

  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TravelCard(
      icon: Icons.lightbulb,
      title: l10n.recommendationsTitle,
      children:
          recommendations
              .map(
                (recommendation) => _buildListItem(context, recommendation),
              )
              .toList(),
    );
  }

  // Helper method to build a list item with a bullet point
  Widget _buildListItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GptMarkdown(text),
    );
  }
}
