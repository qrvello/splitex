import 'package:hive/hive.dart';

import 'expense_model.dart';
import 'transaction_model.dart';
import 'member_model.dart';

part 'group_model.g.dart';

@HiveType(typeId: 0)
class Group {
  Group({
    this.id,
    this.name,
    this.adminUser,
    this.timestamp,
    this.members,
    this.expenses,
    this.transactions,
    this.totalBalance,
    this.link,
    this.users,
  });

  @HiveField(1)
  String id;

  @HiveField(2)
  String name;

  @HiveField(3)
  int timestamp;

  @HiveField(4)
  num totalBalance;

  @HiveField(5)
  List<Member> members;

  @HiveField(6)
  List<Expense> expenses;

  @HiveField(7)
  List<Transaction> transactions;

  String link;
  String adminUser;
  Map<dynamic, dynamic> users;

  factory Group.fromMap(Map<dynamic, dynamic> map, key) {
    List<Member> members = [];
    List<Expense> expenses = [];
    List<Transaction> transactions = [];

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

    if (map['transactions'] != null) {
      Map<dynamic, dynamic> transactionsMap = map['transactions'];

      transactionsMap.forEach((id, value) {
        Transaction thisTransaction = Transaction.fromMap(value, id);
        transactions.add(thisTransaction);
      });
    }

    return Group(
      id: key,
      name: map["name"],
      adminUser: map["admin_user"],
      timestamp: map["timestamp"],
      members: members,
      expenses: expenses,
      transactions: transactions,
      users: map["users"],
      totalBalance: map["total_balance"],
      link: map['link'],
    );
  }

  Map<dynamic, dynamic> tomap() => {
        "name": name,
        "admin_user": adminUser,
        "timestamp": timestamp,
        "members": members,
        "expenses": expenses,
        "total_balance": totalBalance,
        "users": users,
        "transactions": transactions,
        "link": link
      };
}
