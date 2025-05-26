import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_assistant/features/travel_form/bloc/travel_form_bloc.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

abstract class _Constants {
  static const padding = EdgeInsets.all(16);
  static const progressIndicatorHeight = 8.0;
  static const progressIndicatorBorderRadius = 100.0;
}

class TravelFormStepLayout extends StatelessWidget {
  const TravelFormStepLayout({required this.children, this.spacing = 0, this.showHeader = true, super.key});

  final List<Widget> children;
  final double spacing;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: _Constants.padding,
      child: Column(
        spacing: spacing,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            BlocBuilder<TravelFormBloc, TravelFormState>(
              buildWhen: (previous, current) => previous.currentStep != current.currentStep,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(getTitle(context, state.currentStep), style: textTheme.headlineMedium),
                    Text(getDescription(context, state.currentStep), style: textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: state.currentStep / state.totalSteps,
                      minHeight: _Constants.progressIndicatorHeight,
                      borderRadius: BorderRadius.circular(_Constants.progressIndicatorBorderRadius),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ...children,
        ],
      ),
    );
  }

  String getTitle(BuildContext context, int currentStep) {
    final l10n = AppLocalizations.of(context);

    return switch (currentStep) {
      0 => l10n.stepTitleWelcome,
      1 => l10n.stepTitleArrival,
      2 => l10n.stepTitleDates,
      3 => l10n.stepTitleNationality,
      4 => l10n.stepTitlePurpose,
      5 => l10n.stepTitleReview,
      _ => '',
    };
  }

  String getDescription(BuildContext context, int currentStep) {
    final l10n = AppLocalizations.of(context);

    return switch (currentStep) {
      0 => l10n.stepDescriptionDeparture,
      1 => l10n.stepDescriptionArrival,
      2 => l10n.stepDescriptionDates,
      3 => l10n.stepDescriptionNationality,
      4 => l10n.stepDescriptionPurpose,
      5 => l10n.stepDescriptionReview,
      _ => '',
    };
  }
}
