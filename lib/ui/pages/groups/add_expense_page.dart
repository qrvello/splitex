import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/repositories/expenses_repository.dart';
import 'package:splitex/domain/repositories/expenses_repository_offline.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final Group group = Get.arguments['group'] as Group;
  final bool online = Get.arguments['online'] as bool;
  final TextEditingController _expenseNameController = TextEditingController();

  final TextEditingController _expenseAmountController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final List<DropdownMenuItem<String>> items = [];

  Expense expense = Expense();
  bool errorNotMatchTotalExpenditure = false;
  bool? allCheckbox = true;
  String? dropdownValue = '';
  List<Member> payingMembers = [];
  bool advanced = false;
  bool _saving = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    payingMembers = List.from(group.members!);
    items.add(const DropdownMenuItem(
      value: '',
      child: Text('Seleccioná'),
    ));

    // Crea los items para el dropdown con los miembros.

    for (final Member member in group.members!) {
      member.controller =
          TextEditingController(text: member.amountToPay.toString());
      items.add(
        DropdownMenuItem(
          value: member.id,
          child: Text(member.name!),
        ),
      );
    }
    expense.timestamp = selectedDate.millisecondsSinceEpoch;
    super.initState();
  }

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      });

      expense.timestamp = selectedDate.millisecondsSinceEpoch;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfday = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (timeOfday != null) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          timeOfday.hour,
          timeOfday.minute,
        );
      });

      expense.timestamp = selectedDate.millisecondsSinceEpoch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _submit(context),
        child: _saving
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(Icons.check_rounded),
      ),
      appBar: AppBar(title: const Text('Agregar gasto')),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _inputDescription(),
                    const SizedBox(height: 12),
                    _inputAmount(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                            DateFormat.yMMMd().format(
                              DateTime.fromMillisecondsSinceEpoch(
                                selectedDate.millisecondsSinceEpoch,
                              ),
                            ),
                          ),
                        ),
                        const Text("-"),
                        TextButton(
                          onPressed: () => _selectTime(context),
                          child: Text(
                            DateFormat('k:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                selectedDate.millisecondsSinceEpoch,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    buildDropdownButton(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                activeColor: const Color(0xff0076ff),
                controlAffinity: ListTileControlAffinity.leading,
                checkColor: Colors.white,
                secondary: TextButton(
                  onPressed: () {
                    setState(() {
                      advanced = !advanced;
                      calculateDivision();
                    });
                  },
                  child: (advanced == false)
                      ? const Text('Avanzado')
                      : const Text('Simple'),
                ),
                tileColor: const Color(0xff1c1e20).withOpacity(0.3),
                value: allCheckbox,
                title: const Text('Entre quien se divide'),
                onChanged: (value) {
                  setState(() {
                    allCheckbox = value;

                    // Todos los miembros se ponen del valor que este sea
                    if (value == true) {
                      payingMembers = List.from(group.members!);
                    } else {
                      payingMembers = [];
                    }
                    for (final Member member in group.members!) {
                      member.amountToPay = 0;
                      member.checked = value;
                    }
                  });
                  calculateDivision();
                },
              ),
              membersList(),
              SizedBox(height: context.height * 0.1)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdownButton() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Pagado por'),
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
    );
  }

  Widget membersList() {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (_, __) => const Divider(height: 2),
      padding: EdgeInsets.only(bottom: context.height * 0.1),
      itemCount: group.members!.length,
      itemBuilder: (context, index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: context.width * 0.5,
              child: CheckboxListTile(
                activeColor: const Color(0xff0076ff),
                tileColor: Theme.of(context).scaffoldBackgroundColor,
                controlAffinity: ListTileControlAffinity.leading,
                checkColor: Colors.white,
                title: Text(group.members![index].name!),
                value: group.members![index].checked,
                onChanged: (value) {
                  setState(() {
                    group.members![index].checked = value;
                    if (value == true) {
                      payingMembers.add(group.members![index]);
                    } else {
                      group.members![index].amountToPay = 0;
                      group.members![index].controller!.text = '0';

                      payingMembers.remove(group.members![index]);
                    }
                  });
                  calculateDivision();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: (advanced == false)
                  ? Text(group.members![index].amountToPay.toString())
                  : advancedDivision(index),
            )
          ],
        );
      },
    );
  }

  Widget advancedDivision(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: context.width * 0.1,
          child: TextFormField(
            maxLength: 3,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (String value) {
              if (value == '') {
                group.members![index].amountToPay = 0;
                group.members![index].weight = 0;
              } else {
                final int? weight = int.tryParse(value);

                group.members![index].weight = weight;
              }
              calculateDivision();
            },
            textAlign: TextAlign.center,
            initialValue: group.members![index].weight.toString(),
            decoration: const InputDecoration(
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
        const SizedBox(width: 15),
        SizedBox(
          width: context.width * 0.2,
          child: TextFormField(
            maxLength: 10,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
            ],
            onChanged: (String value) {
              if (value != '') {
                final double amountToPay = double.tryParse(value)!;
                calculateDivisionForAmount(amountToPay, group.members![index]);
              } else {}
            },
            controller: group.members![index].controller,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
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
      style: const TextStyle(fontSize: 20),
      decoration: const InputDecoration(
        labelText: 'Descripción',
        counterText: '',
      ),
      onSaved: (value) => expense.description = value,
      controller: _expenseNameController,
      validator: (value) {
        if (value!.trim().isEmpty) return 'Por favor ingresá una descripción';
      },
    );
  }

  Widget _inputAmount() {
    return TextFormField(
      maxLength: 10,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 20),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.attach_money),
        prefixIconConstraints: BoxConstraints(
          minWidth: 36,
        ),
        labelText: 'Monto',
        counterText: '',
        contentPadding: EdgeInsets.zero,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
      ],
      onChanged: (String? value) {
        if (value != null) {
          expense.amount = double.parse(value);
          calculateDivision();
        } else {
          expense.amount = 0;
          calculateDivision();
        }
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: _expenseAmountController,
      validator: (value) {
        if (value!.trim().isEmpty) return 'Por favor ingresa un número';
        if (_isNumeric(value.trim()) != false) {
          return null;
        } else {
          return 'Por favor ingresa solo números.';
        }
      },
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_saving == true) return;

    setState(() {
      _saving = true;
    });

    if (errorNotMatchTotalExpenditure == true) {
      snackbarError(
          'La división de gastos entre miembros no concuerda con el gasto total');

      setState(() {
        _saving = false;
      });

      return;
    }

    if (!formKey.currentState!.validate()) {
      setState(() {
        _saving = false;
      });

      return;
    }

    formKey.currentState!.save();

    try {
      if (online) {
        await RepositoryProvider.of<ExpensesRepository>(context)
            .addExpense(group, expense);
      } else {
        RepositoryProvider.of<ExpensesRepositoryOffline>(context)
            .addExpense(group, expense);
      }

      setState(() {
        _saving = false;
      });

      Get.back();

      snackbarSuccess();
    } catch (e) {
      setState(() {
        _saving = false;
      });
      snackbarError('Error al agregar gasto al grupo: ${e.toString()}');
    }
  }

  bool _isNumeric(String? str) {
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
          for (final Member member in payingMembers) {
            weightTotal += member.weight!;
          }

          // Si el peso total es distinto de null y 0 realiza el cálculo, sino
          // marca que todos tienen que pagar 0.
          if (weightTotal != 0) {
            // Se obtiene cuanto vale una unidad de peso diviendo la cantidad
            // a gastar por el total del peso

            double debtForWeight = expense.amount! / weightTotal;

            // Se convierte a double y solo se queda con 2 decimales
            debtForWeight = double.parse(debtForWeight.toStringAsFixed(2));

            // Se asigna el valor que tienen que pagar a los miembros
            // multiplicando la unidad de peso por el peso que tiene el miembro
            for (final Member member in payingMembers) {
              member.controller!.text =
                  (debtForWeight * member.weight!).toStringAsFixed(2);
              member.amountToPay = double.parse(
                  (debtForWeight * member.weight!).toStringAsFixed(2));
            }

            errorNotMatchTotalExpenditure = false;
          } else {
            for (final Member member in payingMembers) {
              member.amountToPay = 0;
            }
          }
        } else {
          // Se obtiene cuanto tiene que pagar cada miembro
          // diviendo la cantidad del gasto por la cantidad de miembros
          double debtForEach = expense.amount! / payingMembers.length;

          // Se convierte a double y solo se queda con 2 decimales
          debtForEach = double.parse(debtForEach.toStringAsFixed(2));

          // Se asigna el valor que tienen que pagar a los miembros
          for (final Member member in payingMembers) {
            member.amountToPay = debtForEach;
          }

          errorNotMatchTotalExpenditure = false;
        }
      });
    }
  }

  void calculateDivisionForAmount(double amountToPay, Member member) {
    member.amountToPay = double.tryParse(amountToPay.toStringAsFixed(2));

    double totalExpense = 0;

    // Obtiene el gasto total sumando lo que tienen que pagar todos los miembros
    for (final Member member in group.members!) {
      totalExpense += member.amountToPay!;
    }

    if (totalExpense.roundToDouble() != expense.amount!.roundToDouble()) {
      errorNotMatchTotalExpenditure = true;
    } else {
      errorNotMatchTotalExpenditure = false;
    }
  }

  void snackbarSuccess() {
    Get.snackbar(
      'Acción exitosa',
      'Gasto agregado satisfactoriamente',
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError(String message) {
    Get.snackbar(
      'Error',
      message,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Color(0xffee6c4d),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: const Color(0xffee6c4d).withOpacity(0.1),
    );
  }
}
