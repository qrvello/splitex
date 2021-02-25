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
    databaseReference.child('groups').push().set({
      'name': group.name,
      'simplify_group_debts': group.simplifyGroupDebts,
      'admin_user': group.adminUser,
    });

    // Actualiza los grupos del usuario
    databaseReference
        .child('users/${user.uid}/groups')
        .update({group.name: true});

    return true;
  }

  Future<List<GroupModel>> loadGroups() async {
    DataSnapshot snapshot = await databaseReference.child('groups').once();

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
}
