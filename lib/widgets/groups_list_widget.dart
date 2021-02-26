import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';
import 'package:gastos_grupales/provider/groups_provider.dart';

class GroupsLists extends StatelessWidget {
  final groupProvider = GroupsProvider();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: groupProvider.loadGroups(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final groups = snapshot.data;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, i) => _createItem(context, groups[i]),
          );
        } else {
          return Center(child: CupertinoActivityIndicator());
        }
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
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(group.name),
              onTap: () => Navigator.pushNamed(context, '/group_details',
                  arguments: group),
            ),
          ],
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
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        FlatButton(
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
    Scaffold.of(context).showSnackBar(
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
            Scaffold.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  _errorSnackbar(context) {
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xffe63946),
        content: Text(
            'Error al eliminar el grupo debido a que no sos administrador/a del mismo'),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Ok',
          onPressed: () {
            Scaffold.of(context).hideCurrentSnackBar();

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
