import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:money_manager_app/models/index.dart';
import 'package:money_manager_app/services/storage_service.dart';
import 'test_setup.dart';

void main() {
  late StorageService storage;

  setUpAll(() async {
    await HiveTestHelper.init();
    storage = StorageService.instance;
  });

  setUp(() async {
    await Hive.box<Transaction>('transactions').clear();
    await Hive.box<StatEntry>('statEntries').clear();
    await Hive.box<Loan>('loans').clear();
    await Hive.box<Person>('persons').clear();
    await Hive.box<Tag>('tags').clear();
    await Hive.box<SyncMetadata>('syncMetadata').clear();
    await Hive.box<UserSettings>('settings').clear();
  });

  group('Transactions', () {
    test('create and retrieve transaction', () async {
      final id = await storage.createTransaction(
        type: 'income',
        name: 'Salary',
        amount: 5000,
        tagId: 'tag-1',
        date: DateTime(2026, 5, 1),
      );

      expect(id, isNotEmpty);

      final tx = storage.getTransaction(id);
      expect(tx, isNotNull);
      expect(tx!.name, 'Salary');
      expect(tx.type, 'income');
      expect(tx.amount, 5000.0);
      expect(tx.syncStatus, 'pending');
    });

    test('get transactions by month', () async {
      await storage.createTransaction(
        type: 'income',
        name: 'Salary May',
        amount: 5000,
        tagId: 'tag-1',
        date: DateTime(2026, 5, 10),
      );
      await storage.createTransaction(
        type: 'outgoing',
        name: 'Rent May',
        amount: 1000,
        tagId: 'tag-1',
        date: DateTime(2026, 5, 5),
      );
      await storage.createTransaction(
        type: 'income',
        name: 'Salary June',
        amount: 5000,
        tagId: 'tag-1',
        date: DateTime(2026, 6, 1),
      );

      final mayTxs = storage.getTransactionsByMonth(2026, 5);
      expect(mayTxs.length, 2);
      expect(mayTxs[0].name, 'Salary May');
      expect(mayTxs[1].name, 'Rent May');

      final juneTxs = storage.getTransactionsByMonth(2026, 6);
      expect(juneTxs.length, 1);
    });

    test('get monthly income and outgoing sums', () async {
      await storage.createTransaction(
        type: 'income',
        name: 'Salary',
        amount: 5000,
        tagId: 'tag-1',
        date: DateTime(2026, 5, 1),
      );
      await storage.createTransaction(
        type: 'income',
        name: 'Freelance',
        amount: 2000,
        tagId: 'tag-1',
        date: DateTime(2026, 5, 15),
      );
      await storage.createTransaction(
        type: 'outgoing',
        name: 'Rent',
        amount: 1500,
        tagId: 'tag-1',
        date: DateTime(2026, 5, 5),
      );

      expect(storage.getMonthlyIncome(2026, 5), 7000.0);
      expect(storage.getMonthlyOutgoing(2026, 5), 1500.0);
      expect(storage.getMonthlyNet(2026, 5), 5500.0);
    });

    test('update transaction', () async {
      final id = await storage.createTransaction(
        type: 'outgoing',
        name: 'Old Name',
        amount: 100,
        tagId: 'tag-1',
        date: DateTime.now(),
      );
      final tx = storage.getTransaction(id)!;

      await storage.updateTransaction(
          tx.copyWith(name: 'New Name', amount: 200));

      final updated = storage.getTransaction(id);
      expect(updated!.name, 'New Name');
      expect(updated.amount, 200.0);
      expect(updated.syncStatus, 'pending');
    });

    test('delete transaction', () async {
      final id = await storage.createTransaction(
        type: 'income',
        name: 'Delete Me',
        amount: 100,
        tagId: 'tag-1',
        date: DateTime.now(),
      );

      await storage.deleteTransaction(id);
      expect(storage.getTransaction(id), isNull);
    });

    test('get transactions by tag', () async {
      await storage.createTransaction(
        type: 'income',
        name: 'Tagged A',
        amount: 100,
        tagId: 'tag-a',
        date: DateTime(2026, 5, 1),
      );
      await storage.createTransaction(
        type: 'income',
        name: 'Tagged A 2',
        amount: 200,
        tagId: 'tag-a',
        date: DateTime(2026, 5, 2),
      );
      await storage.createTransaction(
        type: 'outgoing',
        name: 'Tagged B',
        amount: 50,
        tagId: 'tag-b',
        date: DateTime(2026, 5, 3),
      );

      final tagATxs = storage.getTransactionsByTag('tag-a');
      expect(tagATxs.length, 2);

      final tagBTxs = storage.getTransactionsByTag('tag-b');
      expect(tagBTxs.length, 1);
    });
  });

  group('StatEntries', () {
    test('create and retrieve stat entry', () async {
      final id = await storage.createStatEntry(
        cardType: 'assets',
        name: 'Savings',
        amount: 10000,
      );

      final entry = storage.getStatEntry(id);
      expect(entry, isNotNull);
      expect(entry!.cardType, 'assets');
      expect(entry.amount, 10000.0);
    });

    test('get stat entries by type and calculate totals', () async {
      await storage.createStatEntry(
          cardType: 'assets', name: 'Savings', amount: 10000);
      await storage.createStatEntry(
          cardType: 'assets', name: 'Stocks', amount: 5000);
      await storage.createStatEntry(
          cardType: 'liabilities', name: 'Credit Card', amount: 2000);
      await storage.createStatEntry(
          cardType: 'income', name: 'Job', amount: 5000);
      await storage.createStatEntry(
          cardType: 'expenses', name: 'Rent', amount: 1500);

      expect(storage.getStatEntriesByType('assets').length, 2);
      expect(storage.getStatEntriesByType('liabilities').length, 1);
      expect(storage.getTotalForCardType('assets'), 15000.0);
      expect(storage.getTotalForCardType('liabilities'), 2000.0);
    });

    test('calculate net total', () async {
      await storage.createStatEntry(
          cardType: 'assets', name: 'Cash', amount: 10000);
      await storage.createStatEntry(
          cardType: 'liabilities', name: 'Debt', amount: 3000);
      await storage.createStatEntry(
          cardType: 'income', name: 'Salary', amount: 5000);
      await storage.createStatEntry(
          cardType: 'expenses', name: 'Bills', amount: 2000);

      expect(storage.getNetTotal(), 10000.0);
    });
  });

  group('Loans and Persons', () {
    test('create person and loan, calculate net balance', () async {
      final personId = await storage.createPerson(name: 'Alice');

      await storage.createLoan(
          personId: personId,
          amount: 500,
          type: 'given',
          date: DateTime.now());
      await storage.createLoan(
          personId: personId,
          amount: 200,
          type: 'taken',
          date: DateTime.now());

      expect(storage.getNetBalanceForPerson(personId), 300.0);
    });

    test('global loan totals', () async {
      final p1 = await storage.createPerson(name: 'Alice');
      final p2 = await storage.createPerson(name: 'Bob');

      await storage.createLoan(
          personId: p1, amount: 1000, type: 'given', date: DateTime.now());
      await storage.createLoan(
          personId: p2, amount: 500, type: 'given', date: DateTime.now());
      await storage.createLoan(
          personId: p2, amount: 200, type: 'taken', date: DateTime.now());

      expect(storage.getTotalGiven(), 1500.0);
      expect(storage.getTotalTaken(), 200.0);
      expect(storage.getNet(), 1300.0);
    });

    test('delete person cascades to loans', () async {
      final personId = await storage.createPerson(name: 'Charlie');

      await storage.createLoan(
          personId: personId,
          amount: 300,
          type: 'given',
          date: DateTime.now());
      await storage.createLoan(
          personId: personId,
          amount: 100,
          type: 'taken',
          date: DateTime.now());

      expect(storage.getLoansByPerson(personId).length, 2);

      await storage.deletePerson(personId);

      expect(storage.getPerson(personId), isNull);
      expect(storage.getLoansByPerson(personId).length, 0);
    });
  });

  group('Tags', () {
    test('create, read, update, delete tag', () async {
      final id = await storage.createTag(name: 'Food', color: '#FF5722');

      final tag = storage.getTag(id);
      expect(tag, isNotNull);
      expect(tag!.name, 'Food');
      expect(tag.color, '#FF5722');

      await storage.updateTag(tag.copyWith(name: 'Groceries'));
      expect(storage.getTag(id)!.name, 'Groceries');

      await storage.deleteTag(id);
      expect(storage.getTag(id), isNull);
    });

    test('tag name uniqueness check', () async {
      await storage.createTag(name: 'Unique', color: '#FF5722');
      expect(storage.tagNameExists('Unique'), true);
      expect(storage.tagNameExists('unique'), true);
      expect(storage.tagNameExists('Other'), false);
    });
  });

  group('Settings', () {
    test('default settings returned when box empty', () async {
      final settings = storage.getSettings();
      expect(settings.id, 'local');
      expect(settings.theme, 'light');
      expect(settings.autoSync, false);
      expect(settings.language, 'en');
    });

    test('toggle theme', () async {
      final before = storage.getSettings();
      expect(before.theme, 'light');

      await storage.toggleTheme();
      expect(storage.getSettings().theme, 'dark');

      await storage.toggleTheme();
      expect(storage.getSettings().theme, 'light');
    });
  });

  group('Sync Metadata', () {
    test('mark and retrieve pending records', () async {
      await storage.createTransaction(
        type: 'income',
        name: 'Pending Tx',
        amount: 100,
        tagId: 'tag-1',
        date: DateTime.now(),
      );

      final pending = storage.getPendingRecords();
      expect(pending.isNotEmpty, true);
      expect(pending.any((m) => m.recordType == 'transaction'), true);
    });
  });
}
