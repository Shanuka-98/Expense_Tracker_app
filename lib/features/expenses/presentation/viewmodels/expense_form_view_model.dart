import 'package:flutter/foundation.dart';

import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../data/expense_repository.dart';
import '../../../../core/formatting/currency_formatter.dart';

/// Manages form state and saving logic for adding/editing an expense.
///
/// We separate this from [ExpensesViewModel] because form state (like drafts,
/// validation errors, and save progress) is ephemeral and specific to the
/// form view. Keeping it here prevents polluting the global list state.
class ExpenseFormViewModel extends ChangeNotifier {
  ExpenseFormViewModel({
    required this.repository,
    required this.userId,
    this.initialExpense,
  }) {
    if (initialExpense != null) {
      _title = initialExpense!.title;
      _amountInCents = initialExpense!.amountInCents;
      _category = initialExpense!.category;
      _date = DateTime(
        initialExpense!.year,
        initialExpense!.month,
        initialExpense!.day,
      );
      _note = initialExpense!.note;
    } else {
      _date = DateTime.now();
    }
  }

  final ExpenseRepository repository;
  final String userId;

  /// The expense being edited, if any.
  final Expense? initialExpense;

  // ---------------------------------------------------------------------------
  // Form State
  // ---------------------------------------------------------------------------

  String _title = '';
  String get title => _title;
  void setTitle(String value) {
    _title = value.trim();
    notifyListeners();
  }

  int? _amountInCents;
  int? get amountInCents => _amountInCents;
  void setAmountFromDouble(double? value) {
    if (value == null) {
      _amountInCents = null;
    } else {
      _amountInCents = CurrencyFormatter.toMinorUnits(value);
    }
    notifyListeners();
  }

  ExpenseCategory? _category;
  ExpenseCategory? get category => _category;
  void setCategory(ExpenseCategory? value) {
    _category = value;
    notifyListeners();
  }

  late DateTime _date;
  DateTime get date => _date;
  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  String? _note;
  String? get note => _note;
  void setNote(String value) {
    final trimmed = value.trim();
    _note = trimmed.isEmpty ? null : trimmed;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Save State
  // ---------------------------------------------------------------------------

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _saveError;
  String? get saveError => _saveError;

  /// Validates and saves the expense to Firestore.
  ///
  /// Returns `true` if successful, `false` otherwise.
  Future<bool> save() async {
    if (_isSaving) return false;

    // Final validation before assembling the model
    if (_title.isEmpty || _title.length > 200) {
      _saveError = 'Invalid title length.';
      notifyListeners();
      return false;
    }
    if (_amountInCents == null ||
        _amountInCents! <= 0 ||
        _amountInCents! > 100000000) {
      _saveError = 'Invalid amount.';
      notifyListeners();
      return false;
    }
    if (_category == null) {
      _saveError = 'Please select a category.';
      notifyListeners();
      return false;
    }
    if (_note != null && _note!.length > 500) {
      _saveError = 'Note is too long (max 500 characters).';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _saveError = null;
    notifyListeners();

    try {
      final dateString =
          '${_date.year.toString().padLeft(4, '0')}-'
          '${_date.month.toString().padLeft(2, '0')}-'
          '${_date.day.toString().padLeft(2, '0')}';

      if (initialExpense == null) {
        // Create new
        final newExpense = Expense(
          id: '',
          title: _title,
          amountInCents: _amountInCents!,
          category: _category!,
          date: dateString,
          note: _note,
        );
        await repository.addExpense(userId, newExpense);
      } else {
        // Update existing
        final updatedExpense = initialExpense!.copyWith(
          title: _title,
          amountInCents: _amountInCents!,
          category: _category!,
          date: dateString,
          note: () => _note,
        );
        await repository.updateExpense(userId, updatedExpense);
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _saveError = 'Failed to save expense. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
