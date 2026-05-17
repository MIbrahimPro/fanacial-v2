import 'package:hive/hive.dart';

class StatEntry {
  final String id;
  final String cardType;
  final String name;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const StatEntry({
    required this.id,
    required this.cardType,
    required this.name,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'card_type': cardType,
        'name': name,
        'amount': amount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory StatEntry.fromJson(Map<String, dynamic> json) => StatEntry(
        id: json['id'] as String,
        cardType: (json['card_type'] ?? json['cardType']) as String,
        name: json['name'] as String,
        amount: _parseAmount(json['amount']),
        createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
        updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
        syncStatus: json['syncStatus'] as String? ?? 'synced',
      );

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid amount value: $value');
  }

  StatEntry copyWith({
    String? id,
    String? cardType,
    String? name,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) =>
      StatEntry(
        id: id ?? this.id,
        cardType: cardType ?? this.cardType,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StatEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class StatEntryAdapter extends TypeAdapter<StatEntry> {
  @override
  final int typeId = 1;

  @override
  StatEntry read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return StatEntry(
      id: fields[0] as String,
      cardType: fields[1] as String,
      name: fields[2] as String,
      amount: (fields[3] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      syncStatus: fields[6] as String? ?? 'pending',
    );
  }

  @override
  void write(BinaryWriter writer, StatEntry obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.cardType,
      2: obj.name,
      3: obj.amount,
      4: obj.createdAt.millisecondsSinceEpoch,
      5: obj.updatedAt.millisecondsSinceEpoch,
      6: obj.syncStatus,
    });
  }
}
