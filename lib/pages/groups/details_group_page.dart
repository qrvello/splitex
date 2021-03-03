import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';
import 'package:gastos_grupales/pages/groups/edit_group_page.dart';

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

  @override
  void initState() {
    super.initState();

    _streamSubscription = getData(widget.group).listen((data) {
      setState(() {
        group = data;
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
      var groupValue = groupSnapshot.snapshot.value;

      if (groupValue != null) {
        var thisGroup = GroupModel.fromJson(groupValue);

        thisGroup.id = groupSnapshot.snapshot.key;

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
            body: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buttonAddExpense(context, group),
                      _buttonAddMember(context, group),
                    ],
                  ),
                ],
              ),
            )),
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

  Widget _buttonAddExpense(BuildContext context, GroupModel group) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      color: Color(0xff2a9d8f),
      child: Text(
        'Añadir gasto',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed('/add_expense', arguments: group);
      },
    );
  }

  Widget _buttonAddMember(BuildContext context, GroupModel group) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      color: Color(0xff2a9d8f),
      child: Text(
        'Añadir miembro',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed('/add_expense', arguments: group);
      },
    );
  }
}
