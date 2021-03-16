class GroupModel {
  GroupModel(
      {this.id,
      this.name,
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
  Map members;
  Map expenses;

  factory GroupModel.fromJson(Map<dynamic, dynamic> json, key) => GroupModel(
        id: key,
        name: json["name"],
        adminUser: json["admin_user"],
        timestamp: json["timestamp"],
        members: json["members"],
        expenses: json["expenses"],
        invitedBy: json["invited_by"],
      );

  Map<dynamic, dynamic> toJson() => {
        "name": name,
        "admin_user": adminUser,
        "timestamp": timestamp,
        "members": members,
        "expenses": expenses,
        "invited_by": invitedBy,
      };
}
