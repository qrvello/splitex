import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/providers/groups_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repartapp/styles/elevated_button_style.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final groupProvider = new GroupsProvider();

  final _groupNameController = new TextEditingController();

  GroupModel group = new GroupModel();

  bool isSwitched = false;

  bool _guardando = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Crear grupo'),
      ),
      body: Builder(
        builder: (context) => Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                _inputCreateName(),
                SizedBox(height: 12.0),
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
      child: ElevatedButton(
        style: elevatedButtonStyle,
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
        controller: _groupNameController,
      ),
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
      _groupNameController.text = '';
      return _success(context);
    } else {
      return _error(context);
    }
  }

  _success(context) {
    ScaffoldMessenger.of(context).showSnackBar(
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

            return;
          },
        ),
      ),
    );
  }

  _error(context) {
    ScaffoldMessenger.of(context).showSnackBar(
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
            Navigator.of(context).pop();
            return;
          },
        ),
      ),
    );
  }
}
