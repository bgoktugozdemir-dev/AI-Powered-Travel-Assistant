import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/utils/logger.dart'; 
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Screen to display the generated travel plan results after form submission.
class ResultsScreen extends StatelessWidget {
  /// Creates a [ResultsScreen].
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocBuilder<TravelFormBloc, TravelFormState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            automaticallyImplyLeading: false, // Disable back button
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.yourTravelPlan,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildTravelInfoRow(
                            context, 
                            l10n.fromLabel,
                            '${state.selectedDepartureAirport?.name} (${state.selectedDepartureAirport?.iataCode})',
                            Icons.flight_takeoff,
                          ),
                          _buildTravelInfoRow(
                            context, 
                            l10n.toLabel,
                            '${state.selectedArrivalAirport?.name} (${state.selectedArrivalAirport?.iataCode})',
                            Icons.flight_land,
                          ),
                          _buildTravelInfoRow(
                            context, 
                            l10n.datesLabel,
                            _formatDateRange(state.selectedDateRange, context),
                            Icons.calendar_today,
                          ),
                          _buildTravelInfoRow(
                            context, 
                            l10n.nationalityLabel,
                            '${state.selectedNationality?.flagEmoji ?? ''} ${state.selectedNationality?.name}',
                            Icons.flag,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.travelPurposesLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: state.selectedTravelPurposes.map((purpose) {
                              return Chip(
                                label: Text(purpose.name),
                                avatar: Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: Colors.green,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.recommendationsTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildRecommendation(
                            context, 
                            'Based on your travel purposes, we recommend visiting: museums, restaurants, and parks.',
                            Icons.lightbulb,
                          ),
                          _buildRecommendation(
                            context, 
                            'Average weather for your travel dates: Sunny, 25°C',
                            Icons.wb_sunny,
                          ),
                          _buildRecommendation(
                            context, 
                            'Local currency: Euro (EUR)',
                            Icons.euro,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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

  Widget _buildTravelInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTimeRange? dateRange, BuildContext context) {
    if (dateRange == null) {
      return 'No dates selected';
    }
    
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final startDate = dateFormat.format(dateRange.start);
    final endDate = dateFormat.format(dateRange.end);
    return '$startDate - $endDate';
  }
} 