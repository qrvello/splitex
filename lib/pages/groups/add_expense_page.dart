import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repartapp/models/expense_model.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/member_model.dart';

import 'package:repartapp/providers/groups_provider.dart';

class AddExpensePage extends StatefulWidget {
  final Group group;
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
      appBar: AppBar(title: Text('Agregar gasto')),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              (error)
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20, top: 5),
                      child: Text(
                        'Error al agregar gasto',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
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
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        isExpanded: true,
                        value: dropdownValue,
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.white.withOpacity(0.87),
                          ),
                        ),
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofocus: true,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.attach_money),
        labelText: 'Cantidad',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: _expenseAmountController,
      onSaved: (value) => expense.amount = double.tryParse(value).toDouble(),
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

  void _submit(context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    bool resp = await groupProvider.addExpense(widget.group, expense);

    if (resp != false) {
      error = false;
      Navigator.pop(context);
    } else {
      setState(() {
        error = true;
      });
    }
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }
}
