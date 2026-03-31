import 'package:flutter/material.dart';

import '../../../core/constants/town_feature_constants.dart';
import '../../../models/models.dart';

/// Hire rates + deposit for equipment-rentals business detail (matches public web logic).
class EquipmentHireRatesSection extends StatelessWidget {
  final BusinessDetailDto business;

  const EquipmentHireRatesSection({super.key, required this.business});

  static const Color _equipmentAccent = Color(TownFeatureConstants.equipmentRentalsColor);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final h = business.hourlyRate;
    final d = business.dailyRate;
    final hasHourly = h != null && h > 0;
    final hasDaily = d != null && d > 0;
    final showDeposit =
        business.isDepositRequired && business.depositAmount != null;

    if (!hasHourly && !hasDaily && !showDeposit) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _equipmentAccent.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 22,
              color: _equipmentAccent.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ask the business for current hire rates.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.35,
                  color: colorScheme.onSurface.withValues(alpha: 0.82),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasHourly)
          _HireRateTile(
            label: 'Hourly rate',
            value: 'R${h.toStringAsFixed(2)} / hour',
            icon: Icons.hourglass_top_rounded,
            tileBackground: colorScheme.primaryContainer.withValues(alpha: 0.42),
            iconBackground: colorScheme.primary.withValues(alpha: 0.16),
            iconColor: colorScheme.primary,
            borderColor: colorScheme.primary.withValues(alpha: 0.22),
          ),
        if (hasHourly && (hasDaily || showDeposit)) const SizedBox(height: 10),
        if (hasDaily)
          _HireRateTile(
            label: 'Daily rate',
            value: 'R${d.toStringAsFixed(2)} / day',
            icon: Icons.calendar_today_rounded,
            tileBackground: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            iconBackground: colorScheme.tertiary.withValues(alpha: 0.18),
            iconColor: colorScheme.tertiary,
            borderColor: colorScheme.tertiary.withValues(alpha: 0.24),
          ),
        if (hasDaily && showDeposit) const SizedBox(height: 10),
        if (showDeposit)
          _HireRateTile(
            label: 'Security deposit',
            value: 'R${business.depositAmount!.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet_outlined,
            tileBackground: _equipmentAccent.withValues(alpha: 0.14),
            iconBackground: _equipmentAccent.withValues(alpha: 0.22),
            iconColor: _equipmentAccent.withValues(alpha: 0.95),
            borderColor: _equipmentAccent.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}

class _HireRateTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tileBackground;
  final Color iconBackground;
  final Color iconColor;
  final Color borderColor;

  const _HireRateTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.tileBackground,
    required this.iconBackground,
    required this.iconColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: tileBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: colorScheme.onSurface.withValues(alpha: 0.94),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
