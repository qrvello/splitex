import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';

abstract class ExpensesRepositoryOffline {
  Future<void> addExpense(Group group, Expense expense);

  Future<bool> deleteExpense(Expense expense);

  List<Transaction> balanceDebts(List<Member> members);

  Future<void> checkTransaction(Group group, Transaction transaction);
}
