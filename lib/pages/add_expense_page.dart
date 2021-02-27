import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';
import 'package:gastos_grupales/providers/groups_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AddExpensePage extends StatefulWidget {
  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final groupProvider = new GroupsProvider();

  final _expenseNameController = new TextEditingController();

  bool _guardando = false;

  @override
  Widget build(BuildContext context) {
    final GroupModel group = ModalRoute.of(context).settings.arguments;

    final formKey = GlobalKey<FormState>();

    final scaffoldKey = GlobalKey<ScaffoldState>();

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
                _inputCreateName(),
                SizedBox(
                  height: 12,
                ),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.workSans(
                        textStyle: TextStyle(color: Colors.black54)),
                    text: 'Nota: ',
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              'se podrán agregar miembros después de crear el grupo.',
                          style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
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
      child: RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        color: Color(0xff2a9d8f),
        child: Text(
          'Guardar',
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

  Widget _inputCreateName() {
    return Container(
      height: 65,
      child: TextFormField(
        maxLength: 25,
        cursorColor: Color(0xff264653),
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          helperText: 'Ejemplo: Vacaciones a la costa',
          labelText: 'Nombre del grupo',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        controller: _expenseNameController,
      ),
    );
  }

  _submit(context) async {
    setState(() {
      _guardando = true;
    });

    setState(() {
      _guardando = false;
    });
  }
}
