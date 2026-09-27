import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../formatting/currency_formatter.dart';
import 'settings_view_model.dart';

/// Manages user-specific settings synced to Firestore.
class UserSettingsViewModel extends ChangeNotifier {
  UserSettingsViewModel({
    required this.userId,
    required this.firestore,
    required this.settingsViewModel,
  }) {
    _init();
  }

  final String userId;
  final FirebaseFirestore firestore;
  final SettingsViewModel settingsViewModel;

  int _budgetLimitCents = 500000; // Default $5000.00
  int get budgetLimitCents => _budgetLimitCents;

  String _currencySymbol = 'LKR';
  String get currencySymbol => _currencySymbol;

  DocumentReference<Map<String, dynamic>> get _docRef =>
      firestore.collection('users').doc(userId);

  void _init() {
    _docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data.containsKey('budgetLimitCents')) {
          _budgetLimitCents = data['budgetLimitCents'] as int;
        }
        if (data.containsKey('currencySymbol')) {
          _currencySymbol = data['currencySymbol'] as String;
          CurrencyFormatter.symbol = _currencySymbol;
        }
        if (data.containsKey('isDarkMode')) {
          final isDark = data['isDarkMode'] as bool;
          settingsViewModel.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
        }
      }
      notifyListeners();
    });
  }

  Future<void> setBudgetLimit(int cents) async {
    _budgetLimitCents = cents;
    notifyListeners();
    await _docRef.set({'budgetLimitCents': cents}, SetOptions(merge: true));
  }

  Future<void> setCurrencySymbol(String symbol) async {
    _currencySymbol = symbol;
    CurrencyFormatter.symbol = symbol;
    notifyListeners();
    await _docRef.set({'currencySymbol': symbol}, SetOptions(merge: true));
  }

  Future<void> setDarkMode(bool isDark) async {
    // We update local SharedPreferences through SettingsViewModel,
    // and Firebase through UserSettingsViewModel.
    await settingsViewModel.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    await _docRef.set({'isDarkMode': isDark}, SetOptions(merge: true));
  }
}
