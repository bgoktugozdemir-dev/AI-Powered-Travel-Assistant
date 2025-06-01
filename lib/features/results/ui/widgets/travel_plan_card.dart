import 'package:flutter/material.dart';
import 'package:travel_assistant/common/models/response/travel_plan.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/common/utils/helpers/formatters.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TravelPlanCard extends StatelessWidget {
  const TravelPlanCard({required this.travelPlan, super.key});

  final List<TravelPlan> travelPlan;

  @override
  Widget build(BuildContext context) {
    if (travelPlan.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);

    return TravelCard(
      icon: Icons.event,
      title: l10n.travelItineraryTitle,
      children: [
        // List of days with events
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: travelPlan.length,
          itemBuilder: (context, index) {
            final dayPlan = travelPlan[index];
            final date = dayPlan.date;

            return ExpansionTile(
              title: Text(
                Formatters.fullDate(date),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children:
                  dayPlan.events.map(
                    (event) {
                      return ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(event.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.time),
                            Text(event.location),
                          ],
                        ),
                        trailing:
                            event.requirements != null
                                ? IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    _showEventDetails(context, event);
                                  },
                                )
                                : null,
                        isThreeLine: true,
                      );
                    },
                  ).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showEventDetails(BuildContext context, TravelEvent event) async {
    // Show a dialog with full event details
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(event.name),
            content: Text(event.requirements!),
          ),
    );
  }
}
