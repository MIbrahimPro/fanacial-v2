import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/stats_provider.dart';
import 'stats_manager/widgets/stats_card.dart'; // Also exports AddStatModal

class StatsManagerScreen extends StatelessWidget {
  const StatsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatsProvider>();
    final net = provider.getNetTotal();
    final fmt = NumberFormat('#,##0.00');
    final netColor = net >= 0 ? Colors.green : const Color(0xFFE74C3C);

    final assets = provider.getTotal('assets');
    final liabilities = provider.getTotal('liabilities');
    final income = provider.getTotal('income');
    final expenses = provider.getTotal('expenses');
    final positive = assets + income;
    final negative = liabilities + expenses;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _NetTotalCard(net: net, fmt: fmt, netColor: netColor),
            const SizedBox(height: 8),
            _StatsComparisonBar(positive: positive, negative: negative),
            const SizedBox(height: 12),
            _buildCard(context, 'assets', 'Assets', const Color(0xFFFFD700)),
            _buildCard(context, 'liabilities', 'Liabilities', const Color(0xFFE74C3C)),
            _buildCard(context, 'income', 'Income', const Color(0xFF4A90D9)),
            _buildCard(context, 'expenses', 'Expenses', const Color(0xFFE74C3C)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String type, String title, Color color) {
    return StatsCard(
      cardType: type,
      title: title,
      accentColor: color,
      onAdd: () => AddStatModal.show(context, initialCardType: type),
    );
  }
}

class _NetTotalCard extends StatelessWidget {
  final double net;
  final NumberFormat fmt;
  final Color netColor;

  const _NetTotalCard({required this.net, required this.fmt, required this.netColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Net Total',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '\$${fmt.format(net)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: netColor,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsComparisonBar extends StatelessWidget {
  final double positive;
  final double negative;

  const _StatsComparisonBar({required this.positive, required this.negative});

  @override
  Widget build(BuildContext context) {
    final total = positive + negative;
    final posRatio = total == 0 ? 0.5 : positive / total;
    final negRatio = total == 0 ? 0.5 : negative / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Health Bar', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(
                '${(posRatio * 100).toStringAsFixed(0)}% Pos / ${(negRatio * 100).toStringAsFixed(0)}% Neg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: (posRatio * 1000).toInt(),
                    child: Container(color: Colors.green.shade400),
                  ),
                  Expanded(
                    flex: (negRatio * 1000).toInt(),
                    child: Container(color: const Color(0xFFE74C3C).withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _LegendItem(label: 'Assets+Income', color: Colors.green.shade400),
              const SizedBox(width: 12),
              _LegendItem(label: 'Liabilities+Expenses', color: const Color(0xFFE74C3C)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
