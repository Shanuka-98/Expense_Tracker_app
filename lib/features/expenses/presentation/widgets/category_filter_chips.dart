import 'package:flutter/material.dart';

import '../../models/expense_category.dart';

/// A horizontal scrollable row of filter chips, one per expense category.
///
/// [selectedCategory] is null when "All" is selected.
/// [onCategorySelected] passes null to clear the filter.
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              avatar: Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: selectedCategory == null
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: selectedCategory == null
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),

          // One chip per category
          ...ExpenseCategory.values.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.label),
                selected: isSelected,
                onSelected: (_) =>
                    onCategorySelected(isSelected ? null : category),
                avatar: Icon(
                  category.icon,
                  size: 16,
                  color: isSelected ? colorScheme.onPrimary : category.color,
                ),
                selectedColor: category.color,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
