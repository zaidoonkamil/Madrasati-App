import 'dart:convert';

StatsModel statsModelFromJson(String str) => StatsModel.fromJson(json.decode(str));

String statsModelToJson(StatsModel data) => json.encode(data.toJson());

class StatsModel {
  Users users;
  Orders orders;
  Products products;

  StatsModel({
    required this.users,
    required this.orders,
    required this.products,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
        users: Users.fromJson((json["users"] as Map<String, dynamic>?) ?? {}),
        orders: Orders.fromJson((json["orders"] as Map<String, dynamic>?) ?? {}),
        products: Products.fromJson((json["products"] as Map<String, dynamic>?) ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "users": users.toJson(),
        "orders": orders.toJson(),
        "products": products.toJson(),
      };
}

class Orders {
  int total;
  Map<String, int> status;
  New ordersNew;
  Revenue revenue;

  Orders({
    required this.total,
    required this.status,
    required this.ordersNew,
    required this.revenue,
  });

  factory Orders.fromJson(Map<String, dynamic> json) => Orders(
        total: json["total"] ?? 0,
        status: ((json["status"] as Map?) ?? {}).map(
          (k, v) => MapEntry(k.toString(), _toInt(v)),
        ),
        ordersNew: New.fromJson((json["new"] as Map<String, dynamic>?) ?? {}),
        revenue: Revenue.fromJson((json["revenue"] as Map<String, dynamic>?) ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "status": Map.from(status).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "new": ordersNew.toJson(),
        "revenue": revenue.toJson(),
      };
}

class New {
  int today;
  int thisWeek;
  int thisMonth;

  New({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory New.fromJson(Map<String, dynamic> json) => New(
        today: _toInt(json["today"]),
        thisWeek: _toInt(json["thisWeek"]),
        thisMonth: _toInt(json["thisMonth"]),
      );

  Map<String, dynamic> toJson() => {
        "today": today,
        "thisWeek": thisWeek,
        "thisMonth": thisMonth,
      };
}

class Revenue {
  int total;

  Revenue({
    required this.total,
  });

  factory Revenue.fromJson(Map<String, dynamic> json) => Revenue(
        total: _toInt(json["total"]),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
      };
}

class Products {
  int total;
  New productsNew;
  List<ByCategory> byCategory;
  List<TopSeller> topSellers;

  Products({
    required this.total,
    required this.productsNew,
    required this.byCategory,
    required this.topSellers,
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
        total: _toInt(json["total"]),
        productsNew: New.fromJson((json["new"] as Map<String, dynamic>?) ?? {}),
        byCategory: List<ByCategory>.from(
          ((json["byCategory"] as List?) ?? []).map((x) => ByCategory.fromJson((x as Map?)?.cast<String, dynamic>() ?? {})),
        ),
        topSellers: List<TopSeller>.from(
          ((json["topSellers"] as List?) ?? []).map((x) => TopSeller.fromJson((x as Map?)?.cast<String, dynamic>() ?? {})),
        ),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "new": productsNew.toJson(),
        "byCategory": List<dynamic>.from(byCategory.map((x) => x.toJson())),
        "topSellers": List<dynamic>.from(topSellers.map((x) => x.toJson())),
      };
}

class ByCategory {
  int categoryId;
  int count;

  ByCategory({
    required this.categoryId,
    required this.count,
  });

  factory ByCategory.fromJson(Map<String, dynamic> json) => ByCategory(
        categoryId: _toInt(json["categoryId"]),
        count: _toInt(json["count"]),
      );

  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "count": count,
      };
}

class TopSeller {
  int userId;
  int count;

  TopSeller({
    required this.userId,
    required this.count,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) => TopSeller(
        userId: _toInt(json["userId"]),
        count: _toInt(json["count"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "count": count,
      };
}

class Users {
  int total;
  int verified;
  Roles roles;
  New usersNew;

  Users({
    required this.total,
    required this.verified,
    required this.roles,
    required this.usersNew,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        total: _toInt(json["total"]),
        verified: _toInt(json["verified"]),
        roles: Roles.fromJson((json["roles"] as Map<String, dynamic>?) ?? {}),
        usersNew: New.fromJson((json["new"] as Map<String, dynamic>?) ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "verified": verified,
        "roles": roles.toJson(),
        "new": usersNew.toJson(),
      };
}

class Roles {
  int admin;
  int user;

  Roles({
    required this.admin,
    required this.user,
  });

  factory Roles.fromJson(Map<String, dynamic> json) => Roles(
        admin: _toInt(json["admin"]),
        user: _toInt(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "admin": admin,
        "user": user,
      };
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
