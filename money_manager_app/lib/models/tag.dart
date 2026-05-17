import 'package:hive/hive.dart';

class Tag {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as String,
        createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
        updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
      );

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Tag && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TagAdapter extends TypeAdapter<Tag> {
  @override
  final int typeId = 4;

  @override
  Tag read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return Tag(
      id: fields[0] as String,
      name: fields[1] as String,
      color: fields[2] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Tag obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.name,
      2: obj.color,
      3: obj.createdAt.millisecondsSinceEpoch,
      4: obj.updatedAt.millisecondsSinceEpoch,
    });
  }
}
