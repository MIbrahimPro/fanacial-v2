import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/loans_provider.dart';
import '../../../providers/navigation_provider.dart';

class LoansSummarySection extends StatelessWidget {
  const LoansSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final provider = context.watch<LoansProvider>();
    final fmt = NumberFormat('#,##0.00');
    final net = provider.getNet();
    final netColor = net >= 0 ? Colors.green : const Color(0xFFE74C3C);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: const Color(0xFFE74C3C).withValues(alpha: 0.6), width: 4),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Loans', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => nav.goToTab(3),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniStat(label: 'Given', amount: provider.getTotalGiven(), color: const Color(0xFFFFD700), fmt: fmt),
                const SizedBox(width: 16),
                _MiniStat(label: 'Taken', amount: provider.getTotalTaken(), color: const Color(0xFFE74C3C), fmt: fmt),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Net: \$${fmt.format(net)}',
              style: TextStyle(color: netColor, fontWeight: FontWeight.w600, fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 8),
            Text(
              'People: ${provider.getPersons().length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final NumberFormat fmt;

  const _MiniStat({required this.label, required this.amount, required this.color, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const SizedBox(height: 2),
          Text('\$${fmt.format(amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
