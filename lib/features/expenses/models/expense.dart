import 'package:cloud_firestore/cloud_firestore.dart';

import 'expense_category.dart';

/// Represents a single expense entry.
///
/// ## Storage conventions
///
/// - **amountInCents**: Stored as an integer number of minor currency units
///   (e.g., 1250.50 LKR = 125050). This avoids floating-point rounding errors
///   that accumulate over many additions. Use [CurrencyFormatter] for display.
///
/// - **date**: Stored as a canonical `YYYY-MM-DD` string (e.g., "2026-09-27").
///   This avoids timezone-drift problems: a Firestore Timestamp is UTC-anchored,
///   so an expense entered as "Sep 27" in UTC+5:30 could read back as "Sep 26"
///   after naive UTC conversion. A date string is immune to this.
///
/// - **createdAt / updatedAt**: Firestore server timestamps. These track when
///   the document was actually written, not the user's chosen expense date.
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amountInCents,
    required this.category,
    required this.date,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  /// Firestore document ID. Empty string for unsaved expenses.
  final String id;

  /// User-provided title, e.g. "Lunch at Cafe".
  final String title;

  /// Amount in minor currency units (cents). Always non-negative.
  final int amountInCents;

  /// The expense category.
  final ExpenseCategory category;

  /// Calendar date as `YYYY-MM-DD`. Not a time-of-day value.
  final String date;

  /// Optional user note.
  final String? note;

  /// Server-set creation timestamp.
  final DateTime? createdAt;

  /// Server-set last-update timestamp.
  final DateTime? updatedAt;

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  /// Creates an [Expense] from a Firestore document snapshot.
  ///
  /// Thin wrapper around [fromMap]; see that method for validation details.
  static Expense? fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return fromMap(doc.id, doc.data());
  }

  /// Creates an [Expense] from a raw [data] map and a document [id].
  ///
  /// Returns null if [data] is null or if required fields are missing
  /// or have unexpected types, so callers can safely skip bad documents.
  ///
  /// This method is separated from [fromFirestore] so it can be unit-tested
  /// without constructing a real [DocumentSnapshot].
  static Expense? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    final title = data['title'];
    final amountInCents = data['amountInCents'];
    final categoryName = data['category'];
    final date = data['date'];

    // Validate required fields exist and have expected types.
    if (title is! String ||
        amountInCents is! int ||
        categoryName is! String ||
        date is! String) {
      return null;
    }

    // Resolve category enum by name, defaulting to "other".
    final category =
        ExpenseCategory.values.asNameMap()[categoryName] ??
        ExpenseCategory.other;

    return Expense(
      id: id,
      title: title,
      amountInCents: amountInCents,
      category: category,
      date: date,
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this expense to a Firestore-compatible map.
  ///
  /// When [isNew] is true, sets `createdAt` to the server timestamp.
  /// `updatedAt` is always set to the server timestamp.
  Map<String, dynamic> toFirestore({bool isNew = false}) {
    return {
      'title': title,
      'amountInCents': amountInCents,
      'category': category.name,
      'date': date,
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ---------------------------------------------------------------------------
  // Convenience
  // ---------------------------------------------------------------------------

  /// The year component of [date].
  int get year => int.parse(date.substring(0, 4));

  /// The month component of [date] (1-12).
  int get month => int.parse(date.substring(5, 7));

  /// The day component of [date] (1-31).
  int get day => int.parse(date.substring(8, 10));

  /// Creates a copy with the given fields replaced.
  Expense copyWith({
    String? id,
    String? title,
    int? amountInCents,
    ExpenseCategory? category,
    String? date,
    String? Function()? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amountInCents: amountInCents ?? this.amountInCents,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note != null ? note() : this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          amountInCents == other.amountInCents &&
          category == other.category &&
          date == other.date &&
          note == other.note;

  @override
  int get hashCode =>
      Object.hash(id, title, amountInCents, category, date, note);

  @override
  String toString() =>
      'Expense(id: $id, title: $title, amount: $amountInCents, '
      'category: ${category.name}, date: $date)';
}
