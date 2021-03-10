import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/pages/groups/edit_group_page.dart';
import 'package:repartapp/pages/user_search.dart';
//import 'package:repartapp/styles/elevated_button_style.dart';

class DetailsGroupPage extends StatefulWidget {
  final GroupModel group;

  DetailsGroupPage({@required this.group});

  @override
  _DetailsGroupPageState createState() => _DetailsGroupPageState();
}

class _DetailsGroupPageState extends State<DetailsGroupPage> {
  final user = FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseDatabase.instance.reference();

  GroupModel group;
  StreamSubscription _streamSubscription;
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();

    _streamSubscription = getData(widget.group).listen((data) {
      setState(() {
        group = data;
        if (group.expenses != null) {
          Map map = group.expenses;

          map.forEach((key, value) {
            var expense = Expense.fromJson(value, key);

            expenses.add(expense);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    super.dispose();
  }

  Stream<GroupModel> getData(GroupModel group) async* {
    GroupModel groupUpdated;
    var groupStream = databaseReference.child('groups/${group.id}').onValue;

    await for (var groupSnapshot in groupStream) {
      expenses.clear();
      var groupValue = groupSnapshot.snapshot.value;

      if (groupValue != null) {
        var thisGroup =
            GroupModel.fromJson(groupValue, groupSnapshot.snapshot.key);

        groupUpdated = thisGroup;
      }

      yield groupUpdated;
    }
  }

  @override
  Widget build(BuildContext context) {
    GroupModel group = widget.group;

    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        _background(size),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            actions: [
              IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: () async {
                    await showSearch(
                      context: context,
                      delegate: UserSearchDelegate(group),
                    );

                    //setState(() {});
                  }),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => Navigator.of(context)
                    .pushNamed('/add_expense', arguments: group),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGroupPage(group: group),
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(group.name),
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              // Add the app bar to the CustomScrollView.
              SliverAppBar(
                leading: Container(),
                title: Text(
                  'Cuentas saldadas',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                centerTitle: true,
                floating: true,
              ),
              // Next, create a SliverList
              SliverList(
                // Use a delegate to build items as they're scrolled on screen.
                delegate: SliverChildBuilderDelegate(
                  // The builder function returns a ListTile with a title that
                  // displays the index of the current item.
                  (context, i) => _createItem(context, expenses[i]),
                  // Builds 1000 ListTiles
                  childCount: expenses.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _background(size) {
    final gradient = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset(0.0, 0.1),
          end: FractionalOffset(0.0, 1.0),
          colors: [
            Color.fromRGBO(52, 54, 101, 1.0),
            Color.fromRGBO(35, 37, 57, 1.0),
          ],
        ),
      ),
    );

    final box = Transform.rotate(
      angle: -3.14 / 4.0,
      child: Container(
        height: size.width,
        width: size.height * 0.5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(90.0),
            gradient:
                LinearGradient(colors: [Color(0xff2a9d8f), Color(0xff264653)])),
      ),
    );

    return Stack(
      children: [
        gradient,
        //mainAxisAlignment: MainAxisAlignment.start,
        Positioned(
          child: box,
          top: -150,
        ),
      ],
    );
  }

  Widget _createItem(BuildContext context, Expense expense) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (_) {
            // Al deslizar muestra un cuadro de diálogo pidiendo confirmación
            return _confirmDeleteDialog(context, expense);
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
      child: Card(
        color: Color(0xf2ffffff),
        child: ListTile(
          subtitle: Text('Pagado por vos'),
          title: Text(expense.description),
          trailing: Text(
            "\$ ${expense.amount.toString()}",
            style: TextStyle(color: Colors.black87),
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

  Widget _confirmDeleteDialog(context, expense) {
    return AlertDialog(
      title: Text('Confirmar eliminación'),
      content: Text(
          '¿Seguro/a deseas borrar el gasto ${expense.description}? Una vez eliminado no se podrá recuperar la información'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            // TODO borrar expensa
          },
          child: Text(
            'Confirmar',
            style: TextStyle(color: Color(0xffe76f51)),
          ),
        ),
      ],
    );
  }
}
