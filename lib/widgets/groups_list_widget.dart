import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';
import 'package:gastos_grupales/provider/groups_provider.dart';

class GroupsLists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GroupsProvider().loadGroups(),
      builder:
          (BuildContext context, AsyncSnapshot<List<GroupModel>> snapshot) {
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
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
      ),
      //onDismissed: (direccion) {
      //  productosProvider.borrarProducto(producto.id);
      //},
      child: Card(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(group.name),
              onTap: () => Navigator.pushNamed(context, 'group_details',
                  arguments: group),
            ),
          ],
        ),
      ),
    );
  }
}
