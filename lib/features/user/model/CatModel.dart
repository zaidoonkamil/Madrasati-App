import 'dart:convert';

List<CatModel> catModelFromJson(String str) =>
    List<CatModel>.from(json.decode(str).map((x) => CatModel.fromJson(x)));

String catModelToJson(List<CatModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CatModel {
  int id;
  String name;
  String? nameAr;
  int? parentId;
  List<String> images;
  List<CatModel> subcategories;
  DateTime createdAt;
  DateTime updatedAt;

  CatModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.parentId,
    required this.images,
    this.subcategories = const [],
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

  factory CatModel.fromJson(Map<String, dynamic> json) => CatModel(
    id: _asInt(json["id"]),
    name: _asString(json["name"]),
    nameAr:
        _asString(json["name_ar"]).isEmpty ? null : _asString(json["name_ar"]),
    parentId: json["parentId"] == null ? null : _asInt(json["parentId"]),
    images: List<String>.from((json["images"] ?? []).map((x) => x.toString())),
    subcategories: List<CatModel>.from(
      (json["subcategories"] ?? []).map(
        (x) => CatModel.fromJson(x as Map<String, dynamic>),
      ),
    ),
    createdAt: _asDate(json["createdAt"]),
    updatedAt: _asDate(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "name_ar": nameAr,
    "parentId": parentId,
    "images": List<dynamic>.from(images.map((x) => x)),
    "subcategories": List<dynamic>.from(subcategories.map((x) => x.toJson())),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };

  String localizedName(String localeCode) {
    final arabic = (nameAr ?? '').trim();
    return arabic.isNotEmpty ? arabic : name;
  }

  bool get isMainCategory => parentId == null;
  bool get isSubcategory => parentId != null;
}
