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
      body: Builder(
        builder: (context) => Form(
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
                SizedBox(
                  height: 12,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Nota: ',
                    style: TextStyle(color: Colors.black45),
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
    return CupertinoButton(
      color: Color(0xff2a9d8f),
      borderRadius: BorderRadius.circular(20.0),
      child: Text('Guardar'),
      onPressed: (_guardando)
          ? null
          : () {
              _submit(context);
            },
    );
  }

  Widget _inputCreateName() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Nombre del grupo',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      onSaved: (value) => group.name = value,
      validator: (value) {
        if (value.length < 1) {
          return 'Ingrese el nombre del grupo';
        } else if (value.length > 25) {
          return 'Ingrese un nombre menor a 25 caracteres';
        } else {
          return null;
        }
      },
    );
  }

  Widget _switch() {
    return CupertinoSwitch(
      activeColor: Color(0xff2a9d8f),
      value: isSwitched,
      onChanged: (value) {
        setState(() {
          isSwitched = value;
        });
      },
    );
  }

  _submit(context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    setState(() {
      _guardando = true;
    });

    group.simplifyGroupDebts = isSwitched;

    final resp = await groupProvider.createGroup(group);

    setState(() {
      _guardando = false;
    });

    if (resp) {
      return _success(context);
    } else {
      return _error();
    }
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

  _success(context) {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xff2a9d8f),
        content: Text(
          'Grupo creado satisfactoriamente',
        ),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Ok',
          onPressed: () {
            // Back to the home page
            Navigator.pop(context);

            // Close modal
            Navigator.pop(context);

            return;
          },
        ),
      ),
    );
  }

  _error() {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xffe63946),
        content: Text(
          'Error al crear grupo',
        ),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Ok',
          onPressed: () {
            // Back to the home page
            Navigator.pop(context);

            // Close modal
            Navigator.pop(context);

            return;
          },
        ),
      ),
    );
  }
}
