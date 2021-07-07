import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
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

    final DatabaseReference groupReference =
        _databaseReference.child('groups/${group.id}');

    final Stream<Event> groupStream = groupReference.onValue;

    await for (final Event event in groupStream) {
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        final Group groupComplete = Group.fromMap(
            snapshot.value as Map<dynamic, dynamic>, snapshot.key);

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
          'users_groups/${FirebaseAuth.instance.currentUser!.uid}/groups');

      final Stream<Event> userGroupsStream =
          userGroupsReference.orderByKey().onValue;

      await for (final Event event in userGroupsStream) {
        final List<Group> groups = [];

        if (event.snapshot.value != null) {
          final Map<dynamic, dynamic> mapGroups =
              event.snapshot.value as Map<dynamic, dynamic>;

          mapGroups.forEach((id, group) {
            final Group thisGroup =
                Group.fromMap(group as Map<dynamic, dynamic>, id);
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
  Future<void> createGroup(Group group) async {
    if (await Utils.checkConnection() == false) {
      throw const SocketException('No hay internet');
    }

    if (FirebaseAuth.instance.currentUser != null) {
      // Guarda el id del creador del grupo
      group.adminUser = FirebaseAuth.instance.currentUser!.uid;

      // Crea la referencia con una key creada por firebase

      final DatabaseReference newChildGroupRef =
          _databaseReference.child('/groups').push();

      // Crea la referencia en usuarios con la key anterior
      final DatabaseReference newChildUserGroupsRef = _databaseReference.child(
          '/users_groups/${FirebaseAuth.instance.currentUser!.uid}/groups/${newChildGroupRef.key}');

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

      final String? name = _userBox.get('name') as String?;

      final Map<String, dynamic> data = {
        if (name != null)
          'members': {
            newChildUserGroupsRef.child('members').push().key: {
              "name": name,
              "balance": 0,
            },
          },
        'users': {
          FirebaseAuth.instance.currentUser!.uid: true,
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
      } catch (e) {
        rethrow;
      }
    } else {
      throw Exception('No has iniciado sesión');
    }
  }

  @override
  Future<void> updateGroup({
    required Group group,
    required Group newGroup,
  }) async {
    if (await Utils.checkConnection() == false) {
      throw const SocketException('No hay internet');
    }

    // Obtiene la ruta del grupo
    final DatabaseReference groupRef =
        _databaseReference.child('groups/${group.id}/');

    Map<String, dynamic> updateObj = {};

    if (newGroup.name != group.name) {
      // Crea un mapa para usar multiple paths al insertar datos
      updateObj = {"${groupRef.path}name": newGroup.name};

      // Recorre los grupos de cada usuario y le cambia el nombre
      for (final userKey in group.users!.keys) {
        updateObj['users_groups/$userKey/groups/${group.id}/name'] =
            newGroup.name;
      }
    }

    if (group.members!.isNotEmpty) {
      for (final member in group.members!) {
        final newMember = newGroup.members!.firstWhereOrNull(
          (newMember) => newMember.id == member.id,
        );

        if (newMember == null) {
          updateObj['${groupRef.path}members/${member.id}'] = null;
        }
      }
    }

    if (newGroup.members!.isNotEmpty) {
      for (final member in newGroup.members!) {
        // Si el id del miembro es nulo significa que es un miembro nuevo.
        if (member.id != null) {
          // Recorre los antiguos miembros para encontrar la version del miembro.
          final oldMember = group.members!.firstWhereOrNull(
            (oldMember) => oldMember.id == member.id,
          );

          if (oldMember != null) {
            // Si el nombre del miembro antiguamente era distinto al actual,
            // se agrega al updateObj para actualizarlo.
            if (oldMember.name != member.name) {
              updateObj['${groupRef.path}members/${member.id}/name'] =
                  member.name;
            }
          }
        } else {
          final String newMemberKey = groupRef.child('members').push().key;

          updateObj['${groupRef.path}members/$newMemberKey'] = member.toMap();
        }
      }
    } else {
      if (group.members!.isNotEmpty) {
        updateObj['${groupRef.path}/members'] = null;
      }
    }
    print(updateObj);
    if (updateObj != {}) {
      try {
        await _databaseReference.update(updateObj);
      } catch (e) {
        print("Error al actualizar el grupo: ${e.toString()}");
        rethrow;
      }
    } else {
      throw 'No hay cambios a realizar';
    }
  }

  @override
  Future<bool> deleteGroup(Group group) async {
    if (await Utils.checkConnection() == false) return false;

    Map<String, dynamic> removeObj = {};
    if (FirebaseAuth.instance.currentUser != null) {
      // Valida que el admin del grupo sea el usuario que lo elimina sino solo lo borra de mis grupos
      if (group.adminUser == FirebaseAuth.instance.currentUser!.uid) {
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
            '/group/${group.id}/users/${FirebaseAuth.instance.currentUser!.uid}',
            () => null);
      }

      removeObj.putIfAbsent(
          '/users_groups/${FirebaseAuth.instance.currentUser!.uid}/groups/${group.id}',
          () => null);

      try {
        await _databaseReference.update(removeObj);
        return true;
      } catch (e) {
        print(e.toString());

        rethrow;
      }
    } else {
      throw Exception('El usuario no esta logueado');
    }
  }

  @override
  Future<Group> acceptInvitationGroup(String groupId) async {
    if (await Utils.checkConnection() == false) {
      throw const SocketException('No hay internet');
    }

    DataSnapshot snapshot;
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        snapshot = await _databaseReference.child('groups/$groupId').once();
      } catch (e) {
        print(e.toString());
        throw const SocketException('No hay internet');
      }

      final Group group =
          Group.fromMap(snapshot.value as Map<dynamic, dynamic>, snapshot.key);

      final usersGroupPath = _databaseReference
          .child(
              'groups/${group.id}/users/${FirebaseAuth.instance.currentUser!.uid}')
          .path;

      String? membersGroupPath;

      final String? name = _userBox.get('name') as String?;

      if (name != null) {
        membersGroupPath =
            _databaseReference.child('groups/${group.id}/members/$name').path;
      }

      final groupsUserPath = _databaseReference
          .child(
              'users_groups/${FirebaseAuth.instance.currentUser!.uid}/groups/${group.id}')
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
        throw Exception();
      }
    } else {
      throw Exception();
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
          .update({});
      return true;
    } catch (e) {
      debugPrint('Error al borrar miembro: ${e.toString()}');
      return false;
    }
  }
}
