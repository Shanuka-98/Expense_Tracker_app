/// Centralized currency formatting for the app.
///
/// All currency display and storage conversion goes through this class
/// so changing the display currency is a single-point edit.
///
/// ## Storage convention
///
/// Amounts are stored as **integer minor units** (cents) to avoid
/// floating-point rounding errors. For example, 1250.50 LKR is
/// stored as `125050`. The methods [toMinorUnits], [toMajorUnits],
/// and [formatMinorUnits] handle conversion.
class CurrencyFormatter {
  CurrencyFormatter._();

  static String symbol = 'LKR';
  static const int decimalDigits = 2;
  static const String _thousandsSeparator = ',';
  static const String _decimalSeparator = '.';

  /// The multiplier between major and minor units (e.g., 100 for 2 decimals).
  static final int _minorUnitMultiplier = _pow10(decimalDigits);

  // ---------------------------------------------------------------------------
  // Display formatting
  // ---------------------------------------------------------------------------

  /// Formats a **major-unit** [amount] (e.g., 1250.50) as "LKR 1,250.50".
  static String format(double amount) {
    return _formatRaw(amount);
  }

  /// Formats an **integer minor-unit** [amountInCents] (e.g., 125050) as
  /// "LKR 1,250.50".
  static String formatMinorUnits(int amountInCents) {
    return _formatRaw(toMajorUnits(amountInCents));
  }

  /// Short format for compact displays, e.g. "LKR 1.2K".
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '$symbol ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  // ---------------------------------------------------------------------------
  // Conversion between major and minor units
  // ---------------------------------------------------------------------------

  /// Converts a major-unit [amount] (e.g., 1250.50) to minor units (125050).
  ///
  /// Rounds to the nearest integer to handle floating-point imprecision
  /// (e.g., 12.10 * 100 = 1209.9999... should become 1210).
  static int toMinorUnits(double amount) {
    return (amount * _minorUnitMultiplier).round();
  }

  /// Converts minor units (e.g., 125050) to a major-unit double (1250.50).
  static double toMajorUnits(int amountInCents) {
    return amountInCents / _minorUnitMultiplier;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static String _formatRaw(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(decimalDigits).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    // Insert thousands separators from the right.
    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      final posFromEnd = integerPart.length - i;
      if (i > 0 && posFromEnd % 3 == 0) {
        buffer.write(_thousandsSeparator);
      }
      buffer.write(integerPart[i]);
    }

    final formatted = '$symbol $buffer$_decimalSeparator$decimalPart';
    return isNegative ? '-$formatted' : formatted;
  }

  /// Returns 10^[n] as an integer.
  static int _pow10(int n) {
    var result = 1;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }
}
