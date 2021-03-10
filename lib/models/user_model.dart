import 'dart:convert';

import 'package:flutter/material.dart';

//User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.email,
    this.name,
    this.uid,
  });

  String email;
  String name;
  String uid;

  factory User.fromJson(Map<dynamic, dynamic> json, key) => User(
        email: json["email"],
        name: json["name"],
        uid: key,
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "uid": uid,
      };
}
