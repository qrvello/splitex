//import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
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

    final Map<String, dynamic> dataUser = data;

    data.putIfAbsent(
      'members',
      () => {
        user.uid: true,
      },
    );

    // Crea un mapa para usar multiple paths al insertar datos
    final Map<String, dynamic> mapRefs = {
      "${newChildGroupRef.path}": data,
      "${newChildUserGroupsRef.path}": dataUser,
    };

    databaseReference.update(mapRefs).catchError((onError) {
      print("Error al crear nuevo grupo: $onError");
      return false;
    });

    return true;
  }

  Future<bool> updateGroup(GroupModel group) async {
    Map<String, dynamic> updateObj = {};
    // Obtiene la referencia

    final groupRef = databaseReference.child('groups/${group.id}/');

    // Crea un mapa para usar multiple paths al insertar datos
    updateObj = {
      "${groupRef.path}/name": group.name,
      "${groupRef.path}/simplify_group_debts": group.simplifyGroupDebts,
    };
    final members =
        await databaseReference.child('groups/${group.id}/members').once();

    members.value.keys.forEach((key) {
      updateObj.putIfAbsent(
          'users/$key/groups/${group.id}/name', () => group.name);
      updateObj.putIfAbsent(
          'users/$key/groups/${group.id}/simplify_group_debts',
          () => group.simplifyGroupDebts);
    });

    databaseReference.update(updateObj).catchError((onError) {
      print("Error al crear nuevo grupo: $onError");
      return false;
    });

    return true;
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

  Future<bool> addExpense(GroupModel group, Expense expense) async {
    final newChildExpenseReference =
        databaseReference.child('groups/${group.id}/expenses/').push();

    await newChildExpenseReference.set({
      'description': expense.description,
      'amount': expense.amount,
      'paid_by': user.uid
    }).catchError((error) {
      print(error);
      return false;
    });

    return true;
  }
}
