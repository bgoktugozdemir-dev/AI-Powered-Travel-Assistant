import 'package:flutter/material.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({
    required this.icon,
    required this.title,
    required this.content,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String content;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return TravelCard(
      icon: icon,
      title: title,
      iconColor: iconColor,
      children: [
        Text(
          content,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
