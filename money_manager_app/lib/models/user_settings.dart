import 'package:hive/hive.dart';

class UserSettings {
  final String id;
  final String theme;
  final bool autoSync;
  final String? syncToken;
  final DateTime? syncTokenExpiry;
  final DateTime? lastSyncTime;
  final String language;

  const UserSettings({
    this.id = 'local',
    this.theme = 'light',
    this.autoSync = false,
    this.syncToken,
    this.syncTokenExpiry,
    this.lastSyncTime,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'theme': theme,
        'autoSync': autoSync,
        'syncToken': syncToken,
        'syncTokenExpiry': syncTokenExpiry?.toIso8601String(),
        'lastSyncTime': lastSyncTime?.toIso8601String(),
        'language': language,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        id: json['id'] as String? ?? 'local',
        theme: json['theme'] as String? ?? 'light',
        autoSync: json['autoSync'] as bool? ?? false,
        syncToken: json['syncToken'] as String?,
        syncTokenExpiry: json['syncTokenExpiry'] != null
            ? DateTime.parse(json['syncTokenExpiry'] as String)
            : null,
        lastSyncTime: json['lastSyncTime'] != null
            ? DateTime.parse(json['lastSyncTime'] as String)
            : null,
        language: json['language'] as String? ?? 'en',
      );

  UserSettings copyWith({
    String? id,
    String? theme,
    bool? autoSync,
    String? syncToken,
    DateTime? syncTokenExpiry,
    DateTime? lastSyncTime,
    String? language,
  }) =>
      UserSettings(
        id: id ?? this.id,
        theme: theme ?? this.theme,
        autoSync: autoSync ?? this.autoSync,
        syncToken: syncToken ?? this.syncToken,
        syncTokenExpiry: syncTokenExpiry ?? this.syncTokenExpiry,
        lastSyncTime: lastSyncTime ?? this.lastSyncTime,
        language: language ?? this.language,
      );
}

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 5;

  @override
  UserSettings read(BinaryReader reader) {
    final fields = reader.readMap().cast<int, dynamic>();
    return UserSettings(
      id: fields[0] as String? ?? 'local',
      theme: fields[1] as String? ?? 'light',
      autoSync: fields[2] as bool? ?? false,
      syncToken: fields[3] as String?,
      syncTokenExpiry: fields[4] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[4] as int)
          : null,
      lastSyncTime: fields[5] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[5] as int)
          : null,
      language: fields[6] as String? ?? 'en',
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer.writeMap({
      0: obj.id,
      1: obj.theme,
      2: obj.autoSync,
      3: obj.syncToken,
      4: obj.syncTokenExpiry?.millisecondsSinceEpoch,
      5: obj.lastSyncTime?.millisecondsSinceEpoch,
      6: obj.language,
    });
  }
}
