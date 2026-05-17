import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager_app/models/index.dart';

void main() {
  group('sync model parsing', () {
    test('transaction accepts decimal amount returned as string', () {
      final tx = Transaction.fromJson({
        'id': 'tx-1',
        'type': 'income',
        'name': 'Salary',
        'description': null,
        'amount': '123.45',
        'tag_id': 'tag-1',
        'date': '2026-05-17T12:00:00.000Z',
        'created_at': '2026-05-17T12:00:00.000Z',
        'updated_at': '2026-05-17T12:00:00.000Z',
      });

      expect(tx.amount, 123.45);
    });

    test('stat entry accepts decimal amount returned as string', () {
      final entry = StatEntry.fromJson({
        'id': 'stat-1',
        'card_type': 'assets',
        'name': 'Cash',
        'amount': '50.25',
        'created_at': '2026-05-17T12:00:00.000Z',
        'updated_at': '2026-05-17T12:00:00.000Z',
      });

      expect(entry.amount, 50.25);
    });

    test('loan accepts decimal amount returned as string', () {
      final loan = Loan.fromJson({
        'id': 'loan-1',
        'person_id': 'person-1',
        'amount': '10.50',
        'type': 'given',
        'description': null,
        'date': '2026-05-17T12:00:00.000Z',
        'created_at': '2026-05-17T12:00:00.000Z',
        'updated_at': '2026-05-17T12:00:00.000Z',
      });

      expect(loan.amount, 10.50);
    });
  });
}
