import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

import '../../locator.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  EditGroupPage({@required this.group});

  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final GroupsProvider groupsProvider = locator.get<GroupsProvider>();

  var _groupNameController = new TextEditingController();

  bool isSwitched = false;

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check_rounded),
        onPressed: () {
          _submit(context);
        },
      ),
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
                _inputEditName(),
                //Expanded(
                //  child: ListView.builder(itemBuilder:
                //  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputEditName() {
    return TextFormField(
      maxLength: 25,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        helperText: 'Ejemplo: Vacaciones a la costa',
        labelText: 'Nombre del grupo',
      ),
      onSaved: (value) => widget.group.name = value,
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

  void _submit(context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    bool resp = await groupsProvider.updateGroup(widget.group);

    if (resp == true) {
      snackbarSuccess();
    } else {
      snackbarError();
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Grupo editado satisfactoriamente',
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError() {
    return Get.snackbar(
      'Error',
      'Error al editar el grupo',
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
