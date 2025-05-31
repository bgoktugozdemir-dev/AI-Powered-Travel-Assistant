import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_assistant/common/models/response/currency.dart';
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
    final departureCurrencyFormatter = NumberFormat.currency(symbol: currency.departureCurrencyCode, decimalDigits: 2);
    final departureCurrencyValue = NumberFormat.currency(
      symbol: currency.departureCurrencyCode,
      decimalDigits: 0,
    ).format(1);
    final arrivalCurrencyFormatter = NumberFormat.currency(symbol: currency.code, decimalDigits: 2);
    final exchangeRateValue = arrivalCurrencyFormatter.format(currencyExchangeRate);
    final arrivalAverageLivingCostPerDay = arrivalCurrencyFormatter.format(currency.arrivalAverageLivingCostPerDay);
    final arrivalAverageLivingCostPerDayInDepartureCurrency = departureCurrencyFormatter.format(
      currency.arrivalAverageLivingCostPerDay / currencyExchangeRate,
    );

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
                Text(l10n.currencyInformationTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            _buildInfoRow(context, l10n.currencyLabel, '${currency.name} (${currency.code})', Icons.money),

            _buildInfoRow(
              context,
              l10n.exchangeRateLabel,
              '$departureCurrencyValue = $exchangeRateValue',
              Icons.swap_horiz,
            ),

            _buildInfoRow(
              context,
              l10n.averageDailyCostLabel,
              '$arrivalAverageLivingCostPerDay ($arrivalAverageLivingCostPerDayInDepartureCurrency)',
              Icons.price_change,
            ),
          ],
        ),
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
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
