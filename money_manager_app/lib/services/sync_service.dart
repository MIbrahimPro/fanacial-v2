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

  Future<void> syncNow() async {
    if (_isSyncing) return;

    final token = await _pinService.getToken();
    if (token == null) {
      throw StateError('Sync not authorized — enter PIN first');
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final records = _buildPendingRecords();
      await _api.sync(
        lastSync: _lastSyncTime?.toIso8601String(),
        records: records.isNotEmpty ? records : null,
      );

      _updateSyncedStatus();
      _updateLastSyncTime();

      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      rethrow;
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
      result['people']!.add(person.toJson());
    }
    for (final tag in _tagBox.values) {
      result['tags']!.add(tag.toJson());
    }

    result.removeWhere((_, v) => v.isEmpty);
    return result;
  }

  void _updateSyncedStatus() {
    for (final key in _txBox.keys) {
      final tx = _txBox.get(key);
      if (tx != null && tx.syncStatus == 'pending') {
        _txBox.put(key, tx.copyWith(syncStatus: 'synced'));
      }
    }
    for (final key in _statBox.keys) {
      final stat = _statBox.get(key);
      if (stat != null && stat.syncStatus == 'pending') {
        _statBox.put(key, stat.copyWith(syncStatus: 'synced'));
      }
    }
    for (final key in _loanBox.keys) {
      final loan = _loanBox.get(key);
      if (loan != null && loan.syncStatus == 'pending') {
        _loanBox.put(key, loan.copyWith(syncStatus: 'synced'));
      }
    }
  }

  void _updateLastSyncTime() {
    _lastSyncTime = DateTime.now();
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
