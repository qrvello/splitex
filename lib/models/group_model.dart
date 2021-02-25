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
    this.name,
    this.simplifyGroupDebts,
    this.adminUser,
  });

  String adminUser;
  String id;
  String name;
  bool simplifyGroupDebts;

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json["id"],
        name: json["name"],
        adminUser: json["admin_user"],
        simplifyGroupDebts: json["simplify_group_debts"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "simplify_group_debts": simplifyGroupDebts,
        "admin_user": adminUser
      };
}
