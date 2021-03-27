import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/pages/groups/edit_group_page.dart';
import 'package:repartapp/pages/groups/widgets/activity_widget.dart';
import 'package:repartapp/pages/groups/widgets/overview_widget.dart';
import 'package:repartapp/providers/groups_provider.dart';

// ignore: must_be_immutable
class DetailsGroupPage extends StatefulWidget {
  Group group;
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
    _streamSubscription =
        groupProvider.getGroup(widget.group).listen((Group data) {
      setState(() {
        // Si la data (groupo) que se recibe es distinta de la que se tiene entonces se remplaza
        widget.group = data;
        widget.group.expenses
            .sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
            floatingActionButton: buildSpeedDial(context),
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: buildAppBar(context),
            body: TabBarView(
              children: [
                OverviewWidget(group: widget.group),
                ActivityWidget(group: widget.group),
              ],
            ),
          ),
        ),
      ],
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
              'Actividad',
              style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  SpeedDial buildSpeedDial(BuildContext context) {
    return SpeedDial(
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLength: 20,
                cursorColor: Color(0xff264653),
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
                  } else {
                    if (widget.group.members
                        .asMap()
                        .containsKey(value.trim())) {
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

  void _addNewMember() {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    groupProvider.addPersonToGroup(_newMemberName.text.trim(), widget.group);
    _newMemberName.text = '';
    Navigator.pop(context);
    setState(() {});
  }
}
