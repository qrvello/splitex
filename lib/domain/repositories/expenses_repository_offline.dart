import 'package:repartapp/domain/models/expense_model.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/member_model.dart';
import 'package:repartapp/domain/models/transaction_model.dart';

abstract class ExpensesRepositoryOffline {
  Future<bool> addExpense(Group group, Expense expense);

  Future<bool> deleteExpense(Expense expense);

  List<Transaction> balanceDebts(List<Member> members);

  Future<bool> checkTransaction(Group group, Transaction transaction);
}
