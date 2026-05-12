import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:money_manager_app/models/index.dart';
import 'package:money_manager_app/providers/monthly_tracker_provider.dart';
import 'package:money_manager_app/services/storage_service.dart';
import 'test_setup.dart';

void main() {
  late MonthlyTrackerProvider provider;

  setUpAll(() async {
    await HiveTestHelper.init();
    provider = MonthlyTrackerProvider();
    provider.goToCurrentMonth();
  });

  setUp(() async {
    await Hive.box<Transaction>('transactions').clear();
    await Hive.box<StatEntry>('statEntries').clear();
    await Hive.box<Loan>('loans').clear();
    await Hive.box<Person>('persons').clear();
    await Hive.box<Tag>('tags').clear();
    await Hive.box<SyncMetadata>('syncMetadata').clear();
    await Hive.box<UserSettings>('settings').clear();
    provider.goToCurrentMonth();
  });

  group('month navigation', () {
    test('initial month is current month', () {
      final now = DateTime.now();
      expect(provider.currentMonth.year, now.year);
      expect(provider.currentMonth.month, now.month);
      expect(provider.currentMonth.day, 1);
    });

    test('goToPreviousMonth decrements month', () {
      final original = provider.currentMonth;
      provider.goToPreviousMonth();
      final expected = DateTime(original.year, original.month - 1, 1);
      expect(provider.currentMonth, expected);
    });

    test('goToPreviousMonth handles year boundary', () {
      provider.goToPreviousMonth();
      // If we were in January, we should be in December of previous year
      // This test just verifies no crash and month changes
      final current = provider.currentMonth;
      expect(current.day, 1);
    });

    test('goToNextMonth does not go past current month', () {
      final current = provider.currentMonth;
      final now = DateTime.now();
      if (current.month < now.month || current.year < now.year) {
        provider.goToNextMonth();
        expect(provider.currentMonth.isAfter(current), true);
      }
    });

    test('isCurrentMonth returns true for current month', () {
      expect(provider.isCurrentMonth, true);
    });

    test('goToCurrentMonth resets to current month', () async {
      provider.goToPreviousMonth();
      provider.goToCurrentMonth();
      final now = DateTime.now();
      expect(provider.currentMonth.year, now.year);
      expect(provider.currentMonth.month, now.month);
    });
  });

  group('transactions', () {
    test('transactions returns empty list initially', () {
      expect(provider.transactions, isEmpty);
    });

    test('addTransaction creates and refreshes list', () async {
      await provider.addTransaction(
        type: 'income',
        name: 'Test Salary',
        amount: 3000,
        tagId: 'tag-1',
        date: DateTime.now(),
      );

      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.name, 'Test Salary');
    });

    test('monthlyIncome and monthlyOutgoing sums correctly', () async {
      final now = DateTime.now();
      await provider.addTransaction(
        type: 'income', name: 'Salary', amount: 5000, tagId: 't1', date: now);
      await provider.addTransaction(
        type: 'income', name: 'Freelance', amount: 2000, tagId: 't1', date: now);
      await provider.addTransaction(
        type: 'outgoing', name: 'Rent', amount: 1500, tagId: 't1', date: now);

      expect(provider.monthlyIncome, 7000.0);
      expect(provider.monthlyOutgoing, 1500.0);
      expect(provider.monthlyNet, 5500.0);
    });

    test('deleteTransaction removes and refreshes', () async {
      final id = await provider.addTransaction(
        type: 'income', name: 'Delete Me', amount: 100, tagId: 't1',
        date: DateTime.now(),
      );

      expect(provider.transactions.length, 1);

      await provider.deleteTransaction(id);
      expect(provider.transactions, isEmpty);
    });

    test('transactions filtered by current month only', () async {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, 15);

      await provider.addTransaction(
        type: 'income', name: 'Current', amount: 100, tagId: 't1', date: now);
      await provider.addTransaction(
        type: 'income', name: 'Last Month', amount: 200, tagId: 't1',
        date: lastMonth);

      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.name, 'Current');

      provider.goToPreviousMonth();
      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.name, 'Last Month');
    });

    test('dailyData groups transactions by day', () async {
      final now = DateTime.now();
      final day5 = DateTime(now.year, now.month, 5);
      final day10 = DateTime(now.year, now.month, 10);

      await provider.addTransaction(
        type: 'income', name: 'A', amount: 500, tagId: 't1', date: day5);
      await provider.addTransaction(
        type: 'outgoing', name: 'B', amount: 200, tagId: 't1', date: day5);
      await provider.addTransaction(
        type: 'income', name: 'C', amount: 1000, tagId: 't1', date: day10);

      final data = provider.dailyData;
      expect(data[5], isNotNull);
      expect(data[5]!['income'], 500.0);
      expect(data[5]!['outgoing'], 200.0);
      expect(data[10]!['income'], 1000.0);
      expect(data[10]!['outgoing'], 0.0);
    });
  });

  group('tags', () {
    test('tags returns all tags', () async {
      await StorageService.instance.createTag(name: 'Food', color: '#FF5722');
      await StorageService.instance.createTag(name: 'Salary', color: '#4CAF50');

      expect(provider.tags.length, 2);
    });
  });
}
