import 'package:flutter/material.dart';
import 'package:travel_assistant/common/models/response/travel_spot.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TopSpotsCard extends StatelessWidget {
  const TopSpotsCard({
    required this.spots,
    super.key,
  });

  final List<TravelSpot> spots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TravelCard(
      icon: Icons.place,
      title: l10n.placesToVisitTitle,
      children: [
        // List of spots
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: spots.length,
          itemBuilder: (_, index) {
            final spot = spots[index];

            return ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(spot.place),
              subtitle: Text(
                spot.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showSpotDetails(context, spot),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showSpotDetails(BuildContext context, TravelSpot spot) async {
    final l10n = AppLocalizations.of(context);

    // Show a dialog with full spot details
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(spot.place),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spot.description),
                  if (spot.requirements != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.requirementsLabel,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(spot.requirements!),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.closeLabel),
              ),
            ],
          ),
    );
  }
}
