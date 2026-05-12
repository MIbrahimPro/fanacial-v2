import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/navigation_provider.dart';
import '../../../providers/stats_provider.dart';

class StatsSummarySection extends StatelessWidget {
  const StatsSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final provider = context.watch<StatsProvider>();
    final fmt = NumberFormat('#,##0');
    final net = provider.getNetTotal();
    final netColor = net >= 0 ? Colors.green : const Color(0xFFE74C3C);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                Text('Stats', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => nav.goToTab(2),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MiniStat(label: 'Assets', amount: provider.getTotal('assets'), color: const Color(0xFFFFD700), fmt: fmt),
                const SizedBox(width: 8),
                _MiniStat(label: 'Liab.', amount: provider.getTotal('liabilities'), color: const Color(0xFFE74C3C), fmt: fmt),
                const SizedBox(width: 8),
                _MiniStat(label: 'Income', amount: provider.getTotal('income'), color: const Color(0xFF4A90D9), fmt: fmt),
                const SizedBox(width: 8),
                _MiniStat(label: 'Exp.', amount: provider.getTotal('expenses'), color: const Color(0xFFE74C3C), fmt: fmt),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Net: \$${fmt.format(net)}',
              style: TextStyle(color: netColor, fontWeight: FontWeight.w600, fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()]),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 2),
            Text('\$${fmt.format(amount)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      ),
    );
  }
}
