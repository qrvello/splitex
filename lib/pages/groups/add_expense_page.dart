import 'package:flutter/material.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/member_model.dart';

import 'package:repartapp/providers/groups_provider.dart';

class AddExpensePage extends StatefulWidget {
  final GroupModel group;
  AddExpensePage({this.group});
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final groupProvider = new GroupsProvider();

  final _expenseNameController = new TextEditingController();
  final _expenseAmountController = new TextEditingController();

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Expense expense = new Expense();
  bool _guardando = false;
  bool error = false;
  String dropdownValue = '';

  @override
  void dispose() {
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(
        value: '',
        child: Text('Seleccioná'),
      ),
    ];

    // Crea los items para el dropdown con los miembros.

    for (Member member in widget.group.members) {
      items.add(
        DropdownMenuItem(
          value: member.id,
          child: Text(member.id),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Agregar gasto'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                _inputDescription(),
                SizedBox(height: 10),
                _inputAmount(),
                SizedBox(height: 12),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Pagado por'),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.only(top: 5),
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 80,
                        child: DropdownButtonFormField<String>(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          isExpanded: true,
                          value: dropdownValue,
                          style: TextStyle(color: Color(0xffEDF6F9)),
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
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  child: Text('Dividido de forma igualitaria'),
                ),
                SizedBox(height: 16),
                _button(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(context) {
    return Container(
      width: 120,
      child: ElevatedButton(
        child: Text(
          'Agregar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: (_guardando)
            ? null
            : () {
                _submit(context);
              },
      ),
    );
  }

  Widget _inputDescription() {
    return TextFormField(
      autofocus: true,
      maxLength: 25,
      cursorColor: Color(0xff264653),
      style: TextStyle(fontSize: 19),
      decoration: InputDecoration(
        helperText: 'Ejemplo: almuerzo',
        labelText: 'Descripción del gasto',
      ),
      onSaved: (value) => expense.description = value,
      controller: _expenseNameController,
      validator: (value) {
        if (value.isEmpty) return 'Por favor ingresá una descripción';
        return null;
      },
    );
  }

  Widget _inputAmount() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 19),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(Icons.attach_money),
        labelText: 'Cantidad',
      ),
      controller: _expenseAmountController,
      onSaved: (value) => expense.amount = double.tryParse(value).toDouble(),
      validator: (value) {
        if (value.isEmpty) return 'Por favor ingresa un número';
        if (_isNumeric(value) != false) {
          return null;
        } else {
          return 'Por favor ingresa solo números.';
        }
      },
    );
  }

  _submit(context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    //final DetailsGroupPage args = ModalRoute.of(context).settings.arguments;

    //GroupModel group = args.group;

    //group.members = args.members.asMap();

    final resp = await groupProvider.addExpense(widget.group, expense);

    if (resp != false) {
      error = false;
      Navigator.pop(context);
    }
    setState(() {
      error = true;
    });
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
