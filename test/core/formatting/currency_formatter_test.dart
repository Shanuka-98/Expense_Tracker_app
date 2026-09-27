import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/core/formatting/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    group('format (major units)', () {
      test('formats zero', () {
        expect(CurrencyFormatter.format(0), 'LKR 0.00');
      });

      test('formats whole number', () {
        expect(CurrencyFormatter.format(1250), 'LKR 1,250.00');
      });

      test('formats decimal amount', () {
        expect(CurrencyFormatter.format(1250.50), 'LKR 1,250.50');
      });

      test('formats negative amount', () {
        expect(CurrencyFormatter.format(-500.75), '-LKR 500.75');
      });

      test('formats large amount with multiple separators', () {
        expect(CurrencyFormatter.format(1234567.89), 'LKR 1,234,567.89');
      });

      test('formats amount under 1', () {
        expect(CurrencyFormatter.format(0.99), 'LKR 0.99');
      });

      test('rounds to two decimal places', () {
        expect(CurrencyFormatter.format(10.999), 'LKR 11.00');
      });
    });

    group('toMinorUnits', () {
      test('converts whole number', () {
        expect(CurrencyFormatter.toMinorUnits(12.0), 1200);
      });

      test('converts decimal amount', () {
        expect(CurrencyFormatter.toMinorUnits(12.50), 1250);
      });

      test('handles floating-point imprecision (12.10)', () {
        // 12.10 * 100 = 1209.9999... in IEEE 754; should round to 1210.
        expect(CurrencyFormatter.toMinorUnits(12.10), 1210);
      });

      test('converts zero', () {
        expect(CurrencyFormatter.toMinorUnits(0), 0);
      });

      test('converts large amount', () {
        expect(CurrencyFormatter.toMinorUnits(999999.99), 99999999);
      });
    });

    group('toMajorUnits', () {
      test('converts cents to major units', () {
        expect(CurrencyFormatter.toMajorUnits(1250), 12.50);
      });

      test('converts zero', () {
        expect(CurrencyFormatter.toMajorUnits(0), 0.0);
      });

      test('converts single cent', () {
        expect(CurrencyFormatter.toMajorUnits(1), 0.01);
      });
    });

    group('formatMinorUnits', () {
      test('formats from integer cents', () {
        expect(CurrencyFormatter.formatMinorUnits(125050), 'LKR 1,250.50');
      });

      test('formats zero cents', () {
        expect(CurrencyFormatter.formatMinorUnits(0), 'LKR 0.00');
      });

      test('formats single cent', () {
        expect(CurrencyFormatter.formatMinorUnits(1), 'LKR 0.01');
      });
    });

    group('formatCompact', () {
      test('formats thousands', () {
        expect(CurrencyFormatter.formatCompact(5000), 'LKR 5.0K');
      });

      test('formats millions', () {
        expect(CurrencyFormatter.formatCompact(2500000), 'LKR 2.5M');
      });

      test('falls back to full format below 1000', () {
        expect(CurrencyFormatter.formatCompact(999), 'LKR 999.00');
      });
    });
  });
}
