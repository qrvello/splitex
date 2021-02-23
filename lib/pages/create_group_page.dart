import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';
import 'package:gastos_grupales/provider/groups_provider.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final groupProvider = new GroupsProvider();
  GroupModel group = new GroupModel();
  bool isSwitched = false;
  bool _guardando = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              _inputCreateName(),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Simplificar las deudas grupales'),
                  _switch(),
                ],
              ),
              _helpSwitch(),
              _button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button() {
    return CupertinoButton.filled(
      child: Text('Guardar'),
      onPressed: (_guardando) ? null : _submit,
    );
  }

  Widget _inputCreateName() {
    return TextFormField(
      decoration: InputDecoration(
        fillColor: Colors.white,
        labelText: 'Nombre del grupo',
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.circular(25.0),
          borderSide: new BorderSide(),
        ),
      ),
      onSaved: (value) => group.name = value,
      validator: (value) {
        if (value.length < 1) {
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }

  Widget _switch() {
    return CupertinoSwitch(
      value: isSwitched,
      onChanged: (value) {
        setState(() {
          isSwitched = value;
        });
      },
    );
  }

  void _submit() async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    setState(() {
      _guardando = true;
    });

    group.simplifyGroupDebts = isSwitched;

    groupProvider.createGroup(group);

    // Upload image

    setState(() {
      _guardando = false;
    });

    Navigator.pop(context);
  }

  Widget _helpSwitch() {
    if (isSwitched) {
      return Padding(
        padding: EdgeInsets.only(right: 24.0, bottom: 20),
        child: Text(
          'Se combinarán automáticamente las deudas de este grupo para deshacerse de pagos adicionales innecesarios.',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(right: 24.0, bottom: 20),
      child: Text(
        'No  se combinarán las deudas en este grupo, incluso si hay pagos adicionales innecesarios.',
        style: TextStyle(fontWeight: FontWeight.w300),
      ),
    );
  }
}
