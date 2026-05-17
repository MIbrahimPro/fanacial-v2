import 'package:hive/hive.dart';

class Transaction {
  final String id;
  final String type;
  final String name;
  final String? description;
  final double amount;
  final String tagId;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const Transaction({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.amount,
    required this.tagId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'description': description,
        'amount': amount,
        'tag_id': tagId,
        'date': date.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: json['type'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        amount: (json['amount'] as num).toDouble(),
        tagId: (json['tag_id'] ?? json['tagId']) as String,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
        updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
        syncStatus: json['syncStatus'] as String? ?? 'synced',
      );

  Transaction copyWith({
    String? id,
    String? type,
    String? name,
    String? description,
    double? amount,
    String? tagId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) =>
      Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        tagId: tagId ?? this.tagId,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Transaction && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return Transaction(
      id: fields[0] as String,
      type: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String?,
      amount: (fields[4] as num).toDouble(),
      tagId: fields[5] as String,
      date: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[7] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[8] as int),
      syncStatus: fields[9] as String? ?? 'pending',
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.type,
      2: obj.name,
      3: obj.description,
      4: obj.amount,
      5: obj.tagId,
      6: obj.date.millisecondsSinceEpoch,
      7: obj.createdAt.millisecondsSinceEpoch,
      8: obj.updatedAt.millisecondsSinceEpoch,
      9: obj.syncStatus,
    });
  }
}
