import 'package:flutter/material.dart';

import '../services/pin_service.dart';
import '../services/sync_service.dart';

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;
  final PinService _pinService;

  bool _syncEnabled = false;
  bool _hasPin = false;

  bool get isSyncing => _syncService.isSyncing;
  bool get autoSync => _syncService.autoSync;
  DateTime? get lastSync => _syncService.lastSyncTime;
  bool get hasPin => _hasPin;
  bool get syncEnabled => _syncEnabled;

  SyncProvider(this._syncService, this._pinService);

  Future<void> init() async {
    final token = await _pinService.getToken();
    _syncEnabled = token != null;
    _hasPin = await _pinService.hasPin() || token != null;
    notifyListeners();
  }

  Future<bool> loginAndEnable(String pin) async {
    try {
      await _syncService.login(pin);
      _syncEnabled = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> disableSync() async {
    await _pinService.clearToken();
    _syncEnabled = false;
    notifyListeners();
  }

  Future<void> toggleAutoSync() async {
    final newVal = !_syncService.autoSync;
    await _syncService.setAutoSync(newVal);
    notifyListeners();
  }

  Future<String?> syncNow() async {
    try {
      await _syncService.syncNow();
      notifyListeners();
      return null;
    } catch (e) {
      if (e.toString().contains('AUTH_REQUIRED')) {
        return 'AUTH_REQUIRED';
      }
      return e.toString();
    }
  }
}
