import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/pages/groups/details_group_page.dart';

import 'package:repartapp/providers/groups_provider.dart';

class GroupsListTab extends StatefulWidget {
  @override
  _GroupsListTabState createState() => _GroupsListTabState();
}

class _GroupsListTabState extends State<GroupsListTab> {
  final groupProvider = GroupsProvider();

  final user = FirebaseAuth.instance.currentUser;
  final databaseReference = FirebaseDatabase.instance.reference();

  StreamSubscription _streamSubscription;

  List<GroupModel> groups = [];

  @override
  void initState() {
    super.initState();

    _streamSubscription = getData().listen((data) {
      setState(() {
        groups = data;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    super.dispose();
  }

  Stream<List<GroupModel>> getData() async* {
    var userGroupsStream = databaseReference
        .child('users/${user.uid}/groups')
        .orderByKey()
        .onValue;
    List<GroupModel> foundGroups = [];

    await for (var userGroupsSnapshot in userGroupsStream) {
      foundGroups.clear();

      Map dictionary = userGroupsSnapshot.snapshot.value;
      if (dictionary != null) {
        dictionary.forEach((id, group) {
          var thisGroup = GroupModel.fromJson(group);
          thisGroup.id = id;
          foundGroups.add(thisGroup);
        });

        yield foundGroups;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (groups.length > 0) {
      return ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, i) => _createItem(context, groups[i]),
      );
    }
    // ignore: todo
    //TODO: Arreglar carga: que cuando esté cargando no aparezca el mensaje de no participas en ningun grupo sino que aparezca un circular progress indicator

    return Center(
      child: Text('No participás de ningún grupo.'),
    );
  }

  Widget _createItem(BuildContext context, GroupModel group) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (_) {
            // Al deslizar muestra un cuadro de diálogo pidiendo confirmación
            return _confirmDeleteDialog(context, group);
          },
        );
      },
      onDismissed: (_) {
        setState(() {});
      },
      key: UniqueKey(),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xffe76f51),
        ),
        alignment: AlignmentDirectional.centerEnd,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      child: Container(
        child: ListTile(
          title: Text(group.name),
          trailing: Text(
            'No debés nada',
            style: TextStyle(color: Colors.black38),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsGroupPage(group: group),
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmDeleteDialog(context, group) {
    return AlertDialog(
      title: Text('Confirmar eliminación'),
      content: Text(
          '¿Seguro/a deseas borrar el grupo ${group.name}? Una vez eliminado no se podrá recuperar la información'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            _deleteGroup(context, group);
          },
          child: Text(
            'Confirmar',
            style: TextStyle(color: Color(0xffe76f51)),
          ),
        ),
      ],
    );
  }

  _successSnackbar(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xff2a9d8f),
        content: Text(
          'Grupo eliminado satisfactoriamente',
        ),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Ok',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  _errorSnackbar(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xffe63946),
        content: Text(
            'Error al eliminar el grupo debido a que no sos administrador/a del mismo'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Ok',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            return;
          },
        ),
      ),
    );
  }

  _deleteGroup(context, group) {
    final result = groupProvider.deleteGroup(group);

    if (result == true) {
      Navigator.of(context).pop(true);

      _successSnackbar(context);
    } else {
      Navigator.of(context).pop(false);

      _errorSnackbar(context);
    }
  }
}
