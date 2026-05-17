import 'package:hive/hive.dart';

class Loan {
  final String id;
  final String personId;
  final double amount;
  final String type;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const Loan({
    required this.id,
    required this.personId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'person_id': personId,
        'amount': amount,
        'type': type,
        'description': description,
        'date': date.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'] as String,
        personId: (json['person_id'] ?? json['personId']) as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
        updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
        syncStatus: json['syncStatus'] as String? ?? 'synced',
      );

  Loan copyWith({
    String? id,
    String? personId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) =>
      Loan(
        id: id ?? this.id,
        personId: personId ?? this.personId,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        description: description ?? this.description,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Loan && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 2;

  @override
  Loan read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return Loan(
      id: fields[0] as String,
      personId: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      type: fields[3] as String,
      description: fields[4] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[7] as int),
      syncStatus: fields[8] as String? ?? 'pending',
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.personId,
      2: obj.amount,
      3: obj.type,
      4: obj.description,
      5: obj.date.millisecondsSinceEpoch,
      6: obj.createdAt.millisecondsSinceEpoch,
      7: obj.updatedAt.millisecondsSinceEpoch,
      8: obj.syncStatus,
    });
  }
}
