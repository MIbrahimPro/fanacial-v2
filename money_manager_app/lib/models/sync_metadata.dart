import 'package:hive/hive.dart';

class SyncMetadata {
  final String id;
  final String recordId;
  final String recordType;
  final DateTime lastModified;
  final bool isDeleted;
  final int version;

  const SyncMetadata({
    required this.id,
    required this.recordId,
    required this.recordType,
    required this.lastModified,
    this.isDeleted = false,
    this.version = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'recordId': recordId,
        'recordType': recordType,
        'lastModified': lastModified.toIso8601String(),
        'isDeleted': isDeleted,
        'version': version,
      };

  factory SyncMetadata.fromJson(Map<String, dynamic> json) => SyncMetadata(
        id: json['id'] as String,
        recordId: json['recordId'] as String,
        recordType: json['recordType'] as String,
        lastModified: DateTime.parse(json['lastModified'] as String),
        isDeleted: json['isDeleted'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
      );

  SyncMetadata copyWith({
    String? id,
    String? recordId,
    String? recordType,
    DateTime? lastModified,
    bool? isDeleted,
    int? version,
  }) =>
      SyncMetadata(
        id: id ?? this.id,
        recordId: recordId ?? this.recordId,
        recordType: recordType ?? this.recordType,
        lastModified: lastModified ?? this.lastModified,
        isDeleted: isDeleted ?? this.isDeleted,
        version: version ?? this.version,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SyncMetadata && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SyncMetadataAdapter extends TypeAdapter<SyncMetadata> {
  @override
  final int typeId = 6;

  @override
  SyncMetadata read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return SyncMetadata(
      id: fields[0] as String,
      recordId: fields[1] as String,
      recordType: fields[2] as String,
      lastModified: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      isDeleted: fields[4] as bool? ?? false,
      version: fields[5] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, SyncMetadata obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.recordId,
      2: obj.recordType,
      3: obj.lastModified.millisecondsSinceEpoch,
      4: obj.isDeleted,
      5: obj.version,
    });
  }
}
