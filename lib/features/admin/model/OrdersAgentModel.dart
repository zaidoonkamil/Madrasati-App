import 'dart:convert';

OrdersAdminModel ordersAdminModelFromJson(String str) =>
    OrdersAdminModel.fromJson(json.decode(str));

String ordersAdminModelToJson(OrdersAdminModel data) =>
    json.encode(data.toJson());

class OrdersAdminModel {
  List<Order> orders;
  PaginationOrdersUser paginationOrdersUser;

  OrdersAdminModel({required this.orders, required this.paginationOrdersUser});

  factory OrdersAdminModel.fromJson(Map<String, dynamic> json) =>
      OrdersAdminModel(
        orders: List<Order>.from(
          ((json["orders"] as List?) ?? []).map((x) => Order.fromJson(x ?? {})),
        ),
        paginationOrdersUser: PaginationOrdersUser.fromJson(
          (json["paginationOrders"] as Map<String, dynamic>?) ?? {},
        ),
      );

  Map<String, dynamic> toJson() => {
    "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
    "paginationOrders": paginationOrdersUser.toJson(),
  };
}

class Order {
  int id;
  String phone;
  String secondaryPhone;
  String address;
  String deliveryType;
  String status;
  DateTime createdAt;
  int totalItems;
  int totalPrice;
  int discountAmount;
  String? couponCode;
  List<Item> items;

  Order({
    required this.id,
    required this.phone,
    required this.secondaryPhone,
    required this.address,
    required this.deliveryType,
    required this.status,
    required this.createdAt,
    required this.totalItems,
    required this.totalPrice,
    required this.discountAmount,
    this.couponCode,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"] ?? 0,
    phone: json["phone"]?.toString() ?? '',
    secondaryPhone: json["secondaryPhone"]?.toString() ?? '',
    address: json["address"]?.toString() ?? '',
    deliveryType: json["deliveryType"]?.toString() ?? 'standard',
    status: json["status"]?.toString() ?? '',
    createdAt:
        DateTime.tryParse(json["createdAt"]?.toString() ?? '') ??
        DateTime.now(),
    totalItems: json["totalItems"] ?? 0,
    totalPrice: json["totalPrice"] ?? 0,
    discountAmount: json["discountAmount"] ?? 0,
    couponCode: json["couponCode"]?.toString(),
    items: List<Item>.from(
      ((json["items"] as List?) ?? []).map((x) => Item.fromJson(x ?? {})),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "phone": phone,
    "secondaryPhone": secondaryPhone,
    "address": address,
    "deliveryType": deliveryType,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "totalItems": totalItems,
    "totalPrice": totalPrice,
    "discountAmount": discountAmount,
    "couponCode": couponCode,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  int id;
  int quantity;
  int priceAtOrder;
  String? selectedColor;
  String? selectedSize;
  ProductAgent productAgent;

  Item({
    required this.id,
    required this.quantity,
    required this.priceAtOrder,
    this.selectedColor,
    this.selectedSize,
    required this.productAgent,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    quantity: json["quantity"] ?? 0,
    priceAtOrder: json["priceAtOrder"] ?? 0,
    selectedColor: json["selectedColor"]?.toString(),
    selectedSize: json["selectedSize"]?.toString(),
    productAgent: ProductAgent.fromJson(
      (json["product"] as Map<String, dynamic>?) ?? {},
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "priceAtOrder": priceAtOrder,
    "selectedColor": selectedColor,
    "selectedSize": selectedSize,
    "product": productAgent.toJson(),
  };
}

class ProductAgent {
  int id;
  String title;
  int price;
  List<String> images;
  Seller seller;

  ProductAgent({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
    required this.seller,
  });

  factory ProductAgent.fromJson(Map<String, dynamic> json) => ProductAgent(
    id: json["id"] ?? 0,
    title: json["title"]?.toString() ?? '',
    price: json["price"] ?? 0,
    images: List<String>.from(
      ((json["images"] as List?) ?? []).map((x) => x.toString()),
    ),
    seller: Seller.fromJson((json["seller"] as Map<String, dynamic>?) ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "images": List<dynamic>.from(images.map((x) => x)),
    "seller": seller.toJson(),
  };
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

  factory Seller.fromJson(Map<String, dynamic> json) => Seller(
    id: json["id"] ?? 0,
    name: json["name"]?.toString() ?? '',
    phone: json["phone"]?.toString() ?? '',
    location: json["location"]?.toString() ?? '',
    role: json["role"]?.toString() ?? '',
    isVerified: json["isVerified"] ?? false,
    image: json["image"]?.toString() ?? '',
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

class PaginationOrdersUser {
  int currentPage;
  int totalPages;
  int totalItems;

  PaginationOrdersUser({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory PaginationOrdersUser.fromJson(Map<String, dynamic> json) =>
      PaginationOrdersUser(
        totalItems: json["totalItems"] ?? 0,
        totalPages: json["totalPages"] ?? 0,
        currentPage: json["currentPage"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalItems": totalItems,
  };
}
