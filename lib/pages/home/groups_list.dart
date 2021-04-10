import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  final GroupsProvider groupsProvider = Get.find();

  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  List<Group> groups = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: groupsProvider.getGroupsList(),
      builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Ha ocurrido un error al cargar tus grupos.'),
          );
        }

        if (snapshot.hasData) {
          groups = snapshot.data;
          groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          if (groups.length > 0) {
            return Column(
              children: [
                Divider(
                  height: 1,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: size.height * 0.1),
                    itemCount: groups.length,
                    itemBuilder: (context, i) =>
                        _createItem(context, groups[i]),
                  ),
                ),
              ],
            );
          }
        }

        return Center(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No participás de ningún grupo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _createItem(BuildContext context, Group group) {
    return Column(
      children: [
        Dismissible(
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
            decoration: BoxDecoration(
              color: Color(0xffE29578),
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
          child: ListTile(
            title: Hero(
              child: Text(
                group.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              tag: group.id,
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/group_details',
              arguments: group,
            ),
            trailing: Icon(
              Icons.circle,
              size: 10,
              color: Color(0xff06d6a0),
            ),
          ),
        ),
        Divider(
          height: 0,
        ),
      ],
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

  void _deleteGroup(context, group) async {
    final result = await groupsProvider.deleteGroup(group);

    if (result == true) {
      Navigator.of(context).pop(result);
      snackbarSuccess();
    } else {
      Navigator.of(context).pop(result);

      snackbarError();
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Grupo borrado satisfactoriamente',
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
      'Error al borrar el grupo',
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
