import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';
import 'package:repartapp/domain/repositories/groups_repository_offline.dart';

class EditGroupPage extends StatefulWidget {
  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final bool online = Get.arguments['online'];
  final Group group = Get.arguments['group'];

  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _groupNameController = TextEditingController();

  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: group.name);
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

  void _submit(context) async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    bool resp;

    if (online == true) {
      resp = await RepositoryProvider.of<GroupsRepository>(context)
          .updateGroup(group);
    } else {
      resp = await RepositoryProvider.of<GroupsRepositoryOffline>(context)
          .updateGroup(group);
    }

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
