import 'package:flutter/material.dart';

import 'dashboard/widgets/loans_summary_section.dart';
import 'dashboard/widgets/stats_summary_section.dart';
import 'dashboard/widgets/tracker_summary_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const TrackerSummarySection(),
            const StatsSummarySection(),
            const LoansSummarySection(),
          ],
        ),
      ),
    );
  }
}
