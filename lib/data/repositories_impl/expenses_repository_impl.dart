import 'package:firebase_database/firebase_database.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/repositories/expenses_repository.dart';

import '../utils.dart';

class ExpensesRepositoryImpl extends ExpensesRepository {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  @override
  Future<bool> addExpense(Group group, Expense expense) async {
    if (await Utils.checkConnection() == false) return false;

    // Se obtiene la referencia de la raiz del grupo al que se quiere agregar un gasto
    final DatabaseReference groupReference =
        databaseReference.child('groups/${group.id}');
    final DatabaseReference newChildExpenseReference =
        groupReference.child('expenses').push();

    final List<Member> members = group.members!;

    Map<String, dynamic> updateObj = {};
    expense.distributedBetween = {};

    members.forEach((member) {
      double? toPay = 0;

      // Si el miembro que se recorre actualmente es el que pagó el gasto
      // se suma el balance del miembro previo más lo que cuesta este gasto
      // menos lo que le corresponde pagar a este miembro.

      if (member.id == expense.paidBy) {
        toPay = -(expense.amount! - member.amountToPay!);
      } else if (member.amountToPay != null) {
        toPay = member.amountToPay;
      }

      // Si el balance actualizado es igual que el balance previo del miembro,
      // no se coloca en el update object.

      if (toPay != 0) {
        expense.distributedBetween![member.id] = toPay;

        updateObj['${groupReference.path}/members/${member.id}/'] = {
          "balance": member.balance - toPay!,
          "name": member.name
        };
      }
    });

    // Se crea el update object, un objeto que tiene los paths y los datos a colocar para realizar
    // solo una petición a la base de datos.

    updateObj['${groupReference.path}/total_balance'] =
        group.totalBalance + expense.amount!;

    updateObj[newChildExpenseReference.path] = expense.toMap();

    try {
      await databaseReference.update(updateObj);
      return true;
    } catch (e) {
      print('Error al agregar gasto: ' + e.toString());
      return false;
    }
  }

  @override
  List<Transaction> balanceDebts(List<Member> members) {
    List<Transaction> transactions = [];
    List<Member> members2 = [];

    // Crea una nueva lista de miembros y copia la lista original para no modificar la original.

    for (Member member in members) {
      Member member2 = Member(
        id: member.id,
        balance: member.balance,
        name: member.name,
      );
      members2.add(member2);
    }

    Iterable<Member> membersWithDebt =
        members2.where((member) => member.balance < 0);

    Iterable<Member> membersWithPositiveBalance =
        members2.where((member) => member.balance > 0);

    for (Member member1 in membersWithDebt) {
      for (Member member2 in membersWithPositiveBalance) {
        if (member1.balance.abs() <= member2.balance) {
          double toPay = member1.balance.abs();

          member1.balance += toPay;
          member2.balance -= toPay;

          Transaction transaction = Transaction(
            amountToPay: toPay,
            memberToPay: member1,
            memberToReceive: member2,
          );

          transactions.add(transaction);

          break;
        }

        if (member1.balance.abs() > member2.balance) {
          double toPay = member2.balance;

          member1.balance += toPay;
          member2.balance -= toPay;

          Transaction transaction = Transaction(
            amountToPay: toPay,
            memberToPay: member1,
            memberToReceive: member2,
          );

          transactions.add(transaction);
        }
      }
    }

    return transactions;
  }

  @override
  Future<bool> checkTransaction(Group group, Transaction transaction) async {
    if (await Utils.checkConnection() == false) return false;

    DatabaseReference groupReference =
        databaseReference.child('/groups/${group.id}');

    String groupMembersPath = groupReference.child('/members').path;

    String newTransactionChildPath =
        groupReference.child('transactions').push().path;

    Member memberToPay = group.members!
        .firstWhere((member) => member.id == transaction.memberToPay.id);

    Member memberToReceive = group.members!
        .firstWhere((member) => member.id == transaction.memberToReceive.id);

    memberToPay.balance += transaction.amountToPay;
    memberToReceive.balance -= transaction.amountToPay;

    Map<String, dynamic> updateObj = {
      '$groupMembersPath/${memberToPay.id}/balance': memberToPay.balance,
      '$groupMembersPath/${memberToReceive.id}/balance':
          memberToReceive.balance,
      newTransactionChildPath: transaction.toMap(),
    };
    try {
      await databaseReference.update(updateObj);
      return true;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> deleteExpense(Expense expense) async {
    if (await Utils.checkConnection() == false) return false;
    return true;
  }
}
