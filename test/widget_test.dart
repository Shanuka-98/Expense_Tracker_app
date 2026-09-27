import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker/features/expenses/presentation/views/expenses_view.dart';
import 'package:expense_tracker/features/expenses/presentation/viewmodels/expenses_view_model.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/models/expense.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

import 'package:expense_tracker/core/viewmodels/user_settings_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeExpenseRepository extends ExpenseRepository {
  @override
  Stream<List<Expense>> watchExpenses(String userId) {
    return Stream.value([]);
  }

  @override
  Future<String> addExpense(String userId, Expense expense) async => 'fake_id';

  @override
  Future<void> updateExpense(String userId, Expense expense) async {}

  @override
  Future<void> deleteExpense(String userId, String expenseId) async {}
}

class FakeUserSettingsViewModel extends ChangeNotifier implements UserSettingsViewModel {
  @override
  String get userId => 'test_uid';

  @override
  FirebaseFirestore get firestore => throw UnimplementedError();

  @override
  get settingsViewModel => throw UnimplementedError();

  @override
  int get budgetLimitCents => 500000;

  @override
  String get currencySymbol => 'LKR';

  @override
  Future<void> setBudgetLimit(int cents) async {}

  @override
  Future<void> setCurrencySymbol(String symbol) async {}

  @override
  Future<void> setDarkMode(bool isDark) async {}
}

void main() {
  testWidgets('App renders home screen with key elements', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeExpenseRepository();
    final viewModel = ExpensesViewModel(
      repository: fakeRepo,
      userId: 'test_uid',
    );
    final userSettings = FakeUserSettingsViewModel();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ExpenseRepository>.value(value: fakeRepo),
          ChangeNotifierProvider<ExpensesViewModel>.value(value: viewModel),
          ChangeNotifierProvider<UserSettingsViewModel>.value(value: userSettings),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ExpensesView()),
      ),
    );

    // Wait for the stream to emit the empty list
    await tester.pumpAndSettle();

    // AppBar title
    expect(find.text('Expense Tracker'), findsOneWidget);

    // Monthly total card shows the currency symbol
    expect(find.textContaining('LKR'), findsWidgets);

    // Empty state visible by default
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.text('Tap + to add your first expense'), findsOneWidget);

    // FAB is present
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Category filter "All" chip is present
    expect(find.text('All'), findsOneWidget);
  });
}
