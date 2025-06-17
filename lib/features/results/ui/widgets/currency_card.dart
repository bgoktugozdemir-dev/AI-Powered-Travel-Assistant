import 'package:flutter/material.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
import 'package:travel_assistant/common/utils/helpers/formatters.dart';
import 'package:travel_assistant/common/models/response/currency.dart';
import 'package:travel_assistant/features/results/ui/widgets/info_row.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({
    required this.currency,
    required this.exchangeRate,
    super.key,
  });

  final Currency currency;
  final double? exchangeRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyExchangeRate = exchangeRate ?? currency.exchangeRate;

    // Use Formatters for consistent currency formatting
    final departureCurrencyValue = Formatters.currency(
      amount: 1,
      currencyCode: currency.departureCurrencyCode ?? currency.code,
      locale: l10n.localeName,
      decimalDigits: 0,
    );
    final exchangeRateValue = Formatters.currency(
      amount: currencyExchangeRate,
      currencyCode: currency.code,
      locale: l10n.localeName,
    );
    final arrivalAverageLivingCostPerDay = Formatters.currency(
      amount: currency.arrivalAverageLivingCostPerDay,
      currencyCode: currency.code,
      locale: l10n.localeName,
    );
    final arrivalAverageLivingCostPerDayInDepartureCurrency =
        Formatters.currency(
          amount:
              currency.arrivalAverageLivingCostPerDay / currencyExchangeRate,
          currencyCode: currency.departureCurrencyCode ?? currency.code,
          locale: l10n.localeName,
        );

    return TravelCard(
      icon: Icons.currency_exchange,
      title: l10n.currencyInformationTitle,
      children: [
        InfoRow(
          icon: Icons.money,
          label: l10n.currencyLabel,
          value: '${currency.name} (${currency.code})',
        ),

        InfoRow(
          icon: Icons.swap_horiz,
          label: l10n.exchangeRateLabel,
          value: '$departureCurrencyValue = $exchangeRateValue',
        ),

        InfoRow(
          icon: Icons.price_change,
          label: l10n.averageDailyCostLabel,
          value:
              '$arrivalAverageLivingCostPerDay ($arrivalAverageLivingCostPerDayInDepartureCurrency)',
        ),
      ],
    );
  }
}
