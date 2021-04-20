import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:repartapp/domain/models/expense_model.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/member_model.dart';
import 'package:repartapp/domain/repositories/expenses_repository.dart';

class AddExpensePage extends StatefulWidget {
  final Group group;
  AddExpensePage({this.group});
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _expenseAmountController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final List<DropdownMenuItem<String>> items = [];

  Expense expense = new Expense();
  bool errorNotMatchTotalExpenditure = false;
  bool allCheckbox = true;
  String dropdownValue = '';
  List<Member> payingMembers = [];
  bool advanced = false;
  bool _saving = false;

  @override
  void initState() {
    payingMembers = List.from(widget.group.members);
    items.add(DropdownMenuItem(
      value: '',
      child: Text('Seleccioná'),
    ));

    // Crea los items para el dropdown con los miembros.

    for (Member member in widget.group.members) {
      member.controller =
          TextEditingController(text: member.amountToPay.toString());
      items.add(
        DropdownMenuItem(
          value: member.id,
          child: Text(member.id),
        ),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check_rounded),
        onPressed: () => _submit(context),
      ),
      appBar: AppBar(title: Text('Agregar gasto')),
      body: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  _inputDescription(),
                  SizedBox(height: 12),
                  _inputAmount(),
                  SizedBox(height: 16),
                  buildDropdownButton(),
                ],
              ),
            ),
            SizedBox(height: 10),
            CheckboxListTile(
              activeColor: Color(0xff0076ff),
              controlAffinity: ListTileControlAffinity.leading,
              checkColor: Colors.white,
              secondary: TextButton(
                child: (advanced == false) ? Text('Avanzado') : Text('Simple'),
                onPressed: () {
                  setState(() {
                    advanced = !advanced;
                    calculateDivision();
                  });
                },
              ),
              tileColor: Color(0xff1c1e20).withOpacity(0.3),
              value: allCheckbox,
              title: Text('Para quien'),
              onChanged: (value) {
                setState(() {
                  allCheckbox = value;

                  // Todos los miembros se ponen del valor que este sea
                  if (value == true) {
                    payingMembers = List.from(widget.group.members);
                  } else {
                    payingMembers = [];
                  }
                  widget.group.members.forEach((Member member) {
                    member.amountToPay = 0;
                    member.checked = value;
                  });
                });
                calculateDivision();
              },
            ),
            membersList(),
            SizedBox(height: context.height * 0.1)
          ],
        ),
      ),
    );
  }

  Container buildDropdownButton() {
    return Container(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: 'Pagado por'),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        isExpanded: true,
        value: dropdownValue,
        onChanged: (newValue) {
          setState(() {
            dropdownValue = newValue;
          });
        },
        onSaved: (value) => expense.paidBy = value,
        items: items,
        validator: (value) {
          if (value == '') {
            return 'Seleccione un miembro';
          }
          return null;
        },
      ),
    );
  }

  Expanded membersList() {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          height: 1,
        ),
        padding: EdgeInsets.only(bottom: context.height * 0.01),
        itemCount: widget.group.members.length,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: context.width * 0.5,
                child: CheckboxListTile(
                  activeColor: Color(0xff0076ff),
                  tileColor: Theme.of(context).scaffoldBackgroundColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  checkColor: Colors.white,
                  title: Text(widget.group.members[index].id),
                  value: widget.group.members[index].checked,
                  onChanged: (value) {
                    setState(() {
                      widget.group.members[index].checked = value;
                      if (value == true) {
                        payingMembers.add(widget.group.members[index]);
                      } else {
                        widget.group.members[index].amountToPay = 0;
                        widget.group.members[index].controller.text = '0';

                        payingMembers.remove(widget.group.members[index]);
                      }
                    });
                    calculateDivision();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 20),
                child: (advanced == false)
                    ? Text(widget.group.members[index].amountToPay.toString())
                    : advancedDivision(index),
              )
            ],
          );
        },
      ),
    );
  }

  Widget advancedDivision(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: context.width * 0.1,
          child: TextFormField(
            maxLength: 3,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (String value) {
              if (value == '') {
                widget.group.members[index].amountToPay = 0;
                widget.group.members[index].weight = 0;
              } else {
                int weight = int.tryParse(value);

                widget.group.members[index].weight = weight;
              }
              calculateDivision();
            },
            textAlign: TextAlign.center,
            initialValue: widget.group.members[index].weight.toString(),
            decoration: InputDecoration(
              isCollapsed: true,
              counterText: '',
              contentPadding: EdgeInsets.all(4),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff0076ff),
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff0076ff),
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff0076ff),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
        Container(
          width: context.width * 0.2,
          child: TextFormField(
            maxLength: 10,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
            ],
            onChanged: (String value) {
              if (value != '') {
                double amountToPay = double.tryParse(value);
                calculateDivisionForAmount(
                    amountToPay, widget.group.members[index]);
              }
            },
            controller: widget.group.members[index].controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isCollapsed: true,
              counterText: '',
              contentPadding: EdgeInsets.all(4),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff0076ff),
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff0076ff),
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xff0076ff),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextFormField _inputDescription() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLength: 25,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        helperText: 'Ejemplo: almuerzo',
        labelText: 'Descripción',
      ),
      onSaved: (value) => expense.description = value,
      controller: _expenseNameController,
      validator: (value) {
        if (value.trim().isEmpty) return 'Por favor ingresá una descripción';
        return null;
      },
    );
  }

  Widget _inputAmount() {
    return TextFormField(
      maxLength: 10,
      textAlign: TextAlign.end,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.attach_money),
        labelText: 'Cantidad',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
      ],
      onChanged: (value) {
        if (value != null) {
          expense.amount = double.tryParse(value).toDouble();
          calculateDivision();
        } else {
          expense.amount = 0;
          calculateDivision();
        }
      },
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: _expenseAmountController,
      validator: (value) {
        if (value.trim().isEmpty) return 'Por favor ingresa un número';
        if (_isNumeric(value.trim()) != false) {
          return null;
        } else {
          return 'Por favor ingresa solo números.';
        }
      },
    );
  }

  void _submit(BuildContext context) async {
    if (_saving == true) return;

    _saving = true;
    if (errorNotMatchTotalExpenditure == true) {
      snackbarError(
          'La división de gastos entre miembros no concuerda con el gasto total');
      _saving = false;

      return;
    }
    if (!formKey.currentState.validate()) {
      _saving = false;
      return;
    }

    formKey.currentState.save();

    bool resp = await RepositoryProvider.of<ExpensesRepository>(context)
        .addExpense(widget.group, expense);

    if (resp == true) {
      _saving = false;
      Get.back();
      snackbarSuccess();
    } else {
      _saving = false;
      snackbarError('Error al agregar gasto al grupo');
    }
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  void calculateDivision() {
    if (_expenseAmountController.text != '') {
      setState(() {
        // Si 'advanced' es true entonces hace un cálculo distinto
        if (advanced == true) {
          int weightTotal = 0;

          // Recorre todos los miembros que tienen que pagar y todo el peso
          // para obtener el peso total

          payingMembers.forEach((member) {
            weightTotal += member.weight;
          });

          // Si el peso total es distinto de null y 0 realiza el cálculo, sino
          // marca que todos tienen que pagar 0.
          if (weightTotal != null && weightTotal != 0) {
            // Se obtiene cuanto vale una unidad de peso diviendo la cantidad
            // a gastar por el total del peso

            double debtForWeight = expense.amount / weightTotal;

            // Se convierte a double y solo se queda con 2 decimales
            debtForWeight = double.parse(debtForWeight.toStringAsFixed(2));

            // Se asigna el valor que tienen que pagar a los miembros
            // multiplicando la unidad de peso por el peso que tiene el miembro
            payingMembers.forEach((member) {
              member.controller.text =
                  (debtForWeight * member.weight).toStringAsFixed(2);
              member.amountToPay = double.parse(
                  (debtForWeight * member.weight).toStringAsFixed(2));
            });

            errorNotMatchTotalExpenditure = false;
          } else {
            payingMembers.forEach((member) {
              member.amountToPay = 0;
            });
          }
        } else {
          // Se obtiene cuanto tiene que pagar cada miembro
          // diviendo la cantidad del gasto por la cantidad de miembros
          double debtForEach = expense.amount / payingMembers.length;

          // Se convierte a double y solo se queda con 2 decimales
          debtForEach = double.parse(debtForEach.toStringAsFixed(2));

          // Se asigna el valor que tienen que pagar a los miembros
          payingMembers.forEach((member) {
            member.amountToPay = debtForEach;
          });

          errorNotMatchTotalExpenditure = false;
        }
      });
    }
  }

  void calculateDivisionForAmount(double amountToPay, Member member) {
    member.amountToPay = double.tryParse(amountToPay.toStringAsFixed(2));

    double totalExpense = 0;

    widget.group.members.forEach((element) {
      totalExpense += element.amountToPay;
    });

    if (totalExpense.roundToDouble() != expense.amount.roundToDouble()) {
      errorNotMatchTotalExpenditure = true;
    } else {
      errorNotMatchTotalExpenditure = false;
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Gasto agregado satisfactoriamente',
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError(String message) {
    return Get.snackbar(
      'Error',
      message,
      icon: Icon(
        Icons.error_outline_rounded,
        color: Color(0xffee6c4d),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Color(0xffee6c4d).withOpacity(0.1),
    );
  }
}
