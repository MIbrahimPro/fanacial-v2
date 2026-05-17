import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/monthly_tracker_provider.dart';
import '../../../utils/app_theme.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonthlyTrackerProvider>();
    final fmt = NumberFormat('#,##0.00');
    final net = provider.monthlyNet;
    final netColor = net >= 0 ? Colors.green : AppTheme.outgoingRed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Metric(
              label: 'Income',
              amount: provider.monthlyIncome,
              color: AppTheme.incomeBlue,
              icon: Icons.arrow_upward,
              fmt: fmt,
            ),
            _VerticalDivider(),
            _Metric(
              label: 'Outgoing',
              amount: provider.monthlyOutgoing,
              color: AppTheme.outgoingRed,
              icon: Icons.arrow_downward,
              fmt: fmt,
            ),
            _VerticalDivider(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Net',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${fmt.format(net)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: netColor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final NumberFormat fmt;

  const _Metric({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '\$${fmt.format(amount)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: 30,
        child: VerticalDivider(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
