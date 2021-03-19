import 'package:repartapp/models/expense.dart';

import 'member_model.dart';

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
  List<Member> members;
  List<Expense> expenses;

  factory GroupModel.fromMap(Map<dynamic, dynamic> map, key) {
    List<Member> members = [];
    List<Expense> expenses = [];

    if (map['members'] != null) {
      Map<dynamic, dynamic> membersMap = map['members'];

      membersMap.forEach((id, value) {
        Member thisMember = Member.fromMap(value, id);
        members.add(thisMember);
      });
    }

    if (map['expenses'] != null) {
      Map<dynamic, dynamic> expensesMap = map['expenses'];

      expensesMap.forEach((id, value) {
        Expense thisExpense = Expense.fromMap(value, id);
        expenses.add(thisExpense);
      });
    }

    return GroupModel(
      id: key,
      name: map["name"],
      adminUser: map["admin_user"],
      timestamp: map["timestamp"],
      members: members,
      expenses: expenses,
      invitedBy: map["invited_by"],
    );
  }

  Map<dynamic, dynamic> tomap() => {
        "name": name,
        "admin_user": adminUser,
        "timestamp": timestamp,
        "members": members,
        "expenses": expenses,
        "invited_by": invitedBy,
      };
}
