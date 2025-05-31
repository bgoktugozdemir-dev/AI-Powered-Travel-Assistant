import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/results/ui/widgets/city_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/currency_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/flight_options_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/required_documents_card.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

/// Screen to display the generated travel plan results after form submission.
class ResultsScreen extends StatelessWidget {
  /// Creates a [ResultsScreen].
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firebaseRemoteConfigRepository = context.read<FirebaseRemoteConfigRepository>();

    return BlocBuilder<TravelFormBloc, TravelFormState>(
      builder: (context, state) {
        final TravelDetails? travelDetails = state.travelPlan;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            automaticallyImplyLeading: false, // Disable back button
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // If we have travel details, show the sections
                  if (travelDetails != null) ...[
                    // City Information Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showCityCard,
                      child: CityCard(
                        city: travelDetails.city,
                        cityImageInBytes: state.cityImageInBytes,
                      ),
                    ),

                    // Required Documents Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showRequiredDocumentsCard,
                      child: RequiredDocumentsCard(
                        requiredDocument: travelDetails.requiredDocuments,
                      ),
                    ),

                    // Currency Information Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showCurrencyCard,
                      child: CurrencyCard(
                        currency: travelDetails.currency,
                        exchangeRate: state.exchangeRate,
                      ),
                    ),

                    // Flight Options Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showFlightOptionsCard,
                      child: FlightOptionsCard(flightOptions: travelDetails.flightOptions),
                    ),

                    // Tax Information Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showTaxInfoCard,
                      child: _buildTaxInfoCard(context, travelDetails, l10n),
                    ),

                    // Top Spots Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showTopSpotsCard,
                      child: _buildSpotsCard(context, travelDetails, l10n),
                    ),

                    // Travel Plan Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showTravelPlanCard,
                      child: _buildItineraryCard(context, travelDetails, l10n),
                    ),

                    // Recommendations Card
                    Visibility(
                      visible: firebaseRemoteConfigRepository.showRecommendationsCard,
                      child: _buildRecommendationsCard(context, travelDetails, l10n),
                    ),
                  ],

                  // Plan Another Trip Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        appLogger.i("New trip button pressed.");
                        // Reset the form and navigate back to the first step
                        context.read<TravelFormBloc>().add(TravelFormStarted());
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.planAnotherTrip),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Tax Information Card
  Widget _buildTaxInfoCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    final tax = details.taxInformation;
    final languageCode = Localizations.localeOf(context).languageCode;
    final taxRateFormatter = NumberFormat.percentPattern(languageCode);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(l10n.taxInformationTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            _buildInfoRow(
              context,
              l10n.taxRateLabel,
              taxRateFormatter.format(tax.taxRate / 100),
              Icons.percent,
            ),

            _buildInfoRow(
              context,
              l10n.taxFreeShoppingLabel,
              tax.hasTaxFreeOptions ? l10n.availableLabel : l10n.notAvailableLabel,
              Icons.shopping_bag,
              iconColor: tax.hasTaxFreeOptions ? Colors.green : Colors.red,
            ),

            if (tax.refundableTaxRate > 0)
              _buildInfoRow(
                context,
                l10n.refundableTaxRateLabel,
                taxRateFormatter.format(tax.refundableTaxRate / 100),
                Icons.percent,
                iconColor: Colors.green,
              ),

            const SizedBox(height: 8),
            Text(tax.taxRefundInformation, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  // Top Spots Card
  Widget _buildSpotsCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(l10n.placesToVisitTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // List of spots
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.spots.length,
              itemBuilder: (context, index) {
                final spot = details.spots[index];
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(spot.place),
                  subtitle: Text(spot.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      // Show a dialog with full spot details
                      showDialog(
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
                                      Text(l10n.requirementsLabel, style: Theme.of(context).textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(spot.requirements!),
                                    ],
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.closeLabel)),
                              ],
                            ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Travel Plan/Itinerary Card
  Widget _buildItineraryCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    if (details.travelPlan.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(l10n.travelItineraryTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // List of days with events
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.travelPlan.length,
              itemBuilder: (context, index) {
                final dayPlan = details.travelPlan[index];
                final date = dayPlan.date;

                return ExpansionTile(
                  title: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(date),
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
                              children: [Text(event.time), Text(event.location)],
                            ),
                            trailing:
                                event.requirements != null
                                    ? IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      onPressed: () {
                                        // Show a dialog with full event details
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: Text(event.name),
                                                content: Text(event.requirements!),
                                              ),
                                        );
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
        ),
      ),
    );
  }

  // Recommendations Card
  Widget _buildRecommendationsCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(l10n.recommendationsTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // List of recommendations
            ...details.recommendations.map((recommendation) => _buildListItem(context, recommendation)),
          ],
        ),
      ),
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

  // Helper method to build an info row with icon
  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)],
            ),
          ),
        ],
      ),
    );
  }
}
