import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final user = FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseDatabase.instance.reference();

  final groupProvider = new GroupsProvider();

  StreamSubscription _streamSubscription;

  List<GroupModel> groupsInvitations = [];

  @override
  void initState() {
    super.initState();

    _streamSubscription = getData().listen((data) {
      setState(() {
        groupsInvitations = data;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    super.dispose();
  }

  Stream<List<GroupModel>> getData() async* {
    var userGroupsStream = databaseReference
        .child('users_requests/${user.uid}/groups')
        .orderByKey()
        .onValue;
    List<GroupModel> foundGroups = [];

    await for (var userGroupsSnapshot in userGroupsStream) {
      foundGroups.clear();

      Map dictionary = userGroupsSnapshot.snapshot.value;
      if (dictionary != null) {
        dictionary.forEach((id, group) {
          var thisGroup = GroupModel.fromJson(group, id);

          foundGroups.add(thisGroup);
        });

        yield foundGroups;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Notificaciones'),
      ),
      body: groupsInvitations.length > 0
          ? ListView.builder(
              itemCount: groupsInvitations.length,
              itemBuilder: (context, i) =>
                  _createItem(context, groupsInvitations[i]),
            )
          : Center(
              child: Text('No hay notificaciones'),
            ),
    );
  }

  Widget _createItem(BuildContext context, GroupModel group) {
    return Container(
      child: ListTile(
          title: Text(group.name),
          subtitle: Text("Invitado por: ${group.invitedBy}"),
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.cancel_rounded,
                      color: Color(0xffe76f51),
                    ),
                    onPressed: () {}),
                IconButton(
                    icon: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xff06d6a0),
                    ),
                    onPressed: () {
                      groupProvider.acceptInvitationGroup(group);
                      groupsInvitations.remove(group);
                      _successSnackbar(context);
                      setState(() {});
                    }),
              ],
            ),
          )),
    );
  }

  _successSnackbar(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitación aceptada satisfactoriamente'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
