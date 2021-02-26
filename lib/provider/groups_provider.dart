import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:gastos_grupales/models/group_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupsProvider {
  final user = FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseDatabase.instance.reference();

  Future<bool> createGroup(GroupModel group) async {
    // Guarda el id del creador del grupo
    final uidUser = user.uid;
    group.adminUser = uidUser;

    // Inserta nuevo dato con una key creada por firebase
    final newChildRef = databaseReference.child('groups').push();

    // Guarda la nueva key que se usará.
    final newChildKey = newChildRef.key;

    newChildRef.set(
      {
        'name': group.name,
        'simplify_group_debts': group.simplifyGroupDebts,
        'admin_user': group.adminUser,
      },
    ).catchError((onError) {
      print('Error al crear grupo: $onError');
      return false;
    });

    // Actualiza los grupos del usuario con el id del grupo marcandolo true.
    databaseReference
        .child('users/${user.uid}/groups')
        .update({newChildKey: true}).catchError(
      (onError) {
        print(onError);
        return false;
      },
    );

    return true;
  }

  Future<List<GroupModel>> loadGroups() async {
    DataSnapshot snapshot = await databaseReference.child('groups').once();
    //final groupsUser = new Map<String, dynamic>.from(snapshot.value);
    //print(groupsUser);
    final decodedData = new Map<String, dynamic>.from(snapshot.value);

    // Limpia el mapa para que no tire un error (?)
    final cleanMap = jsonDecode(jsonEncode(decodedData));

    final List<GroupModel> groups = new List();

    if (decodedData == null) return [];

    cleanMap.forEach((id, group) {
      final groupTemp = GroupModel.fromJson(group);
      groupTemp.id = id;
      groups.add(groupTemp);
    });

    return groups;
  }

  bool deleteGroup(GroupModel group) {
    // Valida que el admin del grupo sea el usuario que lo elimina
    if (group.adminUser == user.uid) {
      databaseReference.child('groups/${group.id}').remove();
      return true;
    }
    return false;
  }
}
