import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/person.dart';
import '../providers/loans_provider.dart';
import '../widgets/empty_state.dart';
import 'loans_manager/pages/add_person_dialog.dart';
import 'loans_manager/widgets/loans_summary_cards.dart';
import 'loans_manager/widgets/person_list_item.dart';

class LoansManagerScreen extends StatelessWidget {
  const LoansManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoansProvider>();
    final persons = provider.getPersons();
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoansSummaryCards(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'People',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _addPerson(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Person'),
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              clipBehavior: Clip.antiAlias,
              child: persons.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No people yet',
                      subtitle: 'Add someone to start tracking loans.',
                    )
                  : Column(
                      children: persons.map((person) {
                        final balance = provider.getNetBalanceForPerson(person.id);
                        return PersonListItem(
                          person: person,
                          netBalance: balance,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/person-detail',
                              arguments: person.id,
                            );
                          },
                          onEdit: () {
                            AddPersonDialog.show(context, editPerson: person);
                          },
                          onDelete: () => _confirmDelete(context, person),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPerson(BuildContext context) {
    AddPersonDialog.show(context);
  }

  void _confirmDelete(BuildContext context, Person person) {
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
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
