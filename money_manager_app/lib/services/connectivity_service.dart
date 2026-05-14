import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _lastOnline = false;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChanged => _controller.stream;

  bool get isOnline => _lastOnline;

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) async {
    final hasInterface = results.any((r) => r != ConnectivityResult.none);
    bool online = false;
    
    if (hasInterface) {
      try {
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
        online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (_) {
        online = false;
      }
    }

    if (online != _lastOnline) {
      _lastOnline = online;
      _controller.add(online);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
