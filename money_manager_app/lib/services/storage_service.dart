import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/index.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();
  final _uuid = const Uuid();

  // Box getters
  Box<Transaction> get _txBox => Hive.box<Transaction>('transactions');
  Box<StatEntry> get _statBox => Hive.box<StatEntry>('statEntries');
  Box<Loan> get _loanBox => Hive.box<Loan>('loans');
  Box<Person> get _personBox => Hive.box<Person>('persons');
  Box<Tag> get _tagBox => Hive.box<Tag>('tags');
  Box<UserSettings> get _settingsBox =>
      Hive.box<UserSettings>('settings');
  Box<SyncMetadata> get _syncBox => Hive.box<SyncMetadata>('syncMetadata');

  DateTime _now() => DateTime.now();

  // ====================== TRANSACTIONS ======================

  Future<String> createTransaction({
    required String type,
    required String name,
    String? description,
    required double amount,
    required String tagId,
    required DateTime date,
  }) async {
    final id = _uuid.v4();
    final now = _now();
    final tx = Transaction(
      id: id,
      type: type,
      name: name,
      description: description,
      amount: amount,
      tagId: tagId,
      date: date,
      createdAt: now,
      updatedAt: now,
    );
    await _txBox.put(id, tx);
    return id;
  }

  Transaction? getTransaction(String id) => _txBox.get(id);

  List<Transaction> getAllTransactions() => _txBox.values.toList();

  List<Transaction> getTransactionsByMonth(int year, int month) {
    return _txBox.values
        .where((t) => t.date.year == year && t.date.month == month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Transaction> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _txBox.values
        .where((t) =>
            t.date.isAfter(start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Transaction> getRecentTransactions(int count) {
    final all = _txBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return all.take(count).toList();
  }

  double getMonthlyIncome(int year, int month) {
    return _txBox.values
        .where((t) =>
            t.date.year == year &&
            t.date.month == month &&
            t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyOutgoing(int year, int month) {
    return _txBox.values
        .where((t) =>
            t.date.year == year &&
            t.date.month == month &&
            t.type == 'outgoing')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyNet(int year, int month) {
    return getMonthlyIncome(year, month) - getMonthlyOutgoing(year, month);
  }

  List<Transaction> getTransactionsByTag(String tagId) {
    return _txBox.values.where((t) => t.tagId == tagId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateTransaction(Transaction tx) async {
    final now = _now();
    await _txBox.put(tx.id, tx.copyWith(updatedAt: now, syncStatus: 'pending'));
  }

  Future<void> deleteTransaction(String id) async {
    await _txBox.delete(id);
  }

  // ====================== STAT ENTRIES ======================

  Future<String> createStatEntry({
    required String cardType,
    required String name,
    required double amount,
  }) async {
    final id = _uuid.v4();
    final now = _now();
    final entry = StatEntry(
      id: id,
      cardType: cardType,
      name: name,
      amount: amount,
      createdAt: now,
      updatedAt: now,
    );
    await _statBox.put(id, entry);
    return id;
  }

  StatEntry? getStatEntry(String id) => _statBox.get(id);

  List<StatEntry> getStatEntriesByType(String cardType) {
    return _statBox.values
        .where((e) => e.cardType == cardType)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  double getTotalForCardType(String cardType) {
    return _statBox.values
        .where((e) => e.cardType == cardType)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getNetTotal() {
    final assets = getTotalForCardType('assets');
    final liabilities = getTotalForCardType('liabilities');
    final income = getTotalForCardType('income');
    final expenses = getTotalForCardType('expenses');
    return (assets - liabilities) + (income - expenses);
  }

  Future<void> updateStatEntry(StatEntry entry) async {
    final now = _now();
    await _statBox.put(
        entry.id, entry.copyWith(updatedAt: now, syncStatus: 'pending'));
  }

  Future<void> deleteStatEntry(String id) async {
    await _statBox.delete(id);
  }

  // ====================== LOANS ======================

  Future<String> createLoan({
    required String personId,
    required double amount,
    required String type,
    String? description,
    DateTime? date,
  }) async {
    final id = _uuid.v4();
    final now = _now();
    final loan = Loan(
      id: id,
      personId: personId,
      amount: amount,
      type: type,
      description: description,
      date: date ?? now,
      createdAt: now,
      updatedAt: now,
    );
    await _loanBox.put(id, loan);
    return id;
  }

  Loan? getLoan(String id) => _loanBox.get(id);

  List<Loan> getLoansByPerson(String personId) {
    return _loanBox.values
        .where((l) => l.personId == personId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalGiven() {
    return _loanBox.values
        .where((l) => l.type == 'given')
        .fold(0.0, (sum, l) => sum + l.amount);
  }

  double getTotalTaken() {
    return _loanBox.values
        .where((l) => l.type == 'taken')
        .fold(0.0, (sum, l) => sum + l.amount);
  }

  double getNet() => getTotalGiven() - getTotalTaken();

  double getNetBalanceForPerson(String personId) {
    final loans = _loanBox.values.where((l) => l.personId == personId);
    double given = 0, taken = 0;
    for (final l in loans) {
      if (l.type == 'given') given += l.amount;
      if (l.type == 'taken') taken += l.amount;
    }
    return given - taken;
  }

  Future<void> updateLoan(Loan loan) async {
    final now = _now();
    await _loanBox.put(loan.id, loan.copyWith(updatedAt: now, syncStatus: 'pending'));
  }

  Future<void> deleteLoan(String id) async {
    await _loanBox.delete(id);
  }

  // ====================== PERSONS ======================

  Future<String> createPerson({required String name}) async {
    final id = _uuid.v4();
    final now = _now();
    final person = Person(id: id, name: name, createdAt: now, updatedAt: now);
    await _personBox.put(id, person);
    return id;
  }

  Person? getPerson(String id) => _personBox.get(id);

  List<Person> getAllPersons() {
    final persons = _personBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return persons;
  }

  List<Map<String, dynamic>> getTopPersonsByBalance(int count) {
    final persons = _personBox.values.toList();
    persons.sort((a, b) =>
        getNetBalanceForPerson(b.id).abs().compareTo(getNetBalanceForPerson(a.id).abs()));
    return persons.take(count).map((p) => {
      'person': p,
      'balance': getNetBalanceForPerson(p.id),
    }).toList();
  }

  Future<void> updatePerson(Person person) async {
    final now = _now();
    await _personBox.put(person.id, person.copyWith(updatedAt: now));
  }

  Future<void> deletePerson(String id) async {
    final loansToDelete =
        _loanBox.values.where((l) => l.personId == id).map((l) => l.id).toList();
    for (final loanId in loansToDelete) {
      await _loanBox.delete(loanId);
    }
    await _personBox.delete(id);
  }

  bool personNameExists(String name) {
    return _personBox.values.any(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
  }

  // ====================== TAGS ======================

  Future<String> createTag({required String name, required String color}) async {
    final id = _uuid.v4();
    final now = _now();
    final tag = Tag(id: id, name: name, color: color, createdAt: now, updatedAt: now);
    await _tagBox.put(id, tag);
    return id;
  }

  Tag? getTag(String id) => _tagBox.get(id);

  List<Tag> getAllTags() {
    return _tagBox.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> updateTag(Tag tag) async {
    final now = _now();
    await _tagBox.put(tag.id, tag.copyWith(updatedAt: now));
  }

  Future<void> deleteTag(String id) async {
    await _tagBox.delete(id);
  }

  bool tagNameExists(String name) {
    return _tagBox.values
        .any((t) => t.name.toLowerCase() == name.toLowerCase());
  }

  // ====================== SETTINGS ======================

  UserSettings getSettings() {
    return _settingsBox.get('local') ?? const UserSettings();
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _settingsBox.put('local', settings);
  }

  Future<void> toggleTheme() async {
    final s = getSettings();
    await _settingsBox.put(
      'local',
      s.copyWith(theme: s.theme == 'light' ? 'dark' : 'light'),
    );
  }

  // ====================== SYNC METADATA ======================

  Future<void> markPending(String recordId, String recordType) async {
    final existing = _findSyncMeta(recordId, recordType);
    if (existing != null) {
      await _syncBox.put(
        existing.id,
        existing.copyWith(lastModified: _now(), version: existing.version + 1),
      );
    } else {
      final id = _uuid.v4();
      await _syncBox.put(
        id,
        SyncMetadata(
          id: id,
          recordId: recordId,
          recordType: recordType,
          lastModified: _now(),
        ),
      );
    }
  }

  Future<void> markSynced(String recordId) async {
    final existing = _findSyncMetaByRecordId(recordId);
    if (existing != null) {
      await _syncBox.delete(existing.id);
    }
  }

  Future<void> markDeleted(String recordId, String recordType) async {
    final existing = _findSyncMeta(recordId, recordType);
    if (existing != null) {
      await _syncBox.put(
        existing.id,
        existing.copyWith(isDeleted: true, lastModified: _now()),
      );
    } else {
      final id = _uuid.v4();
      await _syncBox.put(
        id,
        SyncMetadata(
          id: id,
          recordId: recordId,
          recordType: recordType,
          lastModified: _now(),
          isDeleted: true,
        ),
      );
    }
  }

  List<SyncMetadata> getPendingRecords() {
    final pending = <SyncMetadata>[];
    for (final tx in _txBox.values) {
      if (tx.syncStatus == 'pending') {
        pending.add(
          SyncMetadata(
            id: _uuid.v4(),
            recordId: tx.id,
            recordType: 'transaction',
            lastModified: tx.updatedAt,
          ),
        );
      }
    }
    for (final stat in _statBox.values) {
      if (stat.syncStatus == 'pending') {
        pending.add(
          SyncMetadata(
            id: _uuid.v4(),
            recordId: stat.id,
            recordType: 'statEntry',
            lastModified: stat.updatedAt,
          ),
        );
      }
    }
    for (final loan in _loanBox.values) {
      if (loan.syncStatus == 'pending') {
        pending.add(
          SyncMetadata(
            id: _uuid.v4(),
            recordId: loan.id,
            recordType: 'loan',
            lastModified: loan.updatedAt,
          ),
        );
      }
    }
    return pending;
  }

  SyncMetadata? _findSyncMeta(String recordId, String recordType) {
    try {
      return _syncBox.values.firstWhere(
        (m) => m.recordId == recordId && m.recordType == recordType,
      );
    } catch (_) {
      return null;
    }
  }

  SyncMetadata? _findSyncMetaByRecordId(String recordId) {
    try {
      return _syncBox.values.firstWhere((m) => m.recordId == recordId);
    } catch (_) {
      return null;
    }
  }
}
