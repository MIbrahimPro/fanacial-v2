import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/loans_provider.dart';

class LoansSummaryCards extends StatelessWidget {
  const LoansSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoansProvider>();
    final fmt = NumberFormat('#,##0.00');
    final given = provider.getTotalGiven();
    final taken = provider.getTotalTaken();
    final net = provider.getNet();
    final netColor = net >= 0 ? Colors.green : const Color(0xFFE74C3C);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _Card(label: 'Given', amount: given, color: const Color(0xFFFFD700), fmt: fmt)),
                    const SizedBox(width: 8),
                    Expanded(child: _Card(label: 'Taken', amount: taken, color: const Color(0xFFE74C3C), fmt: fmt)),
                    const SizedBox(width: 8),
                    Expanded(child: _Card(label: 'Net', amount: net, color: netColor, fmt: fmt)),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _Card(label: 'Given', amount: given, color: const Color(0xFFFFD700), fmt: fmt)),
                        const SizedBox(width: 8),
                        Expanded(child: _Card(label: 'Taken', amount: taken, color: const Color(0xFFE74C3C), fmt: fmt)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _Card(label: 'Net', amount: net, color: netColor, fmt: fmt),
                  ],
                ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final NumberFormat fmt;

  const _Card({
    required this.label,
    required this.amount,
    required this.color,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${fmt.format(amount)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
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
