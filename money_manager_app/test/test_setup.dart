import 'dart:io';

import 'package:hive/hive.dart';

import 'package:money_manager_app/models/index.dart';

class HiveTestHelper {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final dir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(dir.path);

    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(StatEntryAdapter());
    Hive.registerAdapter(LoanAdapter());
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(TagAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(SyncMetadataAdapter());

    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<StatEntry>('statEntries');
    await Hive.openBox<Loan>('loans');
    await Hive.openBox<Person>('persons');
    await Hive.openBox<Tag>('tags');
    await Hive.openBox<UserSettings>('settings');
    await Hive.openBox<SyncMetadata>('syncMetadata');
  }
}
