import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../data/expense_repository.dart';

/// Manages the state for the main expenses view.
///
/// Responsibilities:
/// - Fetches and caches all expenses via [ExpenseRepository].
/// - Manages the currently selected month.
/// - Calculates the true monthly total based on all expenses in the selected month.
/// - Manages category and date filters, exposing a refined [visibleExpenses] list
///   that DOES NOT alter the monthly total.
/// - Handles loading and error states for the expense stream.
class ExpensesViewModel extends ChangeNotifier {
  ExpensesViewModel({
    required this.repository,
    required this.userId,
  }) {
    _init();
  }

  final ExpenseRepository repository;
  final String userId;
  StreamSubscription<List<Expense>>? _subscription;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// The complete list of expenses from Firestore.
  List<Expense> _allExpenses = [];

  /// The month currently being viewed. Defaults to the current month.
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime get selectedMonth => _selectedMonth;

  /// Active category filter, if any.
  ExpenseCategory? _categoryFilter;
  ExpenseCategory? get categoryFilter => _categoryFilter;

  /// Active date filter, if any.
  DateTime? _dateFilter;
  DateTime? get dateFilter => _dateFilter;

  /// Active search query, if any.
  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  // ---------------------------------------------------------------------------
  // Derived State
  // ---------------------------------------------------------------------------

  /// The total amount for all expenses in the [_selectedMonth], regardless of filters.
  int get monthlyTotalInCents {
    int total = 0;
    for (final expense in _allExpenses) {
      if (expense.year == _selectedMonth.year &&
          expense.month == _selectedMonth.month) {
        total += expense.amountInCents;
      }
    }
    return total;
  }

  /// The total amount for each category in the [_selectedMonth].
  Map<ExpenseCategory, int> get categoryTotalsInCents {
    final totals = <ExpenseCategory, int>{};
    for (final expense in _allExpenses) {
      if (expense.year == _selectedMonth.year &&
          expense.month == _selectedMonth.month) {
        totals[expense.category] = (totals[expense.category] ?? 0) + expense.amountInCents;
      }
    }
    return totals;
  }

  /// The expenses to display in the list.
  ///
  /// 1. Only includes expenses from the [_selectedMonth].
  /// 2. Applies the [_categoryFilter] if active.
  /// 3. Applies the [_dateFilter] if active.
  List<Expense> get visibleExpenses {
    return _allExpenses.where((expense) {
      // Must be in the selected month
      if (expense.year != _selectedMonth.year ||
          expense.month != _selectedMonth.month) {
        return false;
      }

      // Apply category filter
      if (_categoryFilter != null && expense.category != _categoryFilter) {
        return false;
      }

      // Apply date filter
      if (_dateFilter != null) {
        if (expense.year != _dateFilter!.year ||
            expense.month != _dateFilter!.month ||
            expense.day != _dateFilter!.day) {
          return false;
        }
      }

      // Apply search query
      if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
        final query = _searchQuery!.trim().toLowerCase();
        final matchesTitle = expense.title.toLowerCase().contains(query);
        final matchesNote = expense.note != null && expense.note!.toLowerCase().contains(query);
        if (!matchesTitle && !matchesNote) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _init() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription = repository
        .watchExpenses(userId)
        .listen(
          (expenses) {
            _allExpenses = expenses;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            _isLoading = false;
            _error = 'Failed to load expenses. Please try again.';
            notifyListeners();
          },
        );
  }

  /// Retries the subscription if it failed.
  void retry() {
    _subscription?.cancel();
    _init();
  }

  /// Changes the currently viewed month. Clears filters.
  void setMonth(DateTime newMonth) {
    _selectedMonth = DateTime(newMonth.year, newMonth.month);
    _categoryFilter = null;
    _dateFilter = null;
    notifyListeners();
  }

  /// Toggles a category filter. If the same category is passed, it clears the filter.
  void toggleCategoryFilter(ExpenseCategory category) {
    if (_categoryFilter == category) {
      _categoryFilter = null;
    } else {
      _categoryFilter = category;
    }
    notifyListeners();
  }

  /// Sets or clears a specific date filter.
  void setDateFilter(DateTime? date) {
    _dateFilter = date;
    notifyListeners();
  }

  /// Sets the search query for filtering.
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clears all active filters without changing the selected month.
  void clearFilters() {
    _categoryFilter = null;
    _dateFilter = null;
    _searchQuery = null;
    notifyListeners();
  }

  /// Deletes an expense.
  Future<void> deleteExpense(String expenseId) async {
    try {
      await repository.deleteExpense(userId, expenseId);
    } catch (e) {
      // In a more complex app, we might surface a specific error state for deletions,
      // but the stream will just not update if it fails. We could throw here for the UI to catch.
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
