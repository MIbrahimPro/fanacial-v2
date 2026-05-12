import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart';
import '../../../providers/monthly_tracker_provider.dart';
import '../../../services/storage_service.dart';
import '../../../utils/contrast_utils.dart';
import '../widgets/transaction_list_item.dart';
import 'add_transaction_modal.dart';

class TransactionDetailPage extends StatefulWidget {
  final String transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    final tx = context.watch<MonthlyTrackerProvider>().transactions
        .cast<Transaction?>().firstWhere(
          (t) => t?.id == widget.transactionId,
          orElse: () => null,
        );

    if (tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final tag = StorageService.instance.getAllTags()
        .cast<Tag?>().firstWhere(
          (t) => t?.id == tx.tagId,
          orElse: () => null,
        );
    final isIncome = tx.type == 'income';
    final amountColor = isIncome ? AppColors.incomeBlue : AppColors.outgoingRed;
    final fmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat('d MMM yyyy');
    final dateTimeFmt = DateFormat('d MMM yyyy, h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: 'Type', value: isIncome ? 'Income' : 'Outgoing',
                        valueColor: amountColor),
                    const Divider(height: 20),
                    _Row(label: 'Name', value: tx.name),
                    const Divider(height: 20),
                    _Row(
                      label: 'Amount',
                      value: '\$${fmt.format(tx.amount)}',
                      valueColor: amountColor,
                      valueWeight: FontWeight.w700,
                    ),
                    const Divider(height: 20),
                    _Row(label: 'Date', value: dateFmt.format(tx.date)),
                    if (tag != null) ...[
                      const Divider(height: 20),
                      _TagRow(tag: tag),
                    ],
                    if (tx.description != null &&
                        tx.description!.isNotEmpty) ...[
                      const Divider(height: 20),
                      _DescriptionRow(description: tx.description!),
                    ],
                    const Divider(height: 20),
                    _Row(
                      label: 'Created',
                      value: dateTimeFmt.format(tx.createdAt),
                      valueSize: 12,
                    ),
                    const SizedBox(height: 4),
                    _Row(
                      label: 'Updated',
                      value: dateTimeFmt.format(tx.updatedAt),
                      valueSize: 12,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _openEditModal(context, tx),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.incomeBlue,
                        side: const BorderSide(color: AppColors.incomeBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, tx),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.outgoingRed,
                        side: const BorderSide(color: AppColors.outgoingRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openEditModal(BuildContext context, Transaction tx) async {
    final result = await AddTransactionModal.show(
      context,
      editTransaction: tx,
    );
    if (result != null && mounted) {
      setState(() {});
    }
  }

  void _confirmDelete(BuildContext context, Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${tx.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MonthlyTrackerProvider>().deleteTransaction(tx.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueWeight;
  final double? valueSize;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight,
    this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: valueWeight ?? FontWeight.normal,
                  color: valueColor,
                  fontSize: valueSize,
                ),
          ),
        ),
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  final Tag tag;

  const _TagRow({required this.tag});

  @override
  Widget build(BuildContext context) {
    final bgColor = _parseColor(tag.color);
    final textColor = ContrastUtils.getTextColorForBackground(tag.color);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            'Tag',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag.name,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
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

class _DescriptionRow extends StatelessWidget {
  final String description;

  const _DescriptionRow({required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            'Description',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
          ),
        ),
      ],
    );
  }
}
