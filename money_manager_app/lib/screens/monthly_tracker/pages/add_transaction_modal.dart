import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart';
import '../../../providers/monthly_tracker_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../utils/app_theme.dart';

class AddTransactionModal extends StatefulWidget {
  final String? initialType;
  final Transaction? editTransaction;

  const AddTransactionModal({
    super.key,
    this.initialType,
    this.editTransaction,
  });

  static Future<String?> show(
    BuildContext context, {
    String? initialType,
    Transaction? editTransaction,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionModal(
          initialType: initialType,
          editTransaction: editTransaction,
        ),
      ),
    );
  }

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedTagId;
  bool _isLoading = false;

  bool get _isEditing => widget.editTransaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.editTransaction;
    _selectedType = widget.initialType ?? tx?.type ?? 'income';
    _nameController = TextEditingController(text: tx?.name ?? '');
    _amountController =
        TextEditingController(text: tx != null ? tx.amount.toString() : '');
    _descriptionController =
        TextEditingController(text: tx?.description ?? '');
    _selectedDate = tx?.date ?? DateTime.now();
    _selectedTagId = tx?.tagId ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isEditing ? 'Edit Transaction' : 'Add Transaction',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _TypeSelector(
              selectedType: _selectedType,
              onChanged: (t) => setState(() => _selectedType = t),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g. Salary, Groceries',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
                      prefixText: '\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final amount = double.tryParse(v);
                      if (amount == null || amount <= 0) {
                        return 'Must be > 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    date: _selectedDate,
                    onChanged: (d) => setState(() => _selectedDate = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add details...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            _TagSelector(
              selectedTagId: _selectedTagId,
              onChanged: (id) => setState(() => _selectedTagId = id),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.read<NavigationProvider>().goToTab(4);
              },
              icon: const Icon(Icons.tune, size: 16),
              label: const Text('Manage Tags'),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.incomeBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Save Changes' : 'Add ${_capitalize(_selectedType)}',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTagId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a tag')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<MonthlyTrackerProvider>();
      final amount = double.parse(_amountController.text.trim());
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      String? resultId;
      if (_isEditing) {
        await provider.updateTransaction(
          widget.editTransaction!.copyWith(
            type: _selectedType,
            name: name,
            description: description.isNotEmpty ? description : null,
            amount: amount,
            tagId: _selectedTagId,
            date: _selectedDate,
            syncStatus: 'pending',
          ),
        );
        resultId = widget.editTransaction!.id;
      } else {
        resultId = await provider.addTransaction(
          type: _selectedType,
          name: name,
          description: description.isNotEmpty ? description : null,
          amount: amount,
          tagId: _selectedTagId,
          date: _selectedDate,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Transaction updated' : 'Transaction added',
            ),
          ),
        );
        Navigator.pop(context, resultId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _TypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _TypeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: 'Income',
            icon: Icons.trending_up,
            isSelected: selectedType == 'income',
            selectedColor: AppTheme.incomeBlue,
            onTap: () => onChanged('income'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            label: 'Outgoing',
            icon: Icons.trending_down,
            isSelected: selectedType == 'outgoing',
            selectedColor: AppTheme.outgoingRed,
            onTap: () => onChanged('outgoing'),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? selectedColor : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('d MMM yyyy').format(date);
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          suffixIcon: Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(formatted, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _TagSelector extends StatelessWidget {
  final String selectedTagId;
  final ValueChanged<String> onChanged;

  const _TagSelector({
    required this.selectedTagId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<MonthlyTrackerProvider>().tags;

    return DropdownButtonFormField<String>(
      initialValue: selectedTagId.isEmpty && tags.isNotEmpty ? tags.first.id : (selectedTagId.isEmpty ? null : selectedTagId),
      decoration: const InputDecoration(
        labelText: 'Tag *',
      ),
      items: tags.map((tag) {
        return DropdownMenuItem(
          value: tag.id,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _parseColor(tag.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(tag.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      validator: (v) => v == null ? 'Select a tag' : null,
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return Color(int.parse(h, radix: 16));
  }
}
