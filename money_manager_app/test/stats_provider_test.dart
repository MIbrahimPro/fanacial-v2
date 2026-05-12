import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:money_manager_app/models/index.dart';
import 'package:money_manager_app/providers/stats_provider.dart';
import 'test_setup.dart';

void main() {
  late StatsProvider provider;

  setUpAll(() async {
    await HiveTestHelper.init();
    provider = StatsProvider();
  });

  setUp(() async {
    await Hive.box<StatEntry>('statEntries').clear();
  });

  group('StatsProvider', () {
    test('entries are empty initially', () {
      expect(provider.getEntries('assets'), isEmpty);
      expect(provider.getEntries('liabilities'), isEmpty);
      expect(provider.getEntries('income'), isEmpty);
      expect(provider.getEntries('expenses'), isEmpty);
    });

    test('addEntry creates and adds to list', () async {
      await provider.addEntry(cardType: 'assets', name: 'Savings', amount: 10000);
      final entries = provider.getEntries('assets');
      expect(entries.length, 1);
      expect(entries.first.name, 'Savings');
      expect(entries.first.amount, 10000.0);
    });

    test('getTotal sums correctly per card type', () async {
      await provider.addEntry(cardType: 'assets', name: 'Cash', amount: 5000);
      await provider.addEntry(cardType: 'assets', name: 'Stocks', amount: 3000);
      await provider.addEntry(cardType: 'liabilities', name: 'Debt', amount: 2000);

      expect(provider.getTotal('assets'), 8000.0);
      expect(provider.getTotal('liabilities'), 2000.0);
    });

    test('getNetTotal calculates correctly', () async {
      await provider.addEntry(cardType: 'assets', name: 'Cash', amount: 10000);
      await provider.addEntry(cardType: 'liabilities', name: 'Debt', amount: 3000);
      await provider.addEntry(cardType: 'income', name: 'Salary', amount: 5000);
      await provider.addEntry(cardType: 'expenses', name: 'Rent', amount: 2000);

      expect(provider.getNetTotal(), (10000 - 3000) + (5000 - 2000));
    });

    test('deleteEntry removes entry', () async {
      final id = await provider.addEntry(cardType: 'income', name: 'Job', amount: 1000);
      expect(provider.getEntries('income').length, 1);

      await provider.deleteEntry(id);
      expect(provider.getEntries('income').length, 0);
    });
  });
}
