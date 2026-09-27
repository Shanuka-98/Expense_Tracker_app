import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/viewmodels/user_settings_view_model.dart';
import '../../models/expense.dart';
import '../viewmodels/expenses_view_model.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/month_selector.dart';
import '../widgets/monthly_total_card.dart';
import '../widgets/category_summary_chart.dart';
import 'expense_form_view.dart';
import 'settings_view.dart';

/// The main home screen for the expense tracker.
///
/// Binds to [ExpensesViewModel] to display the current month's expenses,
/// the true monthly total, and allows filtering by category or date.
class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpensesViewModel>();
    final userSettings = context.watch<UserSettingsViewModel>();
    final theme = Theme.of(context);

    final selectedMonth = viewModel.selectedMonth;
    final monthLabel = _monthNames[selectedMonth.month - 1];

    final visibleExpenses = viewModel.visibleExpenses;
    // We intentionally display the overall monthly total, unaffected by filters
    final monthlyTotal = viewModel.monthlyTotalInCents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          // Filter button to pick a specific date
          IconButton(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              final picked = await showDatePicker(
                context: context,
                initialDate: viewModel.dateFilter ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                viewModel.setDateFilter(picked);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Filtered by date: ${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            icon: Icon(
              Icons.tune_rounded,
              color: viewModel.dateFilter != null
                  ? theme.colorScheme.primary
                  : null,
            ),
            tooltip: 'Filter by Date',
          ),
            IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                viewModel.clearFilters();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All filters cleared'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: 'Clear filters',
            ),
            IconButton(
              onPressed: () {
                final userSettings = context.read<UserSettingsViewModel>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: userSettings,
                      child: const SettingsView(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.settings_rounded),
              tooltip: 'Settings',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Month selector
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: MonthSelector(
                selectedMonth: selectedMonth,
                onMonthChanged: viewModel.setMonth,
              ),
            ),

            // Scrollable content area
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Total card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: MonthlyTotalCard(
                        totalInCents: monthlyTotal,
                        expenseCount: visibleExpenses.length,
                        monthLabel: monthLabel,
                        budgetCents: userSettings.budgetLimitCents,
                      ),
                    ),
                  ),

                  // Category Summary Chart
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CategorySummaryChart(
                        categoryTotalsInCents: viewModel.categoryTotalsInCents,
                      ),
                    ),
                  ),

                  // Section header + search + filter chips
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Text(
                            'Expenses',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: TextField(
                            onChanged: viewModel.setSearchQuery,
                            decoration: InputDecoration(
                              hintText: 'Search by title or note...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        CategoryFilterChips(
                          selectedCategory: viewModel.categoryFilter,
                          onCategorySelected: (cat) {
                            if (cat != null) {
                              viewModel.toggleCategoryFilter(cat);
                              final isActive = viewModel.categoryFilter == cat;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isActive ? 'Filtered by ${cat.label}' : 'Category filter cleared'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Expense list, Loading, or Empty state
                  _buildListContent(context, viewModel, visibleExpenses),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ExpenseFormView.show(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    ExpensesViewModel viewModel,
    List<Expense> expenses,
  ) {
    if (viewModel.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateWidget(
          title: 'Oops!',
          subtitle: viewModel.error!,
          icon: Icons.error_outline_rounded,
        ),
      );
    }

    if (expenses.isEmpty) {
      final isFiltering =
          viewModel.categoryFilter != null || viewModel.dateFilter != null;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateWidget(
          title: isFiltering ? 'No matching expenses' : 'No expenses yet',
          subtitle: isFiltering
              ? 'Try clearing your filters'
              : 'Tap + to add your first expense',
          icon: isFiltering
              ? Icons.search_off_rounded
              : Icons.receipt_long_rounded,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final expense = expenses[index];
        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(context).colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Icon(
              Icons.delete_rounded,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          confirmDismiss: (direction) => _confirmDelete(context, expense.title),
          onDismissed: (direction) {
            viewModel.deleteExpense(expense.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('${expense.title} deleted')));
          },
          child: Column(
            children: [
              ExpenseListTile(
                expense: expense,
                onTap: () => ExpenseFormView.show(context, expense: expense),
              ),
              if (index < expenses.length - 1) const Divider(indent: 74),
            ],
          ),
        );
      }, childCount: expenses.length),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text(
          'Are you sure you want to delete "$title"?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
