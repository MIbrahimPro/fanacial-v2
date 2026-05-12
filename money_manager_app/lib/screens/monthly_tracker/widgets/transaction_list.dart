import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart';
import '../../../providers/monthly_tracker_provider.dart';
import 'transaction_list_item.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonthlyTrackerProvider>();
    final transactions = provider.transactions;
    final tags = provider.tags;

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          child: Text(
            'No transactions for this month.\nTap + to add one.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final tag = tags.cast<Tag?>().firstWhere(
              (t) => t?.id == tx.tagId,
              orElse: () => null,
            );
        final isExpanded = _expandedId == tx.id;

        return TransactionListItem(
          transaction: tx,
          tag: tag,
          isExpanded: isExpanded,
          onTap: () {
            setState(() {
              _expandedId = isExpanded ? null : tx.id;
            });
          },
          onLongPress: () {
            Navigator.pushNamed(context, '/transaction-detail', arguments: tx.id);
          },
          onEdit: () {
            Navigator.pushNamed(context, '/transaction-detail', arguments: tx.id);
          },
          onDelete: () => _confirmDelete(context, tx, provider),
        );
      },
    );
  }

  void _confirmDelete(
      BuildContext context, Transaction tx, MonthlyTrackerProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${tx.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(tx.id);
              Navigator.pop(ctx);
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
