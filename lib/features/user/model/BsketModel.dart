import 'dart:convert';

List<BsketModel> bsketModelFromJson(String str) =>
    List<BsketModel>.from(json.decode(str).map((x) => BsketModel.fromJson(x)));

String bsketModelToJson(List<BsketModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BsketModel {
  int id;
  int productId;
  int quantity;
  int originalQuantity;
  String? selectedColor;
  String? selectedSize;
  ProductBsket product;
  DateTime createdAt;
  DateTime updatedAt;

  BsketModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.originalQuantity,
    this.selectedColor,
    this.selectedSize,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BsketModel.fromJson(Map<String, dynamic> json) => BsketModel(
    id: json["id"],
    productId: json["productId"],
    quantity: json["quantity"],
    originalQuantity: json["quantity"],
    selectedColor: json["selectedColor"]?.toString(),
    selectedSize: json["selectedSize"]?.toString(),
    product: ProductBsket.fromJson(json["product"]),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "productId": productId,
    "quantity": quantity,
    "originalQuantity": quantity,
    "selectedColor": selectedColor,
    "selectedSize": selectedSize,
    "product": product.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}

class ProductBsket {
  int id;
  String title;
  int price;
  int stock;
  List<String> colors;
  List<String> sizes;
  List<String> images;

  ProductBsket({
    required this.id,
    required this.title,
    required this.price,
    required this.stock,
    required this.colors,
    required this.sizes,
    required this.images,
  });

  factory ProductBsket.fromJson(Map<String, dynamic> json) => ProductBsket(
    id: json["id"],
    title: json["title"],
    price: json["price"],
    stock: json["stock"] ?? 0,
    colors: List<String>.from((json["colors"] ?? []).map((x) => x.toString())),
    sizes: List<String>.from((json["sizes"] ?? []).map((x) => x.toString())),
    images: List<String>.from(json["images"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "stock": stock,
    "colors": colors,
    "sizes": sizes,
    "images": List<dynamic>.from(images.map((x) => x)),
  };
}
