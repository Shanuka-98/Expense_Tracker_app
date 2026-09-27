import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/expense_category.dart';

class CategorySummaryChart extends StatelessWidget {
  const CategorySummaryChart({
    super.key,
    required this.categoryTotalsInCents,
  });

  final Map<ExpenseCategory, int> categoryTotalsInCents;

  @override
  Widget build(BuildContext context) {
    if (categoryTotalsInCents.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final totalCents = categoryTotalsInCents.values.fold<int>(0, (a, b) => a + b);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spending Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 35,
                          sections: categoryTotalsInCents.entries.map((entry) {
                            final isLarge = entry.value > totalCents * 0.1;
                            return PieChartSectionData(
                              color: entry.key.color,
                              value: entry.value.toDouble(),
                              title: isLarge ? '${((entry.value / totalCents) * 100).toStringAsFixed(0)}%' : '',
                              radius: isLarge ? 40 : 35,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              borderSide: BorderSide(color: theme.colorScheme.surface, width: 2),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Legend
                    Expanded(
                      flex: 6,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryTotalsInCents.length,
                        itemBuilder: (context, index) {
                          final entry = categoryTotalsInCents.entries.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: entry.key.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        entry.key.label,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '\$${(entry.value / 100).toStringAsFixed(2)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
