import 'dart:convert';

GetNameUser getNameUserFromJson(String str) =>
    GetNameUser.fromJson(json.decode(str));

String getNameUserToJson(GetNameUser data) => json.encode(data.toJson());

class GetNameUser {
  Pagination pagination;
  List<User> users;

  GetNameUser({
    required this.pagination,
    required this.users,
  });

  factory GetNameUser.fromJson(Map<String, dynamic> json) => GetNameUser(
    pagination: Pagination.fromJson(json["pagination"]),
    users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "pagination": pagination.toJson(),
    "users": List<dynamic>.from(users.map((x) => x.toJson())),
  };
}

class Pagination {
  int totalUsers;
  int totalPages;
  int currentPage;
  int limit;

  Pagination({
    required this.totalUsers,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    totalUsers: json["totalUsers"],
    totalPages: json["totalPages"],
    currentPage: json["currentPage"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "totalUsers": totalUsers,
    "totalPages": totalPages,
    "currentPage": currentPage,
    "limit": limit,
  };
}

class User {
  int id;
  String? image;
  String name;
  String phone;
  String? location;
  String role;
  bool? isVerified;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    this.image,
    required this.name,
    required this.phone,
    this.location,
    required this.role,
    this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    image: json["image"],
    name: json["name"],
    phone: json["phone"],
    location: json["location"],
    role: json["role"],
    isVerified: json["isVerified"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "name": name,
    "phone": phone,
    "location": location,
    "role": role,
    "isVerified": isVerified,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
