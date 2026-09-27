import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/models/expense.dart';
import 'package:expense_tracker/features/expenses/models/expense_category.dart';
import 'package:expense_tracker/features/expenses/presentation/viewmodels/expense_form_view_model.dart';

class FakeExpenseRepository extends ExpenseRepository {
  bool addCalled = false;

  @override
  Stream<List<Expense>> watchExpenses(String userId) {
    return Stream.value([]);
  }

  @override
  Future<String> addExpense(String userId, Expense expense) async {
    addCalled = true;
    return 'fake_id';
  }

  @override
  Future<void> updateExpense(String userId, Expense expense) async {}

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {}
}

void main() {
  group('ExpenseFormViewModel', () {
    late FakeExpenseRepository repository;
    late ExpenseFormViewModel viewModel;

    setUp(() {
      repository = FakeExpenseRepository();
      viewModel = ExpenseFormViewModel(repository: repository, userId: 'test_uid');
    });

    test('save fails when title is empty', () async {
      viewModel.setTitle('   ');
      viewModel.setAmountFromDouble(10.50);
      viewModel.setCategory(ExpenseCategory.food);
      
      final result = await viewModel.save();
      
      expect(result, isFalse);
      expect(viewModel.saveError, contains('title length'));
      expect(repository.addCalled, isFalse);
    });

    test('save fails when amount is invalid', () async {
      viewModel.setTitle('Food');
      viewModel.setAmountFromDouble(0);
      viewModel.setCategory(ExpenseCategory.food);
      
      final result = await viewModel.save();
      
      expect(result, isFalse);
      expect(viewModel.saveError, contains('Invalid amount'));
      expect(repository.addCalled, isFalse);
    });

    test('save fails when category is missing', () async {
      viewModel.setTitle('Food');
      viewModel.setAmountFromDouble(10.50);
      
      final result = await viewModel.save();
      
      expect(result, isFalse);
      expect(viewModel.saveError, contains('select a category'));
      expect(repository.addCalled, isFalse);
    });

    test('save succeeds with valid data', () async {
      viewModel.setTitle('Valid Title');
      viewModel.setAmountFromDouble(15.99);
      viewModel.setCategory(ExpenseCategory.other);
      
      final result = await viewModel.save();
      
      expect(result, isTrue);
      expect(viewModel.saveError, isNull);
      expect(repository.addCalled, isTrue);
    });
  });
}
