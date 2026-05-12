import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/index.dart';

class HiveInitializer {
  static final HiveInitializer instance = HiveInitializer._();
  HiveInitializer._();

  bool _initialized = false;
  final _uuid = const Uuid();

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

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

    if (Hive.box<UserSettings>('settings').isEmpty) {
      await Hive.box<UserSettings>('settings').put(
        'local',
        const UserSettings(),
      );
    }

    if (Hive.box<Tag>('tags').isEmpty) {
      await Hive.box<Tag>('tags').add(
        Tag(
          id: _uuid.v4(),
          name: 'General',
          color: '#9E9E9E',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    _initialized = true;
    debugPrint('Hive initialized successfully');
  }
}
