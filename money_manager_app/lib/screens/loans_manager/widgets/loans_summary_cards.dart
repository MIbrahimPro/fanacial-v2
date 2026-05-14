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
        final cards = [
          _Card(label: 'Given', amount: given, color: const Color(0xFFFFD700), fmt: fmt),
          _Card(label: 'Taken', amount: taken, color: const Color(0xFFE74C3C), fmt: fmt),
          _Card(label: 'Net', amount: net, color: netColor, fmt: fmt, isFullHeight: true),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(height: 4),
                      Expanded(child: cards[1]),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: cards[2],
                ),
              ],
            ),
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
  final bool isFullHeight;

  const _Card({
    required this.label,
    required this.amount,
    required this.color,
    required this.fmt,
    this.isFullHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        alignment: isFullHeight ? Alignment.centerLeft : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isFullHeight ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isFullHeight ? MainAxisAlignment.center : MainAxisAlignment.start,
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
                    fontSize: isFullHeight ? 24 : 18,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
