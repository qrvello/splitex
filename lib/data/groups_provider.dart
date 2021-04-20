//import 'package:firebase_database/firebase_database.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:repartapp/domain/models/expense_model.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/member_model.dart';
import 'package:repartapp/domain/models/transaction_model.dart';

class GroupsProvider extends GetxController {
  final user = FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseDatabase.instance.reference();

  Future<bool> addExpense(Group group, Expense expense) async {
    if (await _checkConnection() == false) {
      return false;
    }

    final DatabaseReference groupReference =
        databaseReference.child('groups/${group.id}');

    final DatabaseReference newChildExpenseReference =
        groupReference.child('expenses').push();

    final List<Member> members = group.members;

    final int countMembers = members.length;

    Map<String, dynamic> updateObj = {
      '${groupReference.path}/total_balance':
          group.totalBalance + expense.amount,
      newChildExpenseReference.path: expense.toMap(),
    };

    // Solo usa 2 decimales
    double debtForEach = (expense.amount / countMembers);

    debtForEach = double.parse(debtForEach.toStringAsFixed(2));
    members.forEach((member) {
      if (member.amountToPay != 0) {
        double updatedBalance = 0;

        if (member.id == expense.paidBy) {
          updatedBalance = member.balance + expense.amount - member.amountToPay;
        } else {
          updatedBalance = member.balance - member.amountToPay;
        }

        updateObj.putIfAbsent(
          '${groupReference.path}/members/${member.id}/',
          () => {"balance": updatedBalance},
        );
      }
    });

    await databaseReference.update(updateObj).catchError((error) {
      print("Error al agregar gasto: ${error.message}");
      return false;
    });

    return true;
  }

  Future<bool> deleteExpense(Group group, Expense expense) async {
    if (await _checkConnection() == false) {
      return false;
    }

    // ignore: todo
    // TODO restar balance que se habia agregado previamente con el gasto

    await databaseReference
        .child('groups/${group.id}/expenses/${expense.id}')
        .remove()
        .catchError((onError) {
      print('Error al borrar expensa ${onError.message}');
      return false;
    });

    return true;
  }

  List<Transaction> balanceDebts(List<Member> members2) {
    List<Transaction> transactions = [];
    List<Member> members = [];

    // Crea una nueva lista de miembros y copia la lista original para no modificar la original.

    for (Member member in members2) {
      Member member2 = Member();
      member2.id = member.id;
      member2.balance = member.balance;
      members.add(member2);
    }

    Iterable<Member> membersWithDebt =
        members.where((member) => member.balance < 0);

    Iterable<Member> membersWithPositiveBalance =
        members.where((member) => member.balance > 0);

    for (Member member1 in membersWithDebt) {
      for (Member member2 in membersWithPositiveBalance) {
        if (member1.balance.abs() <= member2.balance) {
          double toPay = member1.balance.abs();

          member1.balance += toPay;
          member2.balance -= toPay;

          Transaction transaction = Transaction();

          transaction.amountToPay = toPay;
          transaction.memberToPay = member1;
          transaction.memberToReceive = member2;

          transactions.add(transaction);

          break;
        }

        if (member1.balance.abs() > member2.balance) {
          double toPay = member2.balance;

          member1.balance += toPay;
          member2.balance -= toPay;

          Transaction transaction = Transaction();

          transaction.amountToPay = toPay;
          transaction.memberToPay = member1;
          transaction.memberToReceive = member2;

          transactions.add(transaction);
        }
      }
    }

    return transactions;
  }

  Future<bool> checkTransaction(Transaction transaction, Group group) async {
    if (await _checkConnection() == false) {
      return false;
    }

    DatabaseReference groupReference =
        databaseReference.child('/groups/${group.id}');

    String groupMembersPath = groupReference.child('/members').path;

    String newTransactionChildPath =
        groupReference.child('transactions').push().path;

    Member memberToPay = group.members
        .firstWhere((member) => member.id == transaction.memberToPay.id);

    Member memberToReceive = group.members
        .firstWhere((member) => member.id == transaction.memberToReceive.id);

    memberToPay.balance += transaction.amountToPay;
    memberToReceive.balance -= transaction.amountToPay;

    Map<String, dynamic> updateObj = {
      '$groupMembersPath/${memberToPay.id}/balance': memberToPay.balance,
      '$groupMembersPath/${memberToReceive.id}/balance':
          memberToReceive.balance,
      newTransactionChildPath: transaction.toMap(),
    };

    await databaseReference.update(updateObj).catchError((onError) {
      print('Error al chequear transacción: ${onError.message}');
      return false;
    });

    return true;
  }

  Future<bool> deleteMember(Group group, Member member) async {
    if (await _checkConnection() == false) {
      return false;
    }

    await databaseReference
        .child('/groups/${group.id}/members/${member.id}')
        .remove();
    return true;
  }

  Future<bool> _checkConnection() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }
}
