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
  final groupProvider = GroupsProvider();

  final user = FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseDatabase.instance.reference();

  List<GroupModel> groups = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: groupProvider.getGroupsList(),
      builder:
          (BuildContext context, AsyncSnapshot<List<GroupModel>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Ha ocurrido un error al cargar tus grupos.'),
          );
        }

        if (snapshot.hasData) {
          List<GroupModel> groups = snapshot.data;
          groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, i) => _createItem(context, groups[i]),
          );
        }

        return Center(
          child: Text('No participás de ningún grupo.'),
        );
      },
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
      child: Container(
        child: ListTile(
          title: Text(group.name),
          trailing: Icon(Icons.drag_handle_rounded),
          onTap: () => Navigator.pushNamed(
            context,
            '/group_details',
            arguments: group,
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

  _errorSnackbar(context) {
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

  _deleteGroup(context, group) async {
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
