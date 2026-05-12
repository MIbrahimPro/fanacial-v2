import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/stats_provider.dart';
import 'stats_manager/widgets/stats_card.dart';

class StatsManagerScreen extends StatelessWidget {
  const StatsManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatsProvider>();
    final net = provider.getNetTotal();
    final fmt = NumberFormat('#,##0.00');
    final netColor = net >= 0 ? Colors.green : const Color(0xFFE74C3C);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Column(
          children: [
            _buildCard(context, 'assets', 'Assets', const Color(0xFFFFD700),),
            _buildCard(context, 'liabilities', 'Liabilities', const Color(0xFFE74C3C)),
            _buildCard(context, 'income', 'Income', const Color(0xFF4A90D9)),
            _buildCard(context, 'expenses', 'Expenses', const Color(0xFFE74C3C)),
            const SizedBox(height: 8),
            Card(
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
            ),
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
