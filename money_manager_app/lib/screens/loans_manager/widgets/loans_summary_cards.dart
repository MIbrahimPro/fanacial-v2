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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          if (isMobile) {
            return Column(
              children: [
                _Card(
                  label: 'Net',
                  amount: net,
                  color: netColor,
                  fmt: fmt,
                  emphasized: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _Card(
                        label: 'Given',
                        amount: given,
                        color: const Color(0xFFFFD700),
                        fmt: fmt,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Card(
                        label: 'Taken',
                        amount: taken,
                        color: const Color(0xFFE74C3C),
                        fmt: fmt,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _Card(
                  label: 'Given',
                  amount: given,
                  color: const Color(0xFFFFD700),
                  fmt: fmt,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Card(
                  label: 'Taken',
                  amount: taken,
                  color: const Color(0xFFE74C3C),
                  fmt: fmt,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Card(
                  label: 'Net',
                  amount: net,
                  color: netColor,
                  fmt: fmt,
                  emphasized: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final NumberFormat fmt;
  final bool emphasized;

  const _Card({
    required this.label,
    required this.amount,
    required this.color,
    required this.fmt,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        constraints: const BoxConstraints(minHeight: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${fmt.format(amount)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: emphasized ? 26 : 20,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
