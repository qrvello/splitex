import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:repartapp/domain/cubits/groups/group_details/group_details_cubit.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';
import 'package:repartapp/ui/pages/groups/edit_group_page.dart';
import 'package:repartapp/ui/pages/groups/widgets/activity_widget.dart';
import 'package:repartapp/ui/pages/groups/widgets/overview_widget.dart';

// ignore: must_be_immutable
class DetailsGroupPage extends StatefulWidget {
  Group group;
  DetailsGroupPage({this.group});

  @override
  _DetailsGroupPageState createState() => _DetailsGroupPageState();
}

class _DetailsGroupPageState extends State<DetailsGroupPage> {
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
    return BlocProvider(
      create: (context) =>
          GroupDetailsCubit(context.read<GroupsRepository>(), widget.group)
            ..init(),
      child: BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
        builder: (context, state) {
          if (state is GroupDetailsLoaded) {
            widget.group = state.group;
          }
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
                            OverviewWidget(group: state.group),
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
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
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
      title: Hero(
        child: Text(
          widget.group.name,
          style: Theme.of(context).textTheme.headline5,
        ),
        tag: widget.group.id,
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
          onTap: () => Navigator.of(context).pushNamed(
            '/add_expense',
            arguments: widget.group,
          ),
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

                for (var member in widget.group.members) {
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

    bool result = await context
        .read<GroupsRepository>()
        .addPersonToGroup(newMember, widget.group);

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
