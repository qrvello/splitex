import 'package:repartapp/models/expense_model.dart';
import 'package:repartapp/models/transaction_model.dart';

import 'member_model.dart';

class Group {
  Group({
    this.id,
    this.name,
    this.adminUser,
    this.timestamp,
    this.invitedBy,
    this.members,
    this.expenses,
    this.transactions,
    this.totalBalance,
    this.link,
  });

  String adminUser;
  String id;
  String name;
  String invitedBy;
  String link;
  int timestamp;
  double totalBalance;
  List<Member> members;
  List<Expense> expenses;
  List<Transaction> transactions;

  factory Group.fromMap(Map<dynamic, dynamic> map, key) {
    List<Member> members = [];
    List<Expense> expenses = [];
    List<Transaction> transactions = [];
    double totalBalance = 0;

    if (map['total_balance'] != null) {
      totalBalance = map["total_balance"].toDouble();
    }
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
      invitedBy: map["invited_by"],
      totalBalance: totalBalance,
      link: map['link'],
    );
  }

  Map<dynamic, dynamic> tomap() => {
        "name": name,
        "admin_user": adminUser,
        "timestamp": timestamp,
        "members": members,
        "expenses": expenses,
        "invited_by": invitedBy,
        "total_balance": totalBalance,
        "transactions": transactions,
        "link": link
      };
}
