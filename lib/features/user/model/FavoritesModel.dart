import 'dart:convert';

FavoritesModel favoritesModelFromJson(String str) =>
    FavoritesModel.fromJson(json.decode(str));

String favoritesModelToJson(FavoritesModel data) => json.encode(data.toJson());

class FavoritesModel {
  List<ProductFavorites> productsFavorites;

  FavoritesModel({required this.productsFavorites});

  factory FavoritesModel.fromJson(Map<String, dynamic> json) => FavoritesModel(
    productsFavorites: List<ProductFavorites>.from(
      json["products"].map((x) => ProductFavorites.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "products": List<dynamic>.from(productsFavorites.map((x) => x.toJson())),
  };
}

class ProductFavorites {
  int id;
  String title;
  String description;
  String? titleAr;
  String? descriptionAr;
  int price;
  int stock;
  List<String> images;
  DateTime createdAt;
  DateTime updatedAt;
  int userId;
  int categoryId;
  Seller seller;

  ProductFavorites({
    required this.id,
    required this.title,
    required this.description,
    this.titleAr,
    this.descriptionAr,
    required this.price,
    required this.stock,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.categoryId,
    required this.seller,
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

  factory ProductFavorites.fromJson(Map<String, dynamic> json) =>
      ProductFavorites(
        id: _asInt(json["id"]),
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
        price: _asInt(json["price"]),
        stock: _asInt(json["stock"]),
        images: List<String>.from(
          (json["images"] ?? []).map((x) => x.toString()),
        ),
        createdAt: _asDate(json["createdAt"]),
        updatedAt: _asDate(json["updatedAt"]),
        userId: _asInt(json["userId"]),
        categoryId: _asInt(json["categoryId"]),
        seller: Seller.fromJson(json["seller"] ?? const {}),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "title_ar": titleAr,
    "description_ar": descriptionAr,
    "price": price,
    "stock": stock,
    "images": List<dynamic>.from(images.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "userId": userId,
    "categoryId": categoryId,
    "seller": seller.toJson(),
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

class Seller {
  int id;
  String name;
  String phone;
  String location;
  String role;
  bool isVerified;
  String image;

  Seller({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.role,
    required this.isVerified,
    required this.image,
  });

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is List && value.isNotEmpty) return value.first.toString();
    return value.toString();
  }

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    id: _asInt(json["id"]),
    name: _asString(json["name"]),
    phone: _asString(json["phone"]),
    location: _asString(json["location"]),
    role: _asString(json["role"]),
    isVerified: json["isVerified"] == true,
    image: _asString(json["image"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "location": location,
    "role": role,
    "isVerified": isVerified,
    "image": image,
  };
}
