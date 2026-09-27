import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/theme/app_theme.dart';
import '../core/viewmodels/settings_view_model.dart';
import '../core/viewmodels/user_settings_view_model.dart';
import '../features/expenses/data/expense_repository.dart';
import '../features/expenses/presentation/viewmodels/expenses_view_model.dart';
import '../features/expenses/presentation/views/expenses_view.dart';
import 'auth_gate.dart';

/// Root widget for the Expense Tracker app.
///
/// Wraps the app in a [Provider] for the repository, and the expense UI
/// in [AuthGate] and [ChangeNotifierProvider] for the view model.
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ExpenseRepository>(create: (_) => ExpenseRepository()),
        ChangeNotifierProvider<SettingsViewModel>(create: (_) => SettingsViewModel(prefs)),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            home: const AuthGate(child: _ExpensesScope(child: ExpensesView())),
          );
        },
      ),
    );
  }
}

class _ExpensesScope extends StatelessWidget {
  const _ExpensesScope({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final uid = AuthGate.uidOf(context);
    final repository = context.read<ExpenseRepository>();

    final settings = context.read<SettingsViewModel>();
    return MultiProvider(
      key: ValueKey(uid),
      providers: [
        ChangeNotifierProvider<UserSettingsViewModel>(
          create: (_) => UserSettingsViewModel(
            userId: uid,
            firestore: FirebaseFirestore.instance,
            settingsViewModel: settings,
          ),
        ),
        ChangeNotifierProvider<ExpensesViewModel>(
          create: (_) => ExpensesViewModel(repository: repository, userId: uid),
        ),
      ],
      child: child,
    );
  }
}
