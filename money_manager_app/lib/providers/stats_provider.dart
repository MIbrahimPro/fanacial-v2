import 'package:flutter/material.dart';

import '../models/index.dart';
import '../services/storage_service.dart';

class StatsProvider extends ChangeNotifier {
  final _storage = StorageService.instance;

  List<StatEntry> getEntries(String cardType) =>
      _storage.getStatEntriesByType(cardType);

  double getTotal(String cardType) =>
      _storage.getTotalForCardType(cardType);

  double getNetTotal() => _storage.getNetTotal();

  Future<String> addEntry({
    required String cardType,
    required String name,
    required double amount,
  }) async {
    final id = await _storage.createStatEntry(
      cardType: cardType,
      name: name,
      amount: amount,
    );
    notifyListeners();
    return id;
  }

  Future<void> updateEntry(StatEntry entry) async {
    await _storage.updateStatEntry(entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _storage.deleteStatEntry(id);
    notifyListeners();
  }
}
