import 'package:flutter/material.dart';
import 'package:travel_assistant/common/ui/travel_card.dart';
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

    return TravelCard(
      icon: Icons.receipt_long,
      title: l10n.taxInformationTitle,
      children: [
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

        if (taxInformation.taxRefundInformation != null) ...[
          const SizedBox(height: 8),
          Text(
            taxInformation.taxRefundInformation!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
