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

    // Crea la referencia con una key creada por firebase

    final newChildGroupRef = databaseReference.child('groups').push();

    // Crea la referencia en usuarios con la key anterior
    final newChildUserGroupsRef = databaseReference
        .child('users/${user.uid}/groups/${newChildGroupRef.key}');

    // Guarda la data en un mapa

    final Map<String, dynamic> data = {
      'name': group.name,
      'simplify_group_debts': group.simplifyGroupDebts,
      'admin_user': group.adminUser,
      'timestamp': ServerValue.timestamp,
    };

    // Crea un mapa para usar multiple paths al insertar datos
    final Map<String, dynamic> mapRefs = {
      "${newChildGroupRef.path}": data,
      "${newChildUserGroupsRef.path}": data,
    };

    databaseReference.update(mapRefs).catchError((onError) {
      print("Error al crear nuevo grupo: $onError");
      return false;
    });

    return true;
  }

  Future<List<GroupModel>> loadGroups() async {
    List<GroupModel> groups = new List();

    // Recibe los grupos del usuario (keys)
    DataSnapshot snapshot =
        await databaseReference.child('users/${user.uid}/groups').once();

    if (snapshot.value == null) {
      return groups;
    }

    // Pasa por cada key para acceder a los datos completos del grupo
    snapshot.value.forEach((id, group) async {
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
      databaseReference.child('users/${user.uid}/groups/${group.id}').remove();
      return true;
    }
    return false;
  }
}
