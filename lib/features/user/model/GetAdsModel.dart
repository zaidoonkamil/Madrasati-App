import 'dart:convert';

List<GetAds> getAdsFromJson(String str) =>
    List<GetAds>.from(json.decode(str).map((x) => GetAds.fromJson(x)));

String getAdsToJson(List<GetAds> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAds {
  int id;
  List<String> images;
  String title;
  String description;
  String? titleAr;
  String? descriptionAr;
  DateTime createdAt;
  DateTime updatedAt;

  GetAds({
    required this.id,
    required this.images,
    required this.title,
    required this.description,
    this.titleAr,
    this.descriptionAr,
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

  factory GetAds.fromJson(Map<String, dynamic> json) => GetAds(
    id: _asInt(json["id"]),
    images: List<String>.from((json["images"] ?? []).map((x) => x.toString())),
    title: _asString(json["title"]),
    description: _asString(json["description"]),
    titleAr:
        _asString(json["title_ar"]).isEmpty
            ? null
            : _asString(json["title_ar"]),
    descriptionAr:
        _asString(json["description_ar"]).isEmpty
            ? null
            : _asString(json["description_ar"]),
    createdAt: _asDate(json["createdAt"]),
    updatedAt: _asDate(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "images": List<dynamic>.from(images.map((x) => x)),
    "title": title,
    "description": description,
    "title_ar": titleAr,
    "description_ar": descriptionAr,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };

  String localizedTitle(String localeCode) {
    final arabic = (titleAr ?? '').trim();
    return arabic.isNotEmpty ? arabic : title;
  }

  String localizedDescription(String localeCode) {
    final arabic = (descriptionAr ?? '').trim();
    return arabic.isNotEmpty ? arabic : description;
  }
}
