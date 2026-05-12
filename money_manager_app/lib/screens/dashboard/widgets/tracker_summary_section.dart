import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/monthly_tracker_provider.dart';
import '../../../providers/navigation_provider.dart';

class TrackerSummarySection extends StatelessWidget {
  const TrackerSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final provider = context.watch<MonthlyTrackerProvider>();
    final fmt = NumberFormat('#,##0.00');
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Tracker', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => nav.goToTab(1),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniStat(label: 'Income', amount: provider.monthlyIncome, color: const Color(0xFF4A90D9), fmt: fmt),
                const SizedBox(width: 16),
                _MiniStat(label: 'Outgoing', amount: provider.monthlyOutgoing, color: const Color(0xFFE74C3C), fmt: fmt),
              ],
            ),
            const SizedBox(height: 6),
            _NetRow(label: 'Net', amount: provider.monthlyNet, fmt: fmt),
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

class _NetRow extends StatelessWidget {
  final String label;
  final double amount;
  final NumberFormat fmt;

  const _NetRow({required this.label, required this.amount, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final color = amount >= 0 ? Colors.green : const Color(0xFFE74C3C);
    return Row(
      children: [
        Text('$label:  ', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        Text('\$${fmt.format(amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13,
            fontFeatures: const [FontFeature.tabularFigures()])),
      ],
    );
  }
}
