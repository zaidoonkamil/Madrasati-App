import 'dart:convert';

GetNotifications getNotificationsFromJson(String str) =>
    GetNotifications.fromJson(json.decode(str));

String getNotificationsToJson(GetNotifications data) =>
    json.encode(data.toJson());

class GetNotifications {
  int total;
  int page;
  int totalPages;
  List<Log> logs;

  GetNotifications({
    required this.total,
    required this.page,
    required this.totalPages,
    required this.logs,
  });

  factory GetNotifications.fromJson(Map<String, dynamic> json) =>
      GetNotifications(
        total: json["total"],
        page: json["page"],
        totalPages: json["totalPages"],
        logs: List<Log>.from(json["logs"].map((x) => Log.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "totalPages": totalPages,
    "logs": List<dynamic>.from(logs.map((x) => x.toJson())),
  };
}

class Log {
  int id;
  int? userId;
  String title;
  String message;
  String? titleAr;
  String? messageAr;
  String targetType;
  String targetValue;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  Log({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.titleAr,
    this.messageAr,
    required this.targetType,
    required this.targetValue,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static DateTime _asDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory Log.fromJson(Map<String, dynamic> json) => Log(
    id: _asInt(json["id"]),
    userId: json["user_id"] == null ? null : _asInt(json["user_id"]),
    title: _asString(json["title"]),
    message: _asString(json["message"]),
    titleAr:
        _asString(json["title_ar"]).isEmpty
            ? null
            : _asString(json["title_ar"]),
    messageAr:
        _asString(json["message_ar"]).isEmpty
            ? null
            : _asString(json["message_ar"]),
    targetType: _asString(json["target_type"]),
    targetValue: _asString(json["target_value"]),
    status: _asString(json["status"]),
    createdAt: _asDate(json["createdAt"]),
    updatedAt: _asDate(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "message": message,
    "title_ar": titleAr,
    "message_ar": messageAr,
    "target_type": targetType,
    "target_value": targetValue,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };

  String localizedTitle(String localeCode) {
    final arabic = (titleAr ?? '').trim();
    return arabic.isNotEmpty ? arabic : title;
  }

  String localizedMessage(String localeCode) {
    final arabic = (messageAr ?? '').trim();
    return arabic.isNotEmpty ? arabic : message;
  }
}
