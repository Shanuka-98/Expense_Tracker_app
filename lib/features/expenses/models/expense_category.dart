import 'package:flutter/material.dart';

/// Categories available for classifying an expense.
///
/// Each variant carries its own display metadata (label, icon, color)
/// so the UI never needs to maintain a parallel mapping.
enum ExpenseCategory {
  food(label: 'Food', icon: Icons.restaurant_rounded, color: Color(0xFFE57373)),
  transport(
    label: 'Transport',
    icon: Icons.directions_bus_rounded,
    color: Color(0xFF4FC3F7),
  ),
  shopping(
    label: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFFBA68C8),
  ),
  entertainment(
    label: 'Entertainment',
    icon: Icons.movie_rounded,
    color: Color(0xFFFFB74D),
  ),
  bills(
    label: 'Bills',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFF4DB6AC),
  ),
  health(
    label: 'Health',
    icon: Icons.favorite_rounded,
    color: Color(0xFFEF5350),
  ),
  education(
    label: 'Education',
    icon: Icons.school_rounded,
    color: Color(0xFF7986CB),
  ),
  other(
    label: 'Other',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF90A4AE),
  );

  const ExpenseCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
