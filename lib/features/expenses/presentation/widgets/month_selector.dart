import 'package:flutter/material.dart';

/// A horizontal month navigator that lets users swipe between months.
///
/// Displays the month/year label with left/right arrows.
/// [selectedMonth] is the currently displayed month (day is ignored).
/// [onMonthChanged] fires whenever the user taps an arrow.
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get _label {
    final month = _monthNames[selectedMonth.month - 1];
    final year = selectedMonth.year;
    return '$month $year';
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.year == now.year && selectedMonth.month == now.month;
  }

  void _goToPrevious() {
    final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
    onMonthChanged(prev);
  }

  void _goToNext() {
    if (_isCurrentMonth) return;
    final next = DateTime(selectedMonth.year, selectedMonth.month + 1);
    onMonthChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _goToPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHigh,
              foregroundColor: colorScheme.onSurface,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _label,
              key: ValueKey<String>(_label),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _isCurrentMonth ? null : _goToNext,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
            style: IconButton.styleFrom(
              backgroundColor: _isCurrentMonth
                  ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.4)
                  : colorScheme.surfaceContainerHigh,
              foregroundColor: _isCurrentMonth
                  ? colorScheme.onSurface.withValues(alpha: 0.3)
                  : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
