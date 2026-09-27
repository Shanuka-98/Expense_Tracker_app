import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/models/expense.dart';
import 'package:expense_tracker/features/expenses/models/expense_category.dart';
import 'package:expense_tracker/features/expenses/presentation/viewmodels/expenses_view_model.dart';

class FakeExpenseRepository extends ExpenseRepository {
  final _controller = StreamController<List<Expense>>.broadcast();

  void emit(List<Expense> expenses) {
    _controller.add(expenses);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  @override
  Stream<List<Expense>> watchExpenses(String userId) {
    return _controller.stream;
  }

  @override
  Future<String> addExpense(String userId, Expense expense) async => 'fake_id';

  @override
  Future<void> updateExpense(String userId, Expense expense) async {}

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {}
}

void main() {
  group('ExpensesViewModel', () {
    late FakeExpenseRepository repository;
    late ExpensesViewModel viewModel;

    setUp(() {
      repository = FakeExpenseRepository();
      viewModel = ExpensesViewModel(repository: repository, userId: 'test_uid');
    });

    test('initial state is loading', () {
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.error, isNull);
    });

    test('updates state when stream emits expenses', () async {
      final expenses = [
        Expense(
          id: '1',
          title: 'Food',
          amountInCents: 1000,
          category: ExpenseCategory.food,
          date: '2023-12-15',
        ),
      ];

      repository.emit(expenses);
      await Future.microtask(() {}); // Let stream process

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      // It won't show in visibleExpenses if the month doesn't match, 
      // but it's in the private list. We need to set the month to match.
      viewModel.setMonth(DateTime(2023, 12));
      expect(viewModel.visibleExpenses.length, 1);
    });

    test('handles stream error gracefully', () async {
      repository.emitError(Exception('Firebase error'));
      await Future.microtask(() {});

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNotNull);
    });

    test('monthly total calculates correctly across boundary dates and categories', () async {
      final expenses = [
        Expense(id: '1', title: 'A', amountInCents: 500, category: ExpenseCategory.food, date: '2023-12-01'),
        Expense(id: '2', title: 'B', amountInCents: 1500, category: ExpenseCategory.transport, date: '2023-12-31'),
        Expense(id: '3', title: 'C', amountInCents: 1000, category: ExpenseCategory.shopping, date: '2024-01-01'), // Next year/month
      ];
      repository.emit(expenses);
      await Future.microtask(() {});

      viewModel.setMonth(DateTime(2023, 12));
      expect(viewModel.monthlyTotalInCents, 2000); // 500 + 1500

      viewModel.setMonth(DateTime(2024, 1));
      expect(viewModel.monthlyTotalInCents, 1000); // Only C
    });

    test('filters do not affect monthly total', () async {
      final expenses = [
        Expense(id: '1', title: 'A', amountInCents: 500, category: ExpenseCategory.food, date: '2023-12-15'),
        Expense(id: '2', title: 'B', amountInCents: 1500, category: ExpenseCategory.transport, date: '2023-12-16'),
      ];
      repository.emit(expenses);
      await Future.microtask(() {});

      viewModel.setMonth(DateTime(2023, 12));
      expect(viewModel.monthlyTotalInCents, 2000);
      expect(viewModel.visibleExpenses.length, 2);

      viewModel.toggleCategoryFilter(ExpenseCategory.food);
      expect(viewModel.visibleExpenses.length, 1);
      expect(viewModel.monthlyTotalInCents, 2000); // Unchanged!
    });
  });
}
