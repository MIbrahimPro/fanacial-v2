import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/loan.dart';
import '../../../providers/loans_provider.dart';

class AddLoanModal extends StatefulWidget {
  final String personId;
  final Loan? editLoan;

  const AddLoanModal({
    super.key,
    required this.personId,
    this.editLoan,
  });

  static Future<void> show(
    BuildContext context, {
    required String personId,
    Loan? editLoan,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.92,
          ),
          child: AddLoanModal(personId: personId, editLoan: editLoan),
        ),
      ),
    );
  }

  @override
  State<AddLoanModal> createState() => _AddLoanModalState();
}

class _AddLoanModalState extends State<AddLoanModal> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  bool get _isEditing => widget.editLoan != null;

  @override
  void initState() {
    super.initState();
    final l = widget.editLoan;
    _selectedType = l?.type ?? 'given';
    _amountController =
        TextEditingController(text: l != null ? l.amount.toString() : '');
    _descriptionController = TextEditingController(text: l?.description ?? '');
    _selectedDate = l?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 12),
            Text(
              _isEditing ? 'Edit Loan' : 'Add Loan',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _TypeChip(
                  label: 'Give',
                  icon: Icons.arrow_upward,
                  isSelected: _selectedType == 'given',
                  color: const Color(0xFF4A90D9),
                  onTap: () => setState(() => _selectedType = 'given'),
                )),
                const SizedBox(width: 12),
                Expanded(child: _TypeChip(
                  label: 'Take',
                  icon: Icons.arrow_downward,
                  isSelected: _selectedType == 'taken',
                  color: const Color(0xFFE74C3C),
                  onTap: () => setState(() => _selectedType = 'taken'),
                )),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              scrollPadding: const EdgeInsets.only(bottom: 160),
              decoration: const InputDecoration(labelText: 'Amount *', prefixText: '\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final a = double.tryParse(v);
                if (a == null || a <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(
                  DateFormat('d MMM yyyy').format(_selectedDate),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              scrollPadding: const EdgeInsets.only(bottom: 160),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Reason for this loan...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == 'given'
                      ? const Color(0xFF4A90D9)
                      : const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Save Changes' : 'Add ${_selectedType == 'given' ? 'Give' : 'Take'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final provider = context.read<LoansProvider>();
      final amount = double.parse(_amountController.text.trim());
      final description = _descriptionController.text.trim();

      if (_isEditing) {
        await provider.updateLoan(
          widget.editLoan!.copyWith(
            type: _selectedType,
            amount: amount,
            description: description.isNotEmpty ? description : null,
            date: _selectedDate,
          ),
        );
      } else {
        await provider.addLoan(
          personId: widget.personId,
          amount: amount,
          type: _selectedType,
          description: description.isNotEmpty ? description : null,
          date: _selectedDate,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Loan updated' : 'Loan added')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
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
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
