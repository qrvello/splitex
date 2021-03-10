import 'dart:convert';

//User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.email,
    this.name,
    this.id,
  });

  String email;
  String name;
  String id;

  factory User.fromJson(Map<dynamic, dynamic> json, key) => User(
        email: json["email"],
        name: json["name"],
        id: key,
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "id": id,
      };
}
