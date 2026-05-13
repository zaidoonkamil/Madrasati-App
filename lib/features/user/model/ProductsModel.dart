import 'dart:convert';

ProductsModel productsModelFromJson(String str) =>
    ProductsModel.fromJson(json.decode(str));

String productsModelToJson(ProductsModel data) => json.encode(data.toJson());

class ProductsModel {
  PaginationProducts paginationProducts;
  List<Product> products;

  ProductsModel({required this.paginationProducts, required this.products});

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    paginationProducts: PaginationProducts(
      totalItems: json["totalItems"],
      totalPages: json["totalPages"],
      currentPage: json["currentPage"],
    ),
    products: List<Product>.from(
      json["products"].map((x) => Product.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "totalItems": paginationProducts.totalItems,
    "totalPages": paginationProducts.totalPages,
    "currentPage": paginationProducts.currentPage,
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}

class Product {
  int id;
  String title;
  String description;
  String? titleAr;
  String? descriptionAr;
  int price;
  int stock;
  int lowStockAlert;
  List<String> colors;
  List<String> sizes;
  List<String> images;
  DateTime createdAt;
  DateTime updatedAt;
  int userId;
  Seller seller;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    this.titleAr,
    this.descriptionAr,
    required this.price,
    required this.stock,
    required this.lowStockAlert,
    required this.colors,
    required this.sizes,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.seller,
    required this.isFavorite,
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

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
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
    lowStockAlert: _asInt(json["lowStockAlert"]),
    colors: _asStringList(json["colors"]),
    sizes: _asStringList(json["sizes"]),
    images: List<String>.from((json["images"] ?? []).map((x) => x.toString())),
    createdAt: _asDate(json["createdAt"]),
    updatedAt: _asDate(json["updatedAt"]),
    userId: _asInt(json["userId"]),
    seller: Seller.fromJson(json["seller"] ?? const {}),
    isFavorite: json["isFavorite"] == true,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "title_ar": titleAr,
    "description_ar": descriptionAr,
    "price": price,
    "stock": stock,
    "lowStockAlert": lowStockAlert,
    "colors": colors,
    "sizes": sizes,
    "images": List<dynamic>.from(images.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "userId": userId,
    "seller": seller.toJson(),
    "isFavorite": isFavorite,
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

class PaginationProducts {
  int totalItems;
  int totalPages;
  int currentPage;

  PaginationProducts({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginationProducts.fromJson(Map<String, dynamic> json) =>
      PaginationProducts(
        totalItems: json["totalItems"],
        totalPages: json["totalPages"],
        currentPage: json["currentPage"],
      );

  Map<String, dynamic> toJson() => {
    "totalItems": totalItems,
    "totalPages": totalPages,
    "currentPage": currentPage,
  };
}
