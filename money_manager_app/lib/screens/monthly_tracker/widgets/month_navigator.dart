import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/monthly_tracker_provider.dart';

class MonthNavigator extends StatelessWidget {
  const MonthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonthlyTrackerProvider>();
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: provider.goToPreviousMonth,
              tooltip: 'Previous month',
            ),
            Expanded(
              child: Text(
                provider.monthLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!provider.isCurrentMonth)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: TextButton(
                  onPressed: provider.goToCurrentMonth,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Today', style: TextStyle(fontSize: 12)),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: provider.goToNextMonth,
              tooltip: 'Next month',
            ),
          ],
        ),
      ),
    );
  }
}
