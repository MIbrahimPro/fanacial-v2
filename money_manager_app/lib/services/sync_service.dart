import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/index.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'pin_service.dart';
import 'storage_service.dart';

class SyncService extends ChangeNotifier {
  final ApiService _api;
  final ConnectivityService _connectivity;
  final PinService _pinService;
  final StorageService _storage = StorageService.instance;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  bool _autoSync = false;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get autoSync => _autoSync;

  SyncService(this._api, this._connectivity, this._pinService) {
    _connectivity.onStatusChanged.listen(_onConnectivityChanged);
    _loadSettings();
  }

  void _loadSettings() {
    final settings = _storage.getSettings();
    _autoSync = settings.autoSync;
    _lastSyncTime = settings.lastSyncTime;
  }

  Future<void> setAutoSync(bool enabled) async {
    _autoSync = enabled;
    await _storage.updateSettings(
      _storage.getSettings().copyWith(autoSync: enabled),
    );
    notifyListeners();
  }

  Future<void> login(String pin) async {
    final token = await _api.login(pin);
    await _pinService.saveToken(token);
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;

    String? token = await _pinService.getToken();
    if (token == null) {
      throw StateError('AUTH_REQUIRED');
    }
    _api.setToken(token);

    _isSyncing = true;
    notifyListeners();

    try {
      final records = _buildPendingRecords();
      final response = await _api.sync(
        lastSync: _lastSyncTime?.toIso8601String(),
        records: records.isNotEmpty ? records : null,
      );

      // Process pulled data from server
      final pullData = response['data'] as Map<String, dynamic>?;
      if (pullData != null) {
        _applyPullData(pullData);
      }

      final conflicts = (response['conflicts'] as List?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const <Map<String, dynamic>>[];
      if (conflicts.isNotEmpty) {
        debugPrint('Sync: ${conflicts.length} conflict(s), server version kept');
      }

      _updateSyncedStatus(conflicts);
      _updateLastSyncTime(response['sync_time'] as String?);

      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      if (e is ApiException && e.message.contains('Unauthorized')) {
        await _pinService.clearToken();
        throw StateError('AUTH_REQUIRED');
      }
      rethrow;
    }
  }

  void _applyPullData(Map<String, dynamic> pullData) {
    // Transactions
    final txs = pullData['transactions'] as List?;
    if (txs != null) {
      for (final txJson in txs) {
        final tx = Transaction.fromJson(txJson as Map<String, dynamic>);
        final existing = _txBox.get(tx.id);
        if (existing == null ||
            existing.syncStatus != 'pending' ||
            tx.updatedAt.isAfter(existing.updatedAt)) {
          _txBox.put(tx.id, tx.copyWith(syncStatus: 'synced'));
        }
      }
    }

    // Stat entries
    final stats = pullData['stat_entries'] as List?;
    if (stats != null) {
      for (final statJson in stats) {
        final stat = StatEntry.fromJson(statJson as Map<String, dynamic>);
        final existing = _statBox.get(stat.id);
        if (existing == null ||
            existing.syncStatus != 'pending' ||
            stat.updatedAt.isAfter(existing.updatedAt)) {
          _statBox.put(stat.id, stat.copyWith(syncStatus: 'synced'));
        }
      }
    }

    // Loans
    final loans = pullData['loans'] as List?;
    if (loans != null) {
      for (final loanJson in loans) {
        final loan = Loan.fromJson(loanJson as Map<String, dynamic>);
        final existing = _loanBox.get(loan.id);
        if (existing == null ||
            existing.syncStatus != 'pending' ||
            loan.updatedAt.isAfter(existing.updatedAt)) {
          _loanBox.put(loan.id, loan.copyWith(syncStatus: 'synced'));
        }
      }
    }

    // People
    final people = pullData['people'] as List?;
    if (people != null) {
      for (final personJson in people) {
        final person = Person.fromJson(personJson as Map<String, dynamic>);
        final existing = _personBox.get(person.id);
        if (existing == null || person.updatedAt.isAfter(existing.updatedAt)) {
          _personBox.put(person.id, person);
        }
      }
    }

    // Tags
    final tags = pullData['tags'] as List?;
    if (tags != null) {
      for (final tagJson in tags) {
        final tag = Tag.fromJson(tagJson as Map<String, dynamic>);
        final existing = _tagBox.get(tag.id);
        if (existing == null || tag.updatedAt.isAfter(existing.updatedAt)) {
          _tagBox.put(tag.id, tag);
        }
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> _buildPendingRecords() {
    final result = <String, List<Map<String, dynamic>>>{
      'transactions': [],
      'stat_entries': [],
      'loans': [],
      'people': [],
      'tags': [],
    };

    for (final tx in _txBox.values) {
      if (tx.syncStatus == 'pending') {
        result['transactions']!.add(tx.toJson());
      }
    }
    for (final stat in _statBox.values) {
      if (stat.syncStatus == 'pending') {
        result['stat_entries']!.add(stat.toJson());
      }
    }
    for (final loan in _loanBox.values) {
      if (loan.syncStatus == 'pending') {
        result['loans']!.add(loan.toJson());
      }
    }
    for (final person in _personBox.values) {
      if (_lastSyncTime == null || person.updatedAt.isAfter(_lastSyncTime!)) {
        result['people']!.add(person.toJson());
      }
    }
    for (final tag in _tagBox.values) {
      if (_lastSyncTime == null || tag.updatedAt.isAfter(_lastSyncTime!)) {
        result['tags']!.add(tag.toJson());
      }
    }

    result.removeWhere((_, v) => v.isEmpty);
    return result;
  }

  void _updateSyncedStatus(List<Map<String, dynamic>> conflicts) {
    final conflictTxIds = conflicts
        .where((c) => c['table'] == 'transactions')
        .map((c) => c['id'] as String)
        .toSet();
    final conflictStatIds = conflicts
        .where((c) => c['table'] == 'stat_entries')
        .map((c) => c['id'] as String)
        .toSet();
    final conflictLoanIds = conflicts
        .where((c) => c['table'] == 'loans')
        .map((c) => c['id'] as String)
        .toSet();

    for (final key in _txBox.keys) {
      final tx = _txBox.get(key);
      if (tx != null &&
          tx.syncStatus == 'pending' &&
          !conflictTxIds.contains(tx.id)) {
        _txBox.put(key, tx.copyWith(syncStatus: 'synced'));
      }
    }
    for (final key in _statBox.keys) {
      final stat = _statBox.get(key);
      if (stat != null &&
          stat.syncStatus == 'pending' &&
          !conflictStatIds.contains(stat.id)) {
        _statBox.put(key, stat.copyWith(syncStatus: 'synced'));
      }
    }
    for (final key in _loanBox.keys) {
      final loan = _loanBox.get(key);
      if (loan != null &&
          loan.syncStatus == 'pending' &&
          !conflictLoanIds.contains(loan.id)) {
        _loanBox.put(key, loan.copyWith(syncStatus: 'synced'));
      }
    }
  }

  void _updateLastSyncTime(String? serverSyncTime) {
    _lastSyncTime = serverSyncTime != null
        ? DateTime.tryParse(serverSyncTime)?.toUtc() ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();
    _storage.updateSettings(
      _storage.getSettings().copyWith(lastSyncTime: _lastSyncTime),
    );
  }

  void _onConnectivityChanged(bool online) {
    if (online && _autoSync) {
      try {
        syncNow();
      } catch (_) {}
    }
  }

  Box<Transaction> get _txBox => Hive.box<Transaction>('transactions');
  Box<StatEntry> get _statBox => Hive.box<StatEntry>('statEntries');
  Box<Loan> get _loanBox => Hive.box<Loan>('loans');
  Box<Person> get _personBox => Hive.box<Person>('persons');
  Box<Tag> get _tagBox => Hive.box<Tag>('tags');


}
