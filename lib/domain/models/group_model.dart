import 'package:hive/hive.dart';

import 'expense_model.dart';
import 'transaction_model.dart';
import 'member_model.dart';
import 'package:equatable/equatable.dart';

part 'group_model.g.dart';

@HiveType(typeId: 0)
// ignore: must_be_immutable
class Group extends Equatable {
  Group({
    this.id,
    this.name,
    this.newName,
    this.adminUser,
    this.timestamp,
    this.members,
    this.expenses,
    this.transactions,
    this.totalBalance = 0,
    this.link,
    this.users,
  });

  @HiveField(1)
  dynamic id;

  @HiveField(2)
  String? name;

  @HiveField(3)
  int? timestamp;

  @HiveField(4)
  num totalBalance;

  @HiveField(5)
  List<Member>? members;

  @HiveField(6)
  List<Expense>? expenses;

  @HiveField(7)
  List<Transaction>? transactions;

  String? newName;
  String? link;
  String? adminUser;
  Map<dynamic, dynamic>? users;

  factory Group.fromMap(Map<dynamic, dynamic> map, key) {
    final List<Member> members = [];
    final List<Expense> expenses = [];
    final List<Transaction> transactions = [];

    if (map['members'] != null) {
      final Map<dynamic, dynamic> membersMap = map['members'];

      membersMap.forEach((id, value) {
        final Member thisMember = Member.fromMap(value, id);
        members.add(thisMember);
      });
    }

    if (map['expenses'] != null) {
      final Map<dynamic, dynamic> expensesMap = map['expenses'];

      expensesMap.forEach((id, value) {
        final Expense thisExpense = Expense.fromMap(value, id);
        expenses.add(thisExpense);
      });
    }

    if (map['transactions'] != null) {
      final Map<dynamic, dynamic> transactionsMap = map['transactions'];

      transactionsMap.forEach((id, value) {
        final Transaction thisTransaction = Transaction.fromMap(value, id);
        transactions.add(thisTransaction);
      });
    }

    return Group(
      id: key,
      name: map["name"] as String?,
      adminUser: map["admin_user"] as String?,
      timestamp: map["timestamp"] as int?,
      members: members,
      expenses: expenses,
      transactions: transactions,
      users: map["users"] as Map<dynamic, dynamic>?,
      totalBalance: map["total_balance"] ?? 0,
      link: map['link'] as String?,
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

  @override
  List<Object?> get props => [
        name,
        members,
      ];
}
