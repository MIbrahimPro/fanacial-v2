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
    _hasPin = await _pinService.hasPin();
    final valid = await _pinService.isTokenValid();
    _syncEnabled = valid;
    notifyListeners();
  }

  Future<bool> setPin(String pin) async {
    try {
      await _pinService.setPin(pin);
      await _pinService.generateToken();
      _syncEnabled = true;
      _hasPin = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPinAndEnable(String pin) async {
    final ok = await _pinService.verifyPin(pin);
    if (!ok) return false;
    await _pinService.generateToken();
    _syncEnabled = true;
    notifyListeners();
    return true;
  }

  Future<void> disableSync() async {
    await _pinService.disableSync();
    _syncEnabled = false;
    _hasPin = await _pinService.hasPin();
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
      return e.toString();
    }
  }
}
