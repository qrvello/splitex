import 'dart:convert';

String groupModelToJson(GroupModel data) => json.encode(data.toJson());

class GroupModel {
  GroupModel(
      {this.id,
      this.name,
      this.simplifyGroupDebts,
      this.adminUser,
      this.timestamp,
      this.invitedBy,
      this.members,
      this.expenses});

  String adminUser;
  String id;
  String name;
  String invitedBy;
  int timestamp;
  bool simplifyGroupDebts;
  Object members;
  Object expenses;

  factory GroupModel.fromJson(Map<dynamic, dynamic> json, key) => GroupModel(
        id: key,
        name: json["name"],
        adminUser: json["admin_user"],
        simplifyGroupDebts: json["simplify_group_debts"],
        timestamp: json["timestamp"],
        members: json["members"],
        expenses: json["expenses"],
        invitedBy: json["invited_by"],
      );

  Map<dynamic, dynamic> toJson() => {
        "name": name,
        "simplify_group_debts": simplifyGroupDebts,
        "admin_user": adminUser,
        "timestamp": timestamp,
        "members": members,
        "expenses": expenses,
        "invited_by": invitedBy,
      };
}
