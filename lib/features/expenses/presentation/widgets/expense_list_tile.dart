import 'package:flutter/material.dart';

import '../../../../core/formatting/currency_formatter.dart';
import '../../models/expense.dart';

/// A single expense row in the history list.
///
/// Shows category icon, title, formatted amount, date, and optional note.
/// Provides swipe-to-delete affordance via Dismissible in the parent.
class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  String get _formattedDate {
    final day = expense.day.toString().padLeft(2, '0');
    final month = expense.month.toString().padLeft(2, '0');
    return '$day/$month/${expense.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category icon bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: expense.category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                expense.category.icon,
                color: expense.category.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Title and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        expense.category.label,
                        style: textTheme.bodySmall?.copyWith(
                          color: expense.category.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '\u2022',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                      Text(
                        _formattedDate,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              CurrencyFormatter.formatMinorUnits(expense.amountInCents),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
