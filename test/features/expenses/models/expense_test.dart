import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/features/expenses/models/expense.dart';
import 'package:expense_tracker/features/expenses/models/expense_category.dart';

void main() {
  group('Expense', () {
    group('toFirestore', () {
      test('produces correct map for new expense', () {
        final expense = Expense(
          id: '',
          title: 'Lunch',
          amountInCents: 85000,
          category: ExpenseCategory.food,
          date: '2026-09-27',
          note: 'With colleagues',
        );

        final map = expense.toFirestore(isNew: true);

        expect(map['title'], 'Lunch');
        expect(map['amountInCents'], 85000);
        expect(map['category'], 'food');
        expect(map['date'], '2026-09-27');
        expect(map['note'], 'With colleagues');
        // Server timestamps are FieldValue sentinels, not null.
        expect(map.containsKey('createdAt'), isTrue);
        expect(map.containsKey('updatedAt'), isTrue);
      });

      test('omits createdAt on update', () {
        final expense = Expense(
          id: 'abc123',
          title: 'Bus fare',
          amountInCents: 6000,
          category: ExpenseCategory.transport,
          date: '2026-09-27',
        );

        final map = expense.toFirestore(isNew: false);

        expect(map.containsKey('createdAt'), isFalse);
        expect(map.containsKey('updatedAt'), isTrue);
      });

      test('includes null note when note is null', () {
        final expense = Expense(
          id: '',
          title: 'Coffee',
          amountInCents: 35000,
          category: ExpenseCategory.food,
          date: '2026-09-27',
        );

        final map = expense.toFirestore(isNew: true);
        expect(map['note'], isNull);
      });
    });

    group('date parsing', () {
      test('year getter extracts correctly', () {
        const expense = Expense(
          id: '',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.other,
          date: '2026-09-27',
        );

        expect(expense.year, 2026);
      });

      test('month getter extracts correctly', () {
        const expense = Expense(
          id: '',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.other,
          date: '2026-01-05',
        );

        expect(expense.month, 1);
      });

      test('day getter extracts correctly', () {
        const expense = Expense(
          id: '',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.other,
          date: '2026-12-31',
        );

        expect(expense.day, 31);
      });
    });

    group('fromMap', () {
      test('returns null for null data', () {
        expect(Expense.fromMap('test', null), isNull);
      });

      test('returns null for missing required fields', () {
        final result = Expense.fromMap('test', {'title': 'Coffee'});
        expect(result, isNull);
      });

      test('returns null for wrong field types', () {
        final result = Expense.fromMap('test', {
          'title': 'Coffee',
          'amountInCents': 12.5, // Should be int, not double
          'category': 'food',
          'date': '2026-09-27',
        });

        expect(result, isNull);
      });

      test('defaults unknown category to other', () {
        final expense = Expense.fromMap('test', {
          'title': 'Mystery',
          'amountInCents': 1000,
          'category': 'nonexistent_category',
          'date': '2026-09-27',
        });

        expect(expense, isNotNull);
        expect(expense!.category, ExpenseCategory.other);
      });

      test('parses complete document', () {
        final now = Timestamp.now();
        final expense = Expense.fromMap('doc123', {
          'title': 'Groceries',
          'amountInCents': 450000,
          'category': 'shopping',
          'date': '2026-09-27',
          'note': 'Weekly shopping',
          'createdAt': now,
          'updatedAt': now,
        });

        expect(expense, isNotNull);
        expect(expense!.id, 'doc123');
        expect(expense.title, 'Groceries');
        expect(expense.amountInCents, 450000);
        expect(expense.category, ExpenseCategory.shopping);
        expect(expense.date, '2026-09-27');
        expect(expense.note, 'Weekly shopping');
        expect(expense.createdAt, isNotNull);
        expect(expense.updatedAt, isNotNull);
      });

      test('handles null note', () {
        final expense = Expense.fromMap('test', {
          'title': 'Bus',
          'amountInCents': 6000,
          'category': 'transport',
          'date': '2026-09-27',
        });

        expect(expense, isNotNull);
        expect(expense!.note, isNull);
      });

      test('parses all category names correctly', () {
        for (final cat in ExpenseCategory.values) {
          final expense = Expense.fromMap('id', {
            'title': 'Test',
            'amountInCents': 100,
            'category': cat.name,
            'date': '2026-01-01',
          });

          expect(expense, isNotNull, reason: 'Failed for ${cat.name}');
          expect(expense!.category, cat, reason: 'Wrong for ${cat.name}');
        }
      });
    });

    group('copyWith', () {
      test('copies with changed fields', () {
        const original = Expense(
          id: 'a',
          title: 'Lunch',
          amountInCents: 85000,
          category: ExpenseCategory.food,
          date: '2026-09-27',
          note: 'Old note',
        );

        final modified = original.copyWith(
          title: 'Dinner',
          amountInCents: 120000,
          note: () => 'New note',
        );

        expect(modified.id, 'a');
        expect(modified.title, 'Dinner');
        expect(modified.amountInCents, 120000);
        expect(modified.category, ExpenseCategory.food);
        expect(modified.date, '2026-09-27');
        expect(modified.note, 'New note');
      });

      test('can set note to null via copyWith', () {
        const original = Expense(
          id: 'a',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.other,
          date: '2026-09-27',
          note: 'Has a note',
        );

        final modified = original.copyWith(note: () => null);
        expect(modified.note, isNull);
      });

      test('preserves all fields when no changes specified', () {
        const original = Expense(
          id: 'a',
          title: 'Lunch',
          amountInCents: 85000,
          category: ExpenseCategory.food,
          date: '2026-09-27',
          note: 'A note',
        );

        final copy = original.copyWith();
        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('equal expenses are equal', () {
        const a = Expense(
          id: 'x',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.food,
          date: '2026-09-27',
        );

        const b = Expense(
          id: 'x',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.food,
          date: '2026-09-27',
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different expenses are not equal', () {
        const a = Expense(
          id: 'x',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.food,
          date: '2026-09-27',
        );

        const b = Expense(
          id: 'y',
          title: 'Test',
          amountInCents: 100,
          category: ExpenseCategory.food,
          date: '2026-09-27',
        );

        expect(a, isNot(equals(b)));
      });
    });
  });
}
