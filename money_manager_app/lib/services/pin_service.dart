import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _pinKey = 'sync_pin_hash';
  static const _tokenKey = 'sync_token';
  static const _expiryKey = 'sync_expiry';

  final FlutterSecureStorage _storage;

  PinService(this._storage);

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    if (pin.length != 4 || int.tryParse(pin) == null) {
      throw ArgumentError('PIN must be 4 digits');
    }
    await _storage.write(key: _pinKey, value: _hash(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null) return false;
    return stored == _hash(pin);
  }

  Future<bool> isTokenValid() async {
    final expiryStr = await _storage.read(key: _expiryKey);
    if (expiryStr == null) return false;
    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  Future<String?> getToken() async {
    final valid = await isTokenValid();
    if (!valid) return null;
    return await _storage.read(key: _tokenKey);
  }

  Future<void> generateToken() async {
    final token = 'mm-sync-secret-k7F9xP2q';
    final expiry = DateTime.now().add(const Duration(days: 365));
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _expiryKey, value: expiry.toIso8601String());
  }

  Future<void> disableSync() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiryKey);
  }

  String _hash(String pin) {
    int h = 0;
    for (int i = 0; i < pin.length; i++) {
      h = 31 * h + pin.codeUnitAt(i);
    }
    return h.toString();
  }
}
