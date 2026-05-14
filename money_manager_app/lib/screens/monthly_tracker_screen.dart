import 'package:flutter/material.dart';

import 'monthly_tracker/widgets/custom_monthly_graph.dart';
import 'monthly_tracker/widgets/month_navigator.dart';
import 'monthly_tracker/widgets/monthly_summary_card.dart';
import 'monthly_tracker/widgets/transaction_list.dart';
import 'monthly_tracker/pages/add_transaction_modal.dart';
import '../providers/monthly_tracker_provider.dart';
import '../utils/date_helpers.dart';
import 'package:provider/provider.dart';

class MonthlyTrackerScreen extends StatelessWidget {
  const MonthlyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonthlyTrackerProvider>();

    return Scaffold(
      body: Column(
        children: [
          const MonthNavigator(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        provider.goToPreviousMonth();
                      } else if (details.primaryVelocity! < 0) {
                        provider.goToNextMonth();
                      }
                    },
                    child: CustomMonthlyGraph(
                      dailyData: provider.dailyData,
                      daysInMonth: DateHelpers.daysInMonth(
                        provider.currentMonth.year,
                        provider.currentMonth.month,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: MonthlySummaryCard()),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 80),
                  sliver: SliverToBoxAdapter(
                    child: TransactionList(
                      key: ValueKey(
                        '${provider.currentMonth.year}-${provider.currentMonth.month}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddTransactionModal.show(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
