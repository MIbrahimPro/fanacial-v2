import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:money_manager_app/models/index.dart';
import 'package:money_manager_app/providers/loans_provider.dart';
import 'test_setup.dart';

void main() {
  late LoansProvider provider;

  setUpAll(() async {
    await HiveTestHelper.init();
    provider = LoansProvider();
  });

  setUp(() async {
    await Hive.box<Loan>('loans').clear();
    await Hive.box<Person>('persons').clear();
  });

  group('LoansProvider', () {
    test('persons is empty initially', () {
      expect(provider.getPersons(), isEmpty);
    });

    test('addPerson creates person', () async {
      final id = await provider.addPerson('Alice');
      expect(id, isNotEmpty);
      expect(provider.getPersons().length, 1);
      expect(provider.getPersons().first.name, 'Alice');
    });

    test('personNameExists checks duplicates', () async {
      await provider.addPerson('Alice');
      expect(provider.personNameExists('Alice'), true);
      expect(provider.personNameExists('Bob'), false);
    });

    test('deletePerson cascades to loans', () async {
      final id = await provider.addPerson('Charlie');
      await provider.addLoan(personId: id, amount: 500, type: 'given', date: DateTime.now());
      await provider.addLoan(personId: id, amount: 200, type: 'taken', date: DateTime.now());

      expect(provider.getLoansByPerson(id).length, 2);
      await provider.deletePerson(id);
      expect(provider.getPersons().length, 0);
      expect(provider.getLoansByPerson(id).length, 0);
    });

    test('loan totals calculate correctly', () async {
      final p1 = await provider.addPerson('Alice');
      final p2 = await provider.addPerson('Bob');

      await provider.addLoan(personId: p1, amount: 1000, type: 'given', date: DateTime.now());
      await provider.addLoan(personId: p2, amount: 500, type: 'given', date: DateTime.now());
      await provider.addLoan(personId: p2, amount: 200, type: 'taken', date: DateTime.now());

      expect(provider.getTotalGiven(), 1500.0);
      expect(provider.getTotalTaken(), 200.0);
      expect(provider.getNet(), 1300.0);
    });

    test('net balance per person', () async {
      final id = await provider.addPerson('Alice');
      await provider.addLoan(personId: id, amount: 600, type: 'given', date: DateTime.now());
      await provider.addLoan(personId: id, amount: 200, type: 'taken', date: DateTime.now());
      await provider.addLoan(personId: id, amount: 100, type: 'given', date: DateTime.now());

      expect(provider.getNetBalanceForPerson(id), 500.0);
    });

    test('deleteLoan removes single loan', () async {
      final id = await provider.addPerson('Alice');
      final loanId = await provider.addLoan(personId: id, amount: 300, type: 'given', date: DateTime.now());

      expect(provider.getLoansByPerson(id).length, 1);
      await provider.deleteLoan(loanId);
      expect(provider.getLoansByPerson(id).length, 0);
    });
  });
}
