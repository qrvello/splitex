import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';

import '../utils.dart';

class GroupsRepositoryImpl extends GroupsRepository {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  final Box _userBox = Hive.box('user');

  @override
  Stream<Group> getGroup(Group group) async* {
    if (await Utils.checkConnection() == false) yield group;

    DatabaseReference groupReference =
        _databaseReference.child('groups/${group.id}');

    Stream<Event> groupStream = groupReference.onValue;

    await for (Event event in groupStream) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Group groupComplete = Group.fromMap(snapshot.value, snapshot.key);

        yield groupComplete;
      }
    }

    yield group;
  }

  @override
  Stream<List<Group>> getGroupsList() async* {
    if (await Utils.checkConnection() == false) yield [];
    if (FirebaseAuth.instance.currentUser != null) {
      final DatabaseReference userGroupsReference = _databaseReference.child(
          'users_groups/${FirebaseAuth.instance.currentUser.uid}/groups');

      Stream<Event> userGroupsStream = userGroupsReference.orderByKey().onValue;

      await for (Event event in userGroupsStream) {
        List<Group> groups = [];

        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> mapGroups = event.snapshot.value;

          mapGroups.forEach((id, group) {
            final Group thisGroup = Group.fromMap(group, id);
            groups.add(thisGroup);
          });

          yield groups;
        } else {
          yield [];
        }
      }
    }
  }

  @override
  Future<bool> createGroup(Group group) async {
    if (await Utils.checkConnection() == false) return false;

    if (FirebaseAuth.instance.currentUser != null) {
      // Guarda el id del creador del grupo
      group.adminUser = FirebaseAuth.instance.currentUser.uid;

      // Crea la referencia con una key creada por firebase

      final DatabaseReference newChildGroupRef =
          _databaseReference.child('/groups').push();

      // Crea la referencia en usuarios con la key anterior
      final DatabaseReference newChildUserGroupsRef = _databaseReference.child(
          '/users_groups/${FirebaseAuth.instance.currentUser.uid}/groups/${newChildGroupRef.key}');

      // Guarda la data en un mapa

      final Map<String, dynamic> dataUser = {
        'name': group.name,
        'admin_user': group.adminUser,
        'timestamp': ServerValue.timestamp,
      };

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://splitex.online/links',
        link: Uri.parse(
            'https://splitex.online/links/?id=${newChildGroupRef.key}'),
        androidParameters: AndroidParameters(
          packageName: 'com.qrvello.splitex',
          minimumVersion: 1,
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Link para unirse a ${group.name}',
          description: 'Con este link abrís la aplicación y entrás al grupo.',
        ),
        navigationInfoParameters: NavigationInfoParameters(
          forcedRedirectEnabled: true,
        ),
      );

      final ShortDynamicLink shortDynamicLink =
          await parameters.buildShortLink();

      final Uri shortUrl = shortDynamicLink.shortUrl;

      final String name = _userBox.get('name');

      final Map<String, dynamic> data = {
        if (name != null)
          'members': {
            name: {
              "balance": 0,
            },
          },
        'users': {
          FirebaseAuth.instance.currentUser.uid: true,
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

      try {
        await _databaseReference.update(mapRefs);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Future<bool> updateGroup(Group group) async {
    if (await Utils.checkConnection() == false) return false;

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
    try {
      await _databaseReference.update(updateObj);
      return true;
    } catch (e) {
      print("Error al actualizar el grupo: ${e.toString()}");
      return false;
    }
  }

  @override
  Future<bool> deleteGroup(Group group) async {
    if (await Utils.checkConnection() == false) return false;

    Map<String, dynamic> removeObj = {};
    if (FirebaseAuth.instance.currentUser != null) {
      // Valida que el admin del grupo sea el usuario que lo elimina sino solo lo borra de mis grupos
      if (group.adminUser == FirebaseAuth.instance.currentUser.uid) {
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
            '/group/${group.id}/users/${FirebaseAuth.instance.currentUser.uid}',
            () => null);
      }

      removeObj.putIfAbsent(
          '/users_groups/${FirebaseAuth.instance.currentUser.uid}/groups/${group.id}',
          () => null);

      try {
        await _databaseReference.update(removeObj);
        return true;
      } catch (e) {
        print(e.toString());

        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Future<Group> acceptInvitationGroup(String groupId) async {
    if (await Utils.checkConnection() == false) return null;

    DataSnapshot snapshot;
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        snapshot = await _databaseReference.child('groups/$groupId').once();
      } catch (e) {
        print(e.toString());
        return null;
      }

      Group group = Group.fromMap(snapshot.value, snapshot.key);

      final usersGroupPath = _databaseReference
          .child(
              'groups/${group.id}/users/${FirebaseAuth.instance.currentUser.uid}')
          .path;

      String membersGroupPath;

      String name = _userBox.get('name');

      if (name != null) {
        membersGroupPath =
            _databaseReference.child('groups/${group.id}/members/$name').path;
      }

      final groupsUserPath = _databaseReference
          .child(
              'users_groups/${FirebaseAuth.instance.currentUser.uid}/groups/${group.id}')
          .path;

      final Map<String, dynamic> data = {
        'name': group.name,
        'timestamp': group.timestamp,
        'admin_user': group.adminUser,
      };

      final Map<String, dynamic> updateObj = {
        usersGroupPath: true,
        groupsUserPath: data,
        if (membersGroupPath != null) membersGroupPath: {'balance': 0},
      };
      try {
        await _databaseReference.update(updateObj);
        return group;
      } catch (e) {
        print("Error al aceptar invitacion: ${e.toString()}");
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Future<bool> addPersonToGroup(String name, Group group) async {
    if (await Utils.checkConnection() == false) return false;

    final DatabaseReference newChildMember =
        _databaseReference.child('/groups/${group.id}/members/$name');

    try {
      await newChildMember.update({
        "balance": 0,
      });
      return true;
    } catch (e) {
      debugPrint('Error al agregar persona al grupo: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<bool> deleteMember(Group group, Member member) async {
    if (await Utils.checkConnection() == false) return false;

    try {
      await _databaseReference
          .child('/groups/${group.id}/members/${member.id}')
          .update(null);
      return true;
    } catch (e) {
      debugPrint('Error al borrar miembro: ${e.toString()}');
      return false;
    }
  }
}
