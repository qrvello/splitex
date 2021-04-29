import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/member_model.dart';
import 'package:repartapp/domain/repositories/groups_repository_offline.dart';

import '../utils.dart';

class GroupsRepositoryOfflineImpl extends GroupsRepositoryOffline {
  User _user;

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  Box<Group> _groupsBox = Hive.box<Group>('groups');
  Box _userBox = Hive.box('user');

  @override
  Stream<Group> getGroup(Group group) async* {
    Group groupComplete;

    DatabaseReference groupReference =
        _databaseReference.child('groups/${group.id}');

    Stream<Event> groupStream = groupReference.onValue;

    await for (Event event in groupStream) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Group thisGroup = Group.fromMap(snapshot.value, snapshot.key);

        groupComplete = thisGroup;
      }

      yield groupComplete;
    }
  }

  Stream<List<Group>> getGroupsList() async* {
    List<Group> foundGroups = _groupsBox.values.toList();

    _groupsBox.watch().listen((event) {
      foundGroups = _groupsBox.values.toList();
    });

    yield foundGroups;
  }

  Future<bool> createGroup(Group group) async {
    final String name = _userBox.get('name');

    group.members = [];
    print(group.name);
    if (name != null) {
      final Member member = Member(id: name);

      group.members.add(member);
    }

    group.totalBalance = 0;

    int id = await _groupsBox.add(group);

    group.id = id.toString();

    await _groupsBox.put(id, group);

    return true;
  }

  Future<bool> updateGroup(Group group) async {
    if (await Utils().checkConnection() == false) {
      return false;
    }

    // Obtiene la referencia
    final DatabaseReference groupRef =
        _databaseReference.child('groups/${group.id}/');

    // Crea un mapa para usar multiple paths al insertar datos
    Map<String, dynamic> updateObj = {
      "${groupRef.path}/name": group.name,
    };

    group.users.keys.forEach((user) {
      updateObj.putIfAbsent(
          'users_groups/$user/groups/${group.id}/name', () => group.name);
    });

    _databaseReference.update(updateObj).catchError((onError) {
      print("Error al actualizar el grupo: $onError");
      return false;
    });

    return true;
  }

  Future<bool> deleteGroup(Group group) async {
    await _groupsBox.delete(int.parse(group.id));

    return true;
  }

  Future<dynamic> acceptInvitationGroup(String groupId) async {
    Box _userBox = Hive.box('user');

    DataSnapshot snapshot =
        await _databaseReference.child('groups/$groupId').once();

    Group group;

    if (snapshot.value != null) {
      group = Group.fromMap(snapshot.value, snapshot.key);
    }

    final requestUserPath = _databaseReference
        .child('users_requests/${_user.uid}/groups/${group.id}/')
        .path;

    final usersGroupPath =
        _databaseReference.child('groups/${group.id}/users/${_user.uid}').path;

    String membersGroupPath;
    String name = _userBox.get('name');
    if (name != null) {
      membersGroupPath =
          _databaseReference.child('groups/${group.id}/members/$name').path;
    }

    final groupsUserPath = _databaseReference
        .child('users_groups/${_user.uid}/groups/${group.id}')
        .path;

    final Map<String, dynamic> data = {
      'name': group.name,
      'timestamp': group.timestamp,
    };

    final Map<String, dynamic> updateObj = {
      usersGroupPath: true,
      groupsUserPath: data,
      if (membersGroupPath != null) membersGroupPath: {'balance': 0},
      requestUserPath: null,
    };

    await _databaseReference.update(updateObj).catchError((onError) {
      print("Error al aceptar invitacion: $onError");
      return false;
    });

    return group;
  }

  Future<bool> addPersonToGroup(String name, Group group) async {
    final Member member = Member(id: name, balance: 0);

    group.members.add(member);

    _groupsBox.put(group.id, group);

    return true;
  }
}
