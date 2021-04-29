import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:repartapp/domain/cubits/groups/group_details/group_details_cubit.dart';
import 'package:repartapp/domain/models/expense_model.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/transaction_model.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';
import 'package:repartapp/domain/repositories/groups_repository_offline.dart';
import 'package:repartapp/ui/pages/groups/add_expense_page.dart';
import 'package:repartapp/ui/pages/groups/edit_group_page.dart';
import 'package:repartapp/ui/pages/groups/widgets/activity_widget.dart';
import 'package:repartapp/ui/pages/groups/widgets/overview_widget.dart';

// ignore: must_be_immutable
class DetailsGroupPage extends StatefulWidget {
  @override
  _DetailsGroupPageState createState() => _DetailsGroupPageState();
}

class _DetailsGroupPageState extends State<DetailsGroupPage> {
  final bool online = Get.arguments['online'];
  Group group = Get.arguments['group'];

  final databaseReference = FirebaseDatabase.instance.reference();
  final _newMemberName = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String newMember;

  @override
  void dispose() {
    _newMemberName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (online == true) {
      return _buildOnline();
    } else {
      return _buildOffline();
    }
  }

  ValueListenableBuilder<Box<Group>> _buildOffline() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Group>('groups').listenable(keys: [group.id]),
      builder: (BuildContext context, Box<Group> box, widget) {
        group = box.get(group.id);

        List<dynamic> actions = [];

        if (group.expenses != null) {
          for (Expense expense in group.expenses) {
            actions.add(expense);
          }
        }

        if (group.transactions != null) {
          for (Transaction transaction in group.transactions) {
            actions.add(transaction);
          }
        }

        actions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Stack(
          children: [
            DefaultTabController(
              length: 2,
              child: Scaffold(
                floatingActionButton: buildSpeedDial(context),
                extendBodyBehindAppBar: true,
                appBar: buildAppBar(context),
                body: TabBarView(
                  children: [
                    OverviewWidget(group: group, online: online),
                    ActivityWidget(group: group, actions: actions),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  BlocProvider<GroupDetailsCubit> _buildOnline() {
    return BlocProvider(
      create: (context) =>
          GroupDetailsCubit(context.read<GroupsRepository>(), group)..init(),
      child: BlocConsumer<GroupDetailsCubit, GroupDetailsState>(
        listener: (context, state) {
          if (state is GroupDetailsLoaded) {
            group = state.group;
          }
        },
        builder: (context, state) {
          return _builderDetails(context, state);
        },
      ),
    );
  }

  Stack _builderDetails(BuildContext context, GroupDetailsState state) {
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            floatingActionButton: buildSpeedDial(context),
            extendBodyBehindAppBar: true,
            appBar: buildAppBar(context),
            body: (state is GroupDetailsLoaded)
                ? TabBarView(
                    children: [
                      OverviewWidget(group: state.group, online: online),
                      ActivityWidget(
                        group: state.group,
                        actions: state.actions,
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
            icon: Icon(Icons.settings_rounded),
            onPressed: () => Get.to(() => EditGroupPage(),
                arguments: {'group': group, 'online': online})),
      ],
      elevation: 0,
      title: Text(
        group.name,
        style: Theme.of(context).textTheme.headline5,
      ),
      bottom: TabBar(
        isScrollable: false,
        tabs: [
          Tab(
            child: Text('Resumen'),
          ),
          Tab(
            child: Text('Actividad'),
          ),
        ],
      ),
    );
  }

  SpeedDial buildSpeedDial(BuildContext context) {
    return SpeedDial(
      backgroundColor: Color(0xff0076FF).withOpacity(0.87),
      overlayColor: Theme.of(context).scaffoldBackgroundColor,
      icon: Icons.add_rounded,
      visible: true,
      children: [
        SpeedDialChild(
            child: Icon(Icons.shopping_bag_rounded),
            backgroundColor: Theme.of(context).accentColor,
            labelWidget: Text(
              'Agregar gasto',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Get.to(() => AddExpensePage(),
                  arguments: {'group': group, 'online': online});
            }
            //onTap: () => Navigator.of(context).pushNamed(
            //  '/add_expense',
            //  arguments: ,
            //),
            ),
        SpeedDialChild(
          child: Icon(Icons.person_add_rounded),
          backgroundColor: Theme.of(context).accentColor,
          labelWidget: Text(
            'Nueva persona',
            style: TextStyle(fontSize: 18),
          ),
          onTap: () => dialogAddMember(context),
        ),
      ],
    );
  }

  Future dialogAddMember(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              maxLength: 20,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                errorMaxLines: 3,
                labelText: 'Nombre',
              ),
              validator: (value) {
                if (value.trim().length < 1) {
                  return 'Ingrese el nombre del nuevo miembro';
                } else if (value.trim().length > 20) {
                  return 'Ingrese un nombre menor a 20 caracteres';
                }

                for (var member in group.members) {
                  if (member.id == value.trim()) {
                    return 'Ya existe un miembro con ese nombre. Elegí otro nombre por favor.';
                  }
                }
                return null;
              },
              onSaved: (value) {
                newMember = value.trim();
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => (states.contains(MaterialState.pressed)
                      ? Color(0xffE29578)
                      : Color(0xffee6c4d)),
                ),
              ),
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Agregar'),
              onPressed: () => _addNewMember(),
            ),
          ],
        );
      },
    );
  }

  void _addNewMember() async {
    formKey.currentState.save();

    if (!formKey.currentState.validate()) return;
    bool result;

    if (online == true) {
      result = await context
          .read<GroupsRepository>()
          .addPersonToGroup(newMember, group);
    } else {
      result = await context
          .read<GroupsRepositoryOffline>()
          .addPersonToGroup(newMember, group);
    }

    if (result == true) {
      Get.back();
      snackbarSuccess();
    } else {
      snackbarError();
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Miembro agregado satisfactoriamente',
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
      'Error al agregar miembro al grupo',
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
