import 'package:flutter/material.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/providers/groups_provider.dart';
import 'package:repartapp/styles/elevated_button_style.dart';

class AddExpensePage extends StatefulWidget {
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
                Text('Pagado por vos y dividido igualmente.'),
                SizedBox(height: 10),
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
        style: elevatedButtonStyle,
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
    return Container(
      height: 65,
      child: TextFormField(
        maxLength: 25,
        cursorColor: Color(0xff264653),
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          helperText: 'Ejemplo: almuerzo',
          labelText: 'Descripción del gasto',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        onSaved: (value) => expense.description = value,
        controller: _expenseNameController,
        validator: (value) {
          if (value.isEmpty) return 'Por favor ingresá una descripción';
          return null;
        },
      ),
    );
  }

  _inputAmount() {
    return Container(
      width: 250,
      height: 60,
      child: TextFormField(
        maxLength: 10,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.start,
        cursorColor: Color(0xff264653),
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.attach_money),
          labelText: 'Cantidad',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        controller: _expenseAmountController,
        onSaved: (value) => expense.amount = double.tryParse(value),
        validator: (value) {
          if (value.isEmpty) return 'Por favor ingresa un número';
          if (_isNumeric(value) != false) {
            return null;
          } else {
            return 'Por favor ingresa solo números.';
          }
        },
      ),
    );
  }

  _submit(context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();
    final GroupModel group = ModalRoute.of(context).settings.arguments;

    setState(() {
      _guardando = true;
    });

    final resp = await groupProvider.addExpense(group, expense);

    setState(() {
      _guardando = false;
    });

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
