import 'package:flutter/material.dart';
import 'package:travel_assistant/common/utils/helpers/formatters.dart';
import 'package:travel_assistant/common/models/response/tax_information.dart';
import 'package:travel_assistant/features/results/ui/widgets/info_row.dart';
import 'package:travel_assistant/l10n/app_localizations.dart';

class TaxInfoCard extends StatelessWidget {
  const TaxInfoCard({
    required this.taxInformation,
    super.key,
  });

  final TaxInformation taxInformation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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

            InfoRow(
              icon: Icons.percent,
              label: l10n.taxRateLabel,
              value: Formatters.percentage(taxInformation.taxRate / 100, l10n.localeName),
            ),

            InfoRow(
              icon: Icons.shopping_bag,
              label: l10n.taxFreeShoppingLabel,
              value: taxInformation.hasTaxFreeOptions ? l10n.availableLabel : l10n.notAvailableLabel,
              iconColor: taxInformation.hasTaxFreeOptions ? Colors.green : Colors.red,
            ),

            if (taxInformation.refundableTaxRate > 0)
              InfoRow(
                icon: Icons.percent,
                label: l10n.refundableTaxRateLabel,
                value: Formatters.percentage(taxInformation.refundableTaxRate / 100, l10n.localeName),
                iconColor: Colors.green,
              ),

            const SizedBox(height: 8),
            Text(
              taxInformation.taxRefundInformation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
