// To parse this JSON data, do
//
//     final groupModel = groupModelFromJson(jsonString);

import 'dart:convert';

GroupModel groupModelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));

String groupModelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  GroupModel({
    this.id,
    this.users,
    this.expenses,
    this.name,
    this.simplifyGroupDebts,
  });

  String id;
  Object users;
  Object expenses;
  String name;
  bool simplifyGroupDebts;

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json["id"],
        users: json["users"],
        expenses: json["expenses"],
        name: json["name"],
        simplifyGroupDebts: json["simplify_group_debts"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "users": users,
        "expenses": expenses,
        "name": name,
        "simplify_group_debts": simplifyGroupDebts,
      };
}
