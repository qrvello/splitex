import 'dart:io';

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
  Future<void> addExpense(Group group, Expense expense) async {
    if (await Utils.checkConnection() == false) {
      throw const SocketException('No hay internet');
    }

    // Se obtiene la referencia de la raiz del grupo al que se quiere agregar un gasto
    final DatabaseReference groupReference =
        databaseReference.child('groups/${group.id}');
    final DatabaseReference newChildExpenseReference =
        groupReference.child('expenses').push();

    final List<Member> members = group.members!;

    final Map<String, dynamic> updateObj = {};
    expense.distributedBetween = {};

    for (final Member member in members) {
      double? toPay = 0;

      // Si el miembro que se recorre actualmente es el que pagó el gasto
      // se suma el balance del miembro previo más lo que cuesta este gasto
      // menos lo que le corresponde pagar a este miembro.

      if (member.id == expense.paidBy?['id']) {
        toPay = -(expense.amount! - member.amountToPay!);
      } else if (member.amountToPay != null) {
        toPay = member.amountToPay;
      }

      // Si el balance actualizado es igual que el balance previo del miembro,
      // no se coloca en el update object.

      if (toPay != 0) {
        expense.distributedBetween![member.id!] = {
          'to_pay': toPay,
          'name': member.name,
        };

        updateObj['${groupReference.path}/members/${member.id}/'] = {
          "balance": member.balance - toPay!,
          "name": member.name
        };
      }
    }

    // Se crea el update object, un objeto que tiene los paths y los datos a colocar para realizar
    // solo una petición a la base de datos.

    updateObj['${groupReference.path}/total_balance'] =
        group.totalBalance! + expense.amount!;

    updateObj[newChildExpenseReference.path] = expense.toMap();

    try {
      await databaseReference.update(updateObj);
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<Transaction> balanceDebts(List<Member> members) {
    final List<Transaction> transactions = [];
    final List<Member> members2 = [];

    // Crea una nueva lista de miembros y copia la lista original para no modificar la original.

    for (final Member member in members) {
      final Member member2 = Member(
        id: member.id,
        balance: member.balance,
        name: member.name,
      );
      members2.add(member2);
    }

    final Iterable<Member> membersWithDebt =
        members2.where((member) => member.balance < 0);

    final Iterable<Member> membersWithPositiveBalance =
        members2.where((member) => member.balance > 0);

    for (final Member member1 in membersWithDebt) {
      for (final Member member2 in membersWithPositiveBalance) {
        if (member1.balance.abs() <= member2.balance) {
          final double toPay = member1.balance.abs();

          member1.balance += toPay;
          member2.balance -= toPay;

          final Transaction transaction = Transaction(
            amountToPay: toPay,
            memberToPay: member1,
            memberToReceive: member2,
          );

          transactions.add(transaction);

          break;
        }

        if (member1.balance.abs() >= member2.balance) {
          final double toPay = member2.balance;

          member1.balance += toPay;
          member2.balance -= toPay;

          final Transaction transaction = Transaction(
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

    final DatabaseReference groupReference =
        databaseReference.child('/groups/${group.id}');

    final String groupMembersPath = groupReference.child('members').path;

    final String newTransactionChildPath =
        groupReference.child('transactions').push().path;

    final Member memberToPay = group.members!
        .firstWhere((member) => member.id == transaction.memberToPay.id);

    final Member memberToReceive = group.members!
        .firstWhere((member) => member.id == transaction.memberToReceive.id);

    memberToPay.balance += transaction.amountToPay;
    memberToReceive.balance -= transaction.amountToPay;

    final Map<String, dynamic> updateObj = {
      '$groupMembersPath/${memberToPay.id}/balance': memberToPay.balance,
      '$groupMembersPath/${memberToReceive.id}/balance':
          memberToReceive.balance,
      newTransactionChildPath: transaction.toMap(),
    };

    print(updateObj);
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
