import 'package:firebase_database/firebase_database.dart';
import 'package:repartapp/domain/models/transaction_model.dart';
import 'package:repartapp/domain/models/member_model.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/expense_model.dart';
import 'package:repartapp/domain/repositories/expenses_repository.dart';

class ExpensesRepositoryImpl extends ExpensesRepository {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  @override
  Future<bool> addExpense(Group group, Expense expense) async {
    // Se obtiene la referencia de la raiz del grupo al que se quiere agregar un gasto
    final DatabaseReference groupReference =
        databaseReference.child('groups/${group.id}');

    final DatabaseReference newChildExpenseReference =
        groupReference.child('expenses').push();

    final List<Member> members = group.members;

    // Se crea el update object, un objeto que tiene los paths y los datos a colocar para realizar
    // solo una petición a la base de datos.

    Map<String, dynamic> updateObj = {
      '${groupReference.path}/total_balance':
          group.totalBalance + expense.amount,
      newChildExpenseReference.path: expense.toMap(),
    };

    members.forEach((member) {
      double updatedBalance = 0;

      // Si el miembro que se recorre actualmente es el que pagó el gasto
      // se suma el balance del miembro previo más lo que cuesta este gasto
      // menos lo que le corresponde pagar a este miembro.

      if (member.id == expense.paidBy) {
        updatedBalance = member.balance + expense.amount - member.amountToPay;
      } else if (member.amountToPay != null) {
        updatedBalance = member.balance - member.amountToPay;
      }

      // Si el balance actualizado es igual que el balance del miembro, no se coloca en el update object.
      if (updatedBalance != member.balance) {
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

  @override
  List<Transaction> balanceDebts(List<Member> members) {
    List<Transaction> transactions = [];
    List<Member> members2 = [];

    // Crea una nueva lista de miembros y copia la lista original para no modificar la original.

    for (Member member in members) {
      Member member2 = Member();
      member2.id = member.id;
      member2.balance = member.balance;
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

  @override
  Future<bool> deleteExpense(Expense expense) {
    // TODO: implement deleteExpense
    throw UnimplementedError();
  }
}
