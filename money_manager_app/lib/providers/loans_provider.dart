import 'package:flutter/material.dart';

import '../models/index.dart';
import '../services/storage_service.dart';

class LoansProvider extends ChangeNotifier {
  final _storage = StorageService.instance;

  List<Person> getPersons() => _storage.getAllPersons();

  bool personNameExists(String name) => _storage.personNameExists(name);

  Future<String> addPerson(String name) async {
    final id = await _storage.createPerson(name: name);
    notifyListeners();
    return id;
  }

  Future<void> updatePerson(Person person) async {
    await _storage.updatePerson(person);
    notifyListeners();
  }

  Future<void> deletePerson(String id) async {
    await _storage.deletePerson(id);
    notifyListeners();
  }

  List<Loan> getLoansByPerson(String personId) =>
      _storage.getLoansByPerson(personId);

  double getNetBalanceForPerson(String personId) =>
      _storage.getNetBalanceForPerson(personId);

  double getTotalGiven() => _storage.getTotalGiven();
  double getTotalTaken() => _storage.getTotalTaken();
  double getNet() => _storage.getNet();

  Future<String> addLoan({
    required String personId,
    required double amount,
    required String type,
    String? description,
    DateTime? date,
  }) async {
    final id = await _storage.createLoan(
      personId: personId,
      amount: amount,
      type: type,
      description: description,
      date: date,
    );
    notifyListeners();
    return id;
  }

  Future<void> updateLoan(Loan loan) async {
    await _storage.updateLoan(loan);
    notifyListeners();
  }

  Future<void> deleteLoan(String id) async {
    await _storage.deleteLoan(id);
    notifyListeners();
  }
}
