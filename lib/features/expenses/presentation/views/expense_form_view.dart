import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../viewmodels/expense_form_view_model.dart';
import '../../data/expense_repository.dart';
import '../../../../app/auth_gate.dart';

/// A sheet or page to add or edit an expense.
class ExpenseFormView extends StatelessWidget {
  const ExpenseFormView({super.key, this.expense});

  final Expense? expense;

  static Future<void> show(BuildContext context, {Expense? expense}) {
    final uid = AuthGate.uidOf(context);
    final repository = context.read<ExpenseRepository>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => ExpenseFormViewModel(
            repository: repository,
            userId: uid,
            initialExpense: expense,
          ),
          child: ExpenseFormView(expense: expense),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseFormViewModel>();
    final isEditing = expense != null;
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (viewModel.isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (viewModel.saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    viewModel.saveError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              TextFormField(
                initialValue: viewModel.title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'What did you buy?',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.setTitle,
                enabled: !viewModel.isSaving,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: viewModel.amountInCents != null
                    ? (viewModel.amountInCents! / 100).toStringAsFixed(2)
                    : '',
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  prefixText: 'LKR ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (val) {
                  final doubleVal = double.tryParse(val);
                  viewModel.setAmountFromDouble(doubleVal);
                },
                enabled: !viewModel.isSaving,
              ),
              const SizedBox(height: 16),
              // ignore: deprecated_member_use
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: viewModel.category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                items: ExpenseCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(cat.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: viewModel.isSaving ? null : viewModel.setCategory,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: '${viewModel.date.year}-${viewModel.date.month.toString().padLeft(2, '0')}-${viewModel.date.day.toString().padLeft(2, '0')}',
                ),
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                onTap: viewModel.isSaving
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: viewModel.date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          viewModel.setDate(picked);
                        }
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: viewModel.note,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'Add extra details...',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.setNote,
                enabled: !viewModel.isSaving,
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 32),
              
              // Save Button
              FilledButton(
                onPressed: viewModel.isSaving
                    ? null
                    : () async {
                        final success = await viewModel.save();
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Expense updated' : 'Expense added'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              // Delete Button (if editing)
              if (isEditing) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: viewModel.isSaving
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Expense?'),
                              content: const Text('Are you sure you want to delete this expense?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            final uid = viewModel.userId;
                            context.read<ExpenseRepository>().deleteExpense(uid, expense!.id);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Expense deleted'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete Expense'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
