import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  final GroupsProvider groupProvider = GroupsProvider();

  final User user = FirebaseAuth.instance.currentUser;

  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();

  List<Group> groups = [];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return StreamBuilder(
      stream: groupProvider.getGroupsList(),
      builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Ha ocurrido un error al cargar tus grupos.'),
          );
        }

        if (snapshot.hasData) {
          groups = snapshot.data;

          groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Column(
            children: [
              Divider(
                height: 1,
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: size.height * 0.1),
                  itemCount: groups.length,
                  itemBuilder: (context, i) => _createItem(context, groups[i]),
                ),
              ),
            ],
          );
        }

        return Center(
          child: Text('No participás de ningún grupo.'),
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
            title: Text(group.name),
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

  void _successSnackbar(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grupo eliminado satisfactoriamente'),
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

  void _errorSnackbar(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xffe63946),
        content: Text('Error al eliminar el grupo'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            return;
          },
        ),
      ),
    );
  }

  void _deleteGroup(context, group) async {
    final result = await groupProvider.deleteGroup(group);

    if (result == true) {
      groups.remove(group);
      Navigator.of(context).pop(result);
      setState(() {});
      _successSnackbar(context);
    } else {
      Navigator.of(context).pop(result);

      _errorSnackbar(context);
    }
  }
}
