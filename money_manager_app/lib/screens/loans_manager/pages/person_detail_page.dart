import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart';
import '../../../providers/loans_provider.dart';
import '../../../widgets/empty_state.dart';
import 'add_loan_modal.dart';
import 'add_person_dialog.dart';

class PersonDetailPage extends StatelessWidget {
  final String personId;

  const PersonDetailPage({
    super.key,
    required this.personId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoansProvider>();
    final persons = provider.getPersons();
    final person = persons.cast<Person?>().firstWhere(
          (p) => p?.id == personId,
          orElse: () => null,
        );

    if (person == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Person')),
        body: const Center(child: Text('Person not found')),
      );
    }

    final loans = provider.getLoansByPerson(personId);
    final balance = provider.getNetBalanceForPerson(personId);
    final fmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat('d MMM');
    final balanceColor = balance >= 0 ? Colors.green : const Color(0xFFE74C3C);

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') _editPerson(context, person);
              if (val == 'delete') _deletePerson(context, person);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Rename'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Balance',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '\$${fmt.format(balance)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: balanceColor,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: () => AddLoanModal.show(context, personId: personId),
                  tooltip: 'Add Loan',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: loans.isEmpty
                ? const EmptyState(
                    icon: Icons.swap_horiz_outlined,
                    title: 'No loans yet',
                    subtitle: 'Tap + to add a give or take entry.',
                  )
                : ListView.builder(
                    itemCount: loans.length,
                    itemBuilder: (context, index) {
                      final loan = loans[index];
                      final isGiven = loan.type == 'given';
                      final amountColor = isGiven ? const Color(0xFF4A90D9) : const Color(0xFFE74C3C);
                      final sign = isGiven ? '+' : '-';

                      return _LoanItem(
                        loan: loan,
                        amountColor: amountColor,
                        sign: sign,
                        fmt: fmt,
                        dateFmt: dateFmt,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _editPerson(BuildContext context, Person person) {
    AddPersonDialog.show(context, editPerson: person);
  }

  void _deletePerson(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Person'),
        content: Text('Delete "${person.name}" and all their loans?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<LoansProvider>().deletePerson(person.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Person deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _LoanItem extends StatelessWidget {
  final Loan loan;
  final Color amountColor;
  final String sign;
  final NumberFormat fmt;
  final DateFormat dateFmt;

  const _LoanItem({
    required this.loan,
    required this.amountColor,
    required this.sign,
    required this.fmt,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showActions(context),
      onSecondaryTap: () => _showActions(context),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                loan.type == 'given' ? 'Give' : 'Take',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.description != null && loan.description!.isNotEmpty
                        ? loan.description!
                        : (loan.type == 'given' ? 'Money Given' : 'Money Taken'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    dateFmt.format(loan.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign\$${fmt.format(loan.amount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
        children: [
          if (loan.description != null && loan.description!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loan.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(ctx);
                AddLoanModal.show(context, personId: loan.personId, editLoan: loan);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Entry', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _delete(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Loan'),
        content: const Text('Delete this loan entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<LoansProvider>().deleteLoan(loan.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
