import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/models/response/required_documents.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/results/ui/widgets/flight_options_card.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Screen to display the generated travel plan results after form submission.
class ResultsScreen extends StatelessWidget {
  /// Creates a [ResultsScreen].
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                    _buildCityCard(context, travelDetails, l10n),

                    // Required Documents Card
                    _buildDocumentsCard(context, travelDetails, l10n),

                    // Currency Information Card
                    _buildCurrencyCard(context, travelDetails, l10n),

                    // Flight Options Card
                    FlightOptionsCard(flightOptions: travelDetails.flightOptions),

                    // Tax Information Card
                    _buildTaxInfoCard(context, travelDetails, l10n),

                    // Top Spots Card
                    _buildSpotsCard(context, travelDetails, l10n),

                    // Travel Plan Card
                    _buildItineraryCard(context, travelDetails, l10n),

                    // Recommendations Card
                    _buildRecommendationsCard(context, travelDetails, l10n),
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

  // City Information Card
  Widget _buildCityCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // City Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
            child: Image.network(
              details.city.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 48)),
                );
              },
            ),
          ),

          // City Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${details.city.name}, ${details.city.country}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (details.city.time != null)
                      Tooltip(
                        message: 'Time difference: ${details.city.time!.differenceInHours} hours',
                        child: Chip(
                          label: Text(details.city.time!.arrivalTimezone),
                          avatar: const Icon(Icons.access_time, size: 16),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Crowd Level
                Row(
                  children: [
                    const Icon(Icons.people, size: 18),
                    const SizedBox(width: 8),
                    Text('Crowd Level: ', style: Theme.of(context).textTheme.bodyMedium),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: details.city.crowdLevel / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          details.city.crowdLevel < 30
                              ? Colors.green
                              : details.city.crowdLevel < 70
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${details.city.crowdLevel}%'),
                  ],
                ),

                // Weather information if available
                if (details.city.weather != null && details.city.weather!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Weather Forecast', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: details.city.weather!.length,
                      itemBuilder: (context, index) {
                        final weather = details.city.weather![index];

                        // Get weather icon
                        IconData weatherIcon;
                        switch (weather.weather.toLowerCase()) {
                          case 'sunny':
                            weatherIcon = Icons.wb_sunny;
                            break;
                          case 'cloudy':
                            weatherIcon = Icons.cloud;
                            break;
                          case 'rainy':
                            weatherIcon = Icons.water_drop;
                            break;
                          case 'snowy':
                            weatherIcon = Icons.ac_unit;
                            break;
                          default:
                            weatherIcon = Icons.cloud;
                        }

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(DateFormat('MMM d').format(DateTime.parse(weather.date))),
                                Icon(weatherIcon, size: 28),
                                Text('${weather.temperature}°C'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Required Documents Card
  Widget _buildDocumentsCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    final requiredDocument = details.requiredDocuments;

    // Document type icon
    IconData docIcon;
    switch (requiredDocument.documentType) {
      case RequiredDocumentType.passport:
        docIcon = Icons.book;
        break;
      case RequiredDocumentType.visa:
      case RequiredDocumentType.eVisa:
        docIcon = Icons.article;
        break;
      case RequiredDocumentType.idCard:
        docIcon = Icons.credit_card;
        break;
      default:
        docIcon = Icons.description;
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
                Icon(docIcon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text('Required Documents', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Document message
            Text(requiredDocument.message, style: Theme.of(context).textTheme.bodyMedium),

            // Document steps if available
            if (requiredDocument.steps != null && requiredDocument.steps!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Required Steps:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...requiredDocument.steps!.map((step) => _buildListItem(context, step)),
            ],

            // More information if available
            if (requiredDocument.moreInformation != null) ...[
              const SizedBox(height: 16),
              Text(requiredDocument.moreInformation!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  // Currency Information Card
  Widget _buildCurrencyCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    final currency = details.currency;

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
                Icon(Icons.currency_exchange, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text('Currency Information', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            _buildInfoRow(context, 'Currency', '${currency.name} (${currency.code})', Icons.money),

            if (currency.exchangeRate != null)
              _buildInfoRow(context, 'Exchange Rate', '1 Unit = ${currency.exchangeRate}', Icons.swap_horiz),

            _buildInfoRow(
              context,
              'Average Daily Cost',
              '${currency.arrivalAverageLivingCostPerDay}',
              Icons.price_change,
            ),
          ],
        ),
      ),
    );
  }

  // Tax Information Card
  Widget _buildTaxInfoCard(BuildContext context, TravelDetails details, AppLocalizations l10n) {
    final tax = details.taxInformation;

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
                Text('Tax Information', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            _buildInfoRow(
              context,
              'Tax Rate',
              NumberFormat.percentPattern(Localizations.localeOf(context).languageCode).format(tax.taxRate),
              Icons.percent,
            ),

            _buildInfoRow(
              context,
              'Tax-Free Shopping',
              tax.hasTaxFreeOptions ? 'Available' : 'Not Available',
              Icons.shopping_bag,
              iconColor: tax.hasTaxFreeOptions ? Colors.green : Colors.red,
            ),

            if (tax.taxRefundInformation != null) ...[
              const SizedBox(height: 8),
              Text(tax.taxRefundInformation!, style: Theme.of(context).textTheme.bodyMedium),
            ],
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
                Text('Places to Visit', style: Theme.of(context).textTheme.titleLarge),
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
                                      Text('Requirements:', style: Theme.of(context).textTheme.titleSmall),
                                      const SizedBox(height: 4),
                                      Text(spot.requirements!),
                                    ],
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
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
                Text('Travel Itinerary', style: Theme.of(context).textTheme.titleLarge),
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
                      dayPlan.events.map((event) {
                        return ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(event.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text(event.time), Text(event.location)],
                          ),
                          isThreeLine: true,
                        );
                      }).toList(),
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
