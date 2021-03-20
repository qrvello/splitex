import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/member_model.dart';
import 'package:repartapp/pages/groups/edit_group_page.dart';
import 'package:repartapp/pages/users/user_search.dart';
import 'package:repartapp/providers/groups_provider.dart';

import 'package:repartapp/widgets/confirm_delete.dart';

class DetailsGroupPage extends StatefulWidget {
  final GroupModel group;
  DetailsGroupPage({this.group});

  @override
  _DetailsGroupPageState createState() => _DetailsGroupPageState();
}

class _DetailsGroupPageState extends State<DetailsGroupPage> {
  final user = FirebaseAuth.instance.currentUser;
  final databaseReference = FirebaseDatabase.instance.reference();
  final groupProvider = GroupsProvider();
  final _newMemberName = TextEditingController();
  final formKey = GlobalKey<FormState>();

  StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.group.balanced == null) {
      widget.group.balanced = false;
    }
    _streamSubscription = groupProvider.getGroup(widget.group).listen((data) {
      setState(() {
        // Si la data (groupo) que se recibe es distinta de la que se tiene entonces se remplaza
        if (widget.group.balanced != data.balanced) {
          widget.group.balanced = data.balanced;
        }
        if (widget.group.expenses != data.expenses) {
          widget.group.expenses = data.expenses;
          widget.group.expenses
              .sort((a, b) => b.timestamp.compareTo(a.timestamp));
        }
        if (widget.group.members != data.members) {
          widget.group.members = data.members;
        }
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _newMemberName.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        _background(size),
        DefaultTabController(
          length: 2,
          child: Scaffold(
            floatingActionButton: SpeedDial(
              backgroundColor: Color(0xff001d3d),
              overlayColor: Colors.black12,
              icon: Icons.add_rounded,
              activeIcon: Icons.add_rounded,
              visible: true,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.shopping_bag_rounded),
                  backgroundColor: Colors.white10,
                  labelWidget: Text(
                    'Agregar gasto',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () => Navigator.of(context).pushNamed(
                    '/add_expense',
                    arguments: widget.group,
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.person_add_rounded),
                  backgroundColor: Colors.white10,
                  labelWidget: Text(
                    'Nueva persona',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(18.0),
                            ),
                          ),
                          content: Container(
                            height: 65,
                            child: Form(
                              key: formKey,
                              child: TextFormField(
                                autofocus: true,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                maxLength: 20,
                                cursorColor: Color(0xff264653),
                                style: TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  errorMaxLines: 3,
                                  labelText: 'Nombre',
                                ),
                                validator: (value) {
                                  if (value.length < 1) {
                                    return 'Ingrese el nombre del nuevo miembro';
                                  } else if (value.length > 20) {
                                    return 'Ingrese un nombre menor a 20 caracteres';
                                  } else {
                                    if (widget.group.members
                                        .asMap()
                                        .containsKey(value)) {
                                      return 'Ya existe un miembro con ese nombre. Elegí otro nombre por favor.';
                                    }
                                    return null;
                                  }
                                },
                                controller: _newMemberName,
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) =>
                                      (states.contains(MaterialState.pressed)
                                          ? Color(0xffFFDDD2)
                                          : Color(0xffE29578)),
                                ),
                              ),
                              child: Text('Cancelar'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            ElevatedButton(
                              child: Text('Guardar'),
                              onPressed: () {
                                _addNewMember();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditGroupPage(group: widget.group),
                    ),
                  ),
                ),
              ],
              elevation: 0,
              title: Text(widget.group.name),
              bottom: TabBar(
                isScrollable: false,
                tabs: [
                  Tab(
                    child: Text(
                      'Resumen',
                      style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Gastos',
                      style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _overview(),
                _expensesList(),
              ],
            ),
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
          begin: FractionalOffset(0.0, 0.3),
          end: FractionalOffset(0.0, 1.0),
          colors: [
            Color(0xff1c1e20),
            Color(0xff000000),
          ],
        ),
      ),
    );

    return Stack(
      children: [gradient],
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
      child: Card(
        child: ListTile(
          subtitle: Text('Pagado por ${expense.paidBy}'),
          title: Text(expense.description),
          trailing: Text(
            "\$${expense.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsGroupPage(group: widget.group),
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmDeleteDialog(context, expense) {
    _onPressed() {
      groupProvider.deleteExpense(widget.group, expense);
      Navigator.pop(context);
    }

    return ConfirmDelete(
      message:
          '¿Seguro/a deseas borrar el gasto ${expense.description}? Una vez eliminado no se podrá recuperar la información',
      title: 'Confirmar eliminación de gasto',
      onPressed: _onPressed,
    );
  }

  Widget _expensesList() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: (widget.group.balanced)
              ? Text(
                  'Cuentas saldadas',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              : Text(
                  'Cuentas sin saldar',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
          centerTitle: true,
          floating: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _createItem(context, widget.group.expenses[i]),
            childCount: widget.group.expenses.length,
          ),
        ),
      ],
    );
  }

  Widget _overview() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text('Invitar a miembros'),
                onPressed: () async {
                  await showSearch(
                    context: context,
                    delegate: UserSearchDelegate(widget.group),
                  );
                },
              ),
              ElevatedButton(
                child: Text('Balancear cuentas'),
                onPressed: () => Navigator.pushNamed(context, '/balance_debts',
                    arguments: widget.group),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _listMembers(context, widget.group.members[i]),
            childCount: widget.group.members.length,
          ),
        ),
      ],
    );
  }

  void _addNewMember() {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    groupProvider.addPersonToGroup(_newMemberName.text.trim(), widget.group);
    _newMemberName.text = '';
    Navigator.pop(context);
    setState(() {});
  }

  Widget _listMembers(BuildContext context, Member member) {
    return Card(
      child: ListTile(
        title: Text(member.id),
        trailing: Text(
          '\$${member.balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                (member.balance >= 0) ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
