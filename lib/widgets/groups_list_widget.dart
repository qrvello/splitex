import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';
import 'package:gastos_grupales/provider/groups_provider.dart';

class GroupsLists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GroupsProvider().loadGroups(),
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
      key: UniqueKey(),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red[200],
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
      //onDismissed: (direction) {
      //  groupPr.borrarProducto(producto.id);
      //},
      direction: DismissDirection.endToStart,
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
