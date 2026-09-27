import 'package:flutter/material.dart';

import '../../../../core/formatting/currency_formatter.dart';

/// A prominent card showing the total expenses for the selected month.
///
/// Uses a gradient background derived from the app's primary color
/// to make the total stand out as the key metric on the home screen.
class MonthlyTotalCard extends StatelessWidget {
  const MonthlyTotalCard({
    super.key,
    required this.totalInCents,
    required this.expenseCount,
    required this.monthLabel,
    this.budgetCents = 500000, // Hardcoded budget of 5000 units (5000.00)
  });

  final int totalInCents;
  final int expenseCount;
  final String monthLabel;
  final int budgetCents;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.78),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Total Expenses',
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatMinorUnits(totalInCents),
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$expenseCount expense${expenseCount == 1 ? '' : 's'} in $monthLabel',
              style: TextStyle(
                color: colorScheme.onPrimary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Unique Feature: Budget Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ${CurrencyFormatter.formatMinorUnits(budgetCents)}',
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
              Text(
                '${(totalInCents / budgetCents * 100).clamp(0, 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (totalInCents / budgetCents).clamp(0.0, 1.0),
              backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                totalInCents > budgetCents ? Colors.redAccent : colorScheme.onPrimary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
