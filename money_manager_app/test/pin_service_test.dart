import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:money_manager_app/services/pin_service.dart';

void main() {
  late PinService pinService;

  setUp(() {
    pinService = PinService(InsecureStorage());
  });

  group('PinService', () {
    test('hasPin returns false initially', () async {
      expect(await pinService.hasPin(), false);
    });

    test('setPin stores PIN', () async {
      await pinService.setPin('1234');
      expect(await pinService.hasPin(), true);
    });

    test('verifyPin matches stored PIN', () async {
      await pinService.setPin('5678');
      expect(await pinService.verifyPin('5678'), true);
      expect(await pinService.verifyPin('0000'), false);
    });

    test('setPin rejects non-4-digit PIN', () async {
      expect(() => pinService.setPin('123'), throwsArgumentError);
      expect(() => pinService.setPin('abc'), throwsArgumentError);
      expect(() => pinService.setPin(''), throwsArgumentError);
    });

    test('isTokenValid returns false before token generated', () async {
      expect(await pinService.isTokenValid(), false);
    });

    test('generateToken makes token valid', () async {
      await pinService.setPin('1234');
      await pinService.saveToken('test-jwt-token');
      expect(await pinService.isTokenValid(), true);
      expect(await pinService.getToken(), 'test-jwt-token');
    });

    test('disableSync invalidates token', () async {
      await pinService.setPin('1234');
      await pinService.saveToken('test-jwt-token');
      await pinService.clearToken();
      expect(await pinService.isTokenValid(), false);
      expect(await pinService.getToken(), null);
    });
  });
}

class InsecureStorage extends FlutterSecureStorage {
  final _store = <String, String>{};

  @override
  Future<void> write({
    required String key,
    String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) _store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<bool> containsKey({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_store);
  }

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }
}
