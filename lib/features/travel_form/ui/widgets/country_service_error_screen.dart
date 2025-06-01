import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  static const double iconSize = 80.0;
  static const double spacing = 24.0;
  static const double buttonPadding = 16.0;
}

/// A widget that displays an error screen when the country service fails to initialize.
class CountryServiceErrorScreen extends StatelessWidget {
  /// Creates a [CountryServiceErrorScreen].
  const CountryServiceErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_Constants.spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: _Constants.iconSize,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: _Constants.spacing),
              Text(
                l10n.countryServiceErrorTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _Constants.spacing / 2),
              Text(
                l10n.countryServiceErrorMessage,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _Constants.spacing * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<TravelFormBloc>().add(const RetryCountryServiceEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.tryAgainButton),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(_Constants.buttonPadding),
                    textStyle: theme.textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 