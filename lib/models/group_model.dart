// To parse this JSON data, do
//
//     final groupModel = groupModelFromJson(jsonString);

import 'dart:convert';

GroupModel groupModelFromJson(String str) =>
    GroupModel.fromJson(json.decode(str));

String groupModelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  GroupModel(
      {this.id,
      this.name,
      this.simplifyGroupDebts,
      this.adminUser,
      this.timestamp,
      this.members});

  String adminUser;
  String id;
  String name;
  int timestamp;
  bool simplifyGroupDebts;
  Object members;

  factory GroupModel.fromJson(Map<dynamic, dynamic> json) => GroupModel(
        id: json["id"],
        name: json["name"],
        adminUser: json["admin_user"],
        simplifyGroupDebts: json["simplify_group_debts"],
        timestamp: json["timestamp"],
        members: json["members"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "simplify_group_debts": simplifyGroupDebts,
        "admin_user": adminUser,
        "timestamp": timestamp,
      };
}
