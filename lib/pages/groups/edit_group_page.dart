import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  EditGroupPage({@required this.group});

  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final groupProvider = new GroupsProvider();

  var _groupNameController = new TextEditingController();

  bool isSwitched = false;

  bool _guardando = false;
  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.group.name);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Group group = widget.group;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Editar grupo'),
      ),
      body: Builder(
        builder: (context) => Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                _inputEditName(group),
                SizedBox(height: 12.0),
                _button(context, group),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _button(context, group) {
    return Container(
      width: 120,
      child: ElevatedButton(
        child: Text(
          'Guardar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: (_guardando)
            ? null
            : () {
                _submit(context, group);
              },
      ),
    );
  }

  Widget _inputEditName(group) {
    return TextFormField(
      maxLength: 25,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        helperText: 'Ejemplo: Vacaciones a la costa',
        labelText: 'Nombre del grupo',
      ),
      onSaved: (value) => group.name = value,
      validator: (value) {
        if (value.trim().length < 1) {
          return 'Ingrese el nombre del grupo';
        } else if (value.trim().length > 25) {
          return 'Ingrese un nombre menor a 25 caracteres';
        } else {
          return null;
        }
      },
      controller: _groupNameController,
    );
  }

  _submit(context, group) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    bool resp = await groupProvider.updateGroup(group);

    if (resp == true) {
      return _success(context);
    } else {
      return _error(context);
    }
  }

  _success(context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grupo editado satisfactoriamente'),
        action: SnackBarAction(
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
      SnackBar(
        backgroundColor: Color(0xffe63946),
        content: Text('Error al crear grupo'),
      ),
    );
  }
}
