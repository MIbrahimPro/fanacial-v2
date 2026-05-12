import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/storage_service.dart';

class MonthlyTrackerProvider extends ChangeNotifier {
  final _storage = StorageService.instance;

  DateTime _currentMonth;

  MonthlyTrackerProvider() : _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  DateTime get currentMonth => _currentMonth;
  String get monthLabel => _formatMonth(_currentMonth);
  bool get isCurrentMonth =>
      _currentMonth.year == DateTime.now().year &&
      _currentMonth.month == DateTime.now().month;

  List<Transaction> get transactions =>
      _storage.getTransactionsByMonth(_currentMonth.year, _currentMonth.month);

  double get monthlyIncome =>
      _storage.getMonthlyIncome(_currentMonth.year, _currentMonth.month);

  double get monthlyOutgoing =>
      _storage.getMonthlyOutgoing(_currentMonth.year, _currentMonth.month);

  double get monthlyNet => monthlyIncome - monthlyOutgoing;

  List<Tag> get tags => _storage.getAllTags();

  Map<int, Map<String, double>> get dailyData {
    final data = <int, Map<String, double>>{};
    for (final tx in transactions) {
      final day = tx.date.day;
      data.putIfAbsent(day, () => {'income': 0.0, 'outgoing': 0.0});
      if (tx.type == 'income') {
        data[day]!['income'] = (data[day]!['income'] ?? 0) + tx.amount;
      } else {
        data[day]!['outgoing'] = (data[day]!['outgoing'] ?? 0) + tx.amount;
      }
    }
    return data;
  }

  void goToPreviousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    notifyListeners();
  }

  void goToNextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final now = DateTime(DateTime.now().year, DateTime.now().month, 1);
    if (next.isAfter(now)) return;
    _currentMonth = next;
    notifyListeners();
  }

  void goToCurrentMonth() {
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    notifyListeners();
  }

  Future<String> addTransaction({
    required String type,
    required String name,
    String? description,
    required double amount,
    required String tagId,
    required DateTime date,
  }) async {
    final id = await _storage.createTransaction(
      type: type,
      name: name,
      description: description,
      amount: amount,
      tagId: tagId,
      date: date,
    );
    notifyListeners();
    return id;
  }

  Future<void> updateTransaction(Transaction tx) async {
    await _storage.updateTransaction(tx);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _storage.deleteTransaction(id);
    notifyListeners();
  }

  String _formatMonth(DateTime dt) {
    return '${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }
}
