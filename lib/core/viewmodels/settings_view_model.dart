import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._prefs) {
    _loadSettings();
  }

  final SharedPreferences _prefs;

  static const _themeModeKey = 'themeMode';
  static const _budgetLimitKey = 'budgetLimitCents';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  int _budgetLimitCents = 500000; // Default $5000.00
  int get budgetLimitCents => _budgetLimitCents;

  void _loadSettings() {
    // Load theme
    final themeIndex = _prefs.getInt(_themeModeKey);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load budget
    final savedBudget = _prefs.getInt(_budgetLimitKey);
    if (savedBudget != null) {
      _budgetLimitCents = savedBudget;
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setBudgetLimit(int cents) async {
    _budgetLimitCents = cents;
    notifyListeners();
    await _prefs.setInt(_budgetLimitKey, cents);
  }
}
