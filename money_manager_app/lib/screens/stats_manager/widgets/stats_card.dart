import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/stat_entry.dart';
import '../../../providers/stats_provider.dart';
import '../../../widgets/empty_state.dart';

class StatsCard extends StatelessWidget {
  final String cardType;
  final String title;
  final Color accentColor;
  final VoidCallback onAdd;

  const StatsCard({
    super.key,
    required this.cardType,
    required this.title,
    required this.accentColor,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatsProvider>();
    final entries = provider.getEntries(cardType);
    final total = provider.getTotal(cardType);
    final fmt = NumberFormat('#,##0.00');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '\$${fmt.format(total)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: EmptyState(
                icon: Icons.playlist_add_outlined,
                title: 'No entries',
                subtitle: '',
              ),
            )
          else
            ...entries.map((e) => _EntryRow(entry: e, accentColor: accentColor)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          InkWell(
            onTap: onAdd,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 16, color: accentColor),
                  const SizedBox(width: 6),
                  Text(
                    'Add Entry',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final StatEntry entry;
  final Color accentColor;

  const _EntryRow({required this.entry, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return InkWell(
      onLongPress: () => _showOptions(context, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '\$${fmt.format(entry.amount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, StatEntry entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  AddStatModal.show(context, editEntry: entry);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
                title: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, entry);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, StatEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Delete "${entry.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<StatsProvider>().deleteEntry(entry.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddStatModal extends StatefulWidget {
  final String? initialCardType;
  final StatEntry? editEntry;

  const AddStatModal({super.key, this.initialCardType, this.editEntry});

  static Future<void> show(
    BuildContext context, {
    String? initialCardType,
    StatEntry? editEntry,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddStatModal(
          initialCardType: initialCardType,
          editEntry: editEntry,
        ),
      ),
    );
  }

  @override
  State<AddStatModal> createState() => _AddStatModalState();
}

class _AddStatModalState extends State<AddStatModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  bool _isLoading = false;

  bool get _isEditing => widget.editEntry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editEntry;
    _nameController = TextEditingController(text: e?.name ?? '');
    _amountController =
        TextEditingController(text: e != null ? e.amount.toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardType = widget.initialCardType ?? widget.editEntry?.cardType ?? 'assets';
    final cardTitle = _cardTitle(cardType);

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
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isEditing ? 'Edit Entry' : 'Add Entry — $cardTitle',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount *', prefixText: '\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final a = double.tryParse(v);
                if (a == null || a <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cardColor(cardType),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditing ? 'Save Changes' : 'Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final provider = context.read<StatsProvider>();
      final amount = double.parse(_amountController.text.trim());
      final name = _nameController.text.trim();
      final cardType = widget.initialCardType ?? widget.editEntry!.cardType;

      if (_isEditing) {
        await provider.updateEntry(
          widget.editEntry!.copyWith(name: name, amount: amount),
        );
      } else {
        await provider.addEntry(cardType: cardType, name: name, amount: amount);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Entry updated' : 'Entry added')),
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

  String _cardTitle(String type) {
    switch (type) {
      case 'assets': return 'Assets';
      case 'liabilities': return 'Liabilities';
      case 'income': return 'Income';
      case 'expenses': return 'Expenses';
      default: return type;
    }
  }

  Color _cardColor(String type) {
    switch (type) {
      case 'assets': return const Color(0xFFFFD700);
      case 'liabilities': return const Color(0xFFE74C3C);
      case 'income': return const Color(0xFF4A90D9);
      case 'expenses': return const Color(0xFFE74C3C);
      default: return Colors.grey;
    }
  }
}