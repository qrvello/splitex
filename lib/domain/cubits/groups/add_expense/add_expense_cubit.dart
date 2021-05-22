import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';

part 'add_expense_state.dart';

class AddExpenseCubit extends Cubit<AddExpenseState> {
  AddExpenseCubit(this._group, this.payingMembers) : super(AddExpenseInitial());

  final Group _group;

  final Expense expense = Expense();

  final List<Member> payingMembers;

  final List<DropdownMenuItem<String>> dropdownMenuItems = [];

  void init() {
    dropdownMenuItems.add(DropdownMenuItem(
      value: '',
      child: Text('Seleccioná'),
    ));

    // Crea los items para el dropdown con los miembros.

    for (Member member in _group.members) {
      member.controller =
          TextEditingController(text: member.amountToPay.toString());
      dropdownMenuItems.add(
        DropdownMenuItem(
          value: member.id,
          child: Text(member.id),
        ),
      );
    }

    emit(AddExpenseLoaded(dropdownMenuItems: dropdownMenuItems));
  }

  void setDropdownValue(String value) {
    expense.paidBy = value;
    emit(AddExpenseLoaded(dropdownValue: value));
  }

  //void calculateDivision() {
  //  if (_expenseAmountController.text != '') {
  //    setState(() {
  //      // Si 'advanced' es true entonces hace un cálculo distinto
  //      if (advanced == true) {
  //        int weightTotal = 0;

  //        // Recorre todos los miembros que tienen que pagar y todo el peso
  //        // para obtener el peso total

  //        payingMembers.forEach((member) {
  //          weightTotal += member.weight;
  //        });

  //        // Si el peso total es distinto de null y 0 realiza el cálculo, sino
  //        // marca que todos tienen que pagar 0.
  //        if (weightTotal != null && weightTotal != 0) {
  //          // Se obtiene cuanto vale una unidad de peso diviendo la cantidad
  //          // a gastar por el total del peso

  //          double debtForWeight = expense.amount / weightTotal;

  //          // Se convierte a double y solo se queda con 2 decimales
  //          debtForWeight = double.parse(debtForWeight.toStringAsFixed(2));

  //          // Se asigna el valor que tienen que pagar a los miembros
  //          // multiplicando la unidad de peso por el peso que tiene el miembro
  //          payingMembers.forEach((member) {
  //            member.controller.text =
  //                (debtForWeight * member.weight).toStringAsFixed(2);
  //            member.amountToPay = double.parse(
  //                (debtForWeight * member.weight).toStringAsFixed(2));
  //          });

  //          errorNotMatchTotalExpenditure = false;
  //        } else {
  //          payingMembers.forEach((member) {
  //            member.amountToPay = 0;
  //          });
  //        }
  //      } else {
  //        // Se obtiene cuanto tiene que pagar cada miembro
  //        // diviendo la cantidad del gasto por la cantidad de miembros
  //        double debtForEach = expense.amount / payingMembers.length;

  //        // Se convierte a double y solo se queda con 2 decimales
  //        debtForEach = double.parse(debtForEach.toStringAsFixed(2));

  //        // Se asigna el valor que tienen que pagar a los miembros
  //        payingMembers.forEach((member) {
  //          member.amountToPay = debtForEach;
  //        });

  //        errorNotMatchTotalExpenditure = false;
  //      }
  //    });
  //  }
  //}

  //void calculateDivisionForAmount(double amountToPay, Member member) {
  //  member.amountToPay = double.tryParse(amountToPay.toStringAsFixed(2));

  //  double totalExpense = 0;

  //  widget.group.members.forEach((element) {
  //    totalExpense += element.amountToPay;
  //  });

  //  if (totalExpense.roundToDouble() != expense.amount.roundToDouble()) {
  //    errorNotMatchTotalExpenditure = true;
  //  } else {
  //    errorNotMatchTotalExpenditure = false;
  //  }
  //}

}
