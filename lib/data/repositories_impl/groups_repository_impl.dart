import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:hive/hive.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';

import '../utils.dart';

class GroupsRepositoryImpl extends GroupsRepository {
  User _user = FirebaseAuth.instance.currentUser;

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  final Box _userBox = Hive.box('user');

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
    final List<Group> foundGroups = [];

    if (_user != null) {
      DatabaseReference userGroupsReference =
          _databaseReference.child('users_groups/${_user.uid}/groups');

      Stream<Event> userGroupsStream = userGroupsReference.orderByKey().onValue;

      await for (Event event in userGroupsStream) {
        foundGroups.clear();

        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> mapGroups = event.snapshot.value;

          mapGroups.forEach((id, group) {
            final Group thisGroup = Group.fromMap(group, id);
            foundGroups.add(thisGroup);
          });

          yield foundGroups;
        }
      }
    }

    yield foundGroups;
  }

  Future<bool> createGroup(Group group) async {
    if (await Utils().checkConnection() == false) {
      return false;
    }

    // Guarda el id del creador del grupo
    group.adminUser = _user.uid;

    // Crea la referencia con una key creada por firebase

    final newChildGroupRef = _databaseReference.child('/groups').push();

    // Crea la referencia en usuarios con la key anterior
    final newChildUserGroupsRef = _databaseReference
        .child('/users_groups/${_user.uid}/groups/${newChildGroupRef.key}');

    // Guarda la data en un mapa

    final Map<String, dynamic> dataUser = {
      'name': group.name,
      'admin_user': group.adminUser,
      'timestamp': ServerValue.timestamp,
    };

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://repartapp2.page.link/',
      link:
          Uri.parse('https://repartapp2.page.link/?id=${newChildGroupRef.key}'),
      androidParameters: AndroidParameters(
        packageName: 'com.curvello.repartapp',
        minimumVersion: 1,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Link para unirse a ${group.name}',
        description: 'This link works whether app is installed or not!',
      ),
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();

    final Uri shortUrl = shortDynamicLink.shortUrl;

    String name = _userBox.get('name');

    final Map<String, dynamic> data = {
      if (name != null)
        'members': {
          name: {
            "balance": 0,
          },
        },
      'users': {
        _user.uid: true,
      },
      'total_balance': 0,
      'link': shortUrl.toString(),
    };

    data.addAll(dataUser);

    // Crea un mapa para usar multiple paths al insertar datos
    final Map<String, dynamic> mapRefs = {
      newChildGroupRef.path: data,
      newChildUserGroupsRef.path: dataUser,
    };

    await _databaseReference.update(mapRefs).catchError((onError) {
      print("Error al crear nuevo grupo: $onError");
      return false;
    });

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
    if (await Utils().checkConnection() == false) {
      return false;
    }

    Map<String, dynamic> removeObj = {};

    // Valida que el admin del grupo sea el usuario que lo elimina sino solo lo borra de mis grupos
    if (group.adminUser == _user.uid) {
      final String groupPath =
          _databaseReference.child('/groups/${group.id}').path;
      removeObj = {groupPath: null};
      final DataSnapshot users =
          await _databaseReference.child('/groups/${group.id}/users').once();

      // Si las keys recibe null (por ejemplo si solo hay una key) entonces solo borra del único miembro que está en el grupo.
      if (users.value != null) {
        users.value.keys.forEach((key) {
          removeObj.putIfAbsent(
              '/users_groups/$key/groups/${group.id}', () => null);
        });
      }
    } else {
      removeObj.putIfAbsent(
          '/group/${group.id}/users/${_user.uid}', () => null);
    }

    removeObj.putIfAbsent(
        '/users_groups/${_user.uid}/groups/${group.id}', () => null);

    _databaseReference.update(removeObj).catchError((error) {
      print('error al borrar o salir del grupo $error');
      return false;
    });

    return true;
  }

  Future<dynamic> acceptInvitationGroup(String groupId) async {
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
    final DatabaseReference newChildMember =
        _databaseReference.child('/groups/${group.id}/members/$name');

    await newChildMember.update({
      "balance": 0,
    }).catchError((onError) {
      print(onError);
      return false;
    });

    return true;
  }
}
