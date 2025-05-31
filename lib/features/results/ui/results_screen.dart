import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/common/ui/disclaimer_card.dart';
import 'package:travel_assistant/common/models/response/travel_details.dart';
import 'package:travel_assistant/common/repositories/firebase_remote_config_repository.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';
import 'package:travel_assistant/features/results/ui/widgets/city_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/currency_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/flight_options_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/recommendations_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/travel_plan_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/required_documents_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/top_spots_card.dart';
import 'package:travel_assistant/features/results/ui/widgets/tax_info_card.dart';
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
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Implement share functionality for mobile platforms
                  // TODO: Implement download functionality for other platforms
                },
                icon: const Icon(Icons.share),
              ),
            ],
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
                    if (firebaseRemoteConfigRepository.showCityCard)
                      CityCard(
                        city: travelDetails.city,
                        cityImageInBytes: state.cityImageInBytes,
                      ),

                    // Required Documents Card
                    if (firebaseRemoteConfigRepository.showRequiredDocumentsCard)
                      RequiredDocumentsCard(
                        requiredDocument: travelDetails.requiredDocuments,
                      ),

                    // Currency Information Card
                    if (firebaseRemoteConfigRepository.showCurrencyCard)
                      CurrencyCard(
                        currency: travelDetails.currency,
                        exchangeRate: state.exchangeRate,
                      ),

                    // Flight Options Card
                    if (firebaseRemoteConfigRepository.showFlightOptionsCard)
                      FlightOptionsCard(
                        flightOptions: travelDetails.flightOptions,
                      ),

                    // Tax Information Card
                    if (firebaseRemoteConfigRepository.showTaxInfoCard)
                      TaxInfoCard(
                        taxInformation: travelDetails.taxInformation,
                      ),

                    // Top Spots Card
                    if (firebaseRemoteConfigRepository.showTopSpotsCard)
                      TopSpotsCard(
                        spots: travelDetails.spots,
                      ),

                    // Travel Plan Card
                    if (firebaseRemoteConfigRepository.showTravelPlanCard && travelDetails.travelPlan.isNotEmpty)
                      TravelPlanCard(
                        travelPlan: travelDetails.travelPlan,
                      ),

                    // Recommendations Card
                    if (firebaseRemoteConfigRepository.showRecommendationsCard)
                      RecommendationsCard(
                        recommendations: travelDetails.recommendations,
                      ),

                    DisclaimerCard(
                      title: l10n.disclaimerAIMistakesTitle,
                      content: l10n.disclaimerAIMistakesContent,
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orangeAccent,
                    ),

                    DisclaimerCard(
                      title: l10n.disclaimerLegalTitle,
                      content: l10n.disclaimerLegalContent,
                      icon: Icons.gavel_rounded,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
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
}
