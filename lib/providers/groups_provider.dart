//import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:repartapp/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsProvider {
  final user = auth.FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseDatabase.instance.reference();

  Future<bool> createGroup(GroupModel group) async {
    // Guarda el id del creador del grupo
    group.adminUser = user.uid;

    // Crea la referencia con una key creada por firebase

    final newChildGroupRef = databaseReference.child('groups').push();

    // Crea la referencia en usuarios con la key anterior
    final newChildUserGroupsRef = databaseReference
        .child('users_groups/${user.uid}/groups/${newChildGroupRef.key}');

    // Guarda la data en un mapa

    final Map<String, dynamic> dataUser = {
      'name': group.name,
      'simplify_group_debts': group.simplifyGroupDebts,
      'admin_user': group.adminUser,
      'timestamp': ServerValue.timestamp,
    };

    final data = Map.from(dataUser);

    data.putIfAbsent('members', () => {user.uid: true});

    // Crea un mapa para usar multiple paths al insertar datos
    final Map<String, dynamic> mapRefs = {
      newChildGroupRef.path: data,
      newChildUserGroupsRef.path: dataUser,
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
          'users_groups/$key/groups/${group.id}/name', () => group.name);
      updateObj.putIfAbsent(
          'users_groups/$key/groups/${group.id}/simplify_group_debts',
          () => group.simplifyGroupDebts);
    });

    databaseReference.update(updateObj).catchError((onError) {
      print("Error al actualizar el grupo: $onError");
      return false;
    });

    return true;
  }

  Future<bool> deleteGroup(GroupModel group) async {
    // Valida que el admin del grupo sea el usuario que lo elimina
    if (group.adminUser == user.uid) {
      final groupPath = databaseReference.child('/groups/${group.id}').path;

      Map<String, dynamic> removeObj = {groupPath: null};

      final members =
          await databaseReference.child('/groups/${group.id}/members').once();

      // Si las keys recibe null (por ejemplo si solo hay una key) entonces solo borra del único miembro que está en el grupo.
      if (members.value.keys != null) {
        members.value.keys.forEach((key) {
          removeObj.putIfAbsent(
              '/users_groups/$key/groups/${group.id}', () => null);
        });
      } else {
        removeObj.putIfAbsent(
            '/users_groups/${user.uid}/groups/${group.id}', () => null);
      }

      databaseReference.update(removeObj);

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
      'paid_by': user.uid,
      'timestamp': ServerValue.timestamp,
    }).catchError((error) {
      print(error);
      return false;
    });

    return true;
  }

  Future<bool> addMemberToGroup(User userToInvite, GroupModel group) async {
    final snapshotMembers =
        await databaseReference.child('groups/${group.id}/members').once();

    List keysList = [];

    snapshotMembers.value.forEach((key, value) {
      if (key != null) {
        keysList.add(key);
      }
    });

    // Verifica que no llegue data nula
    if (keysList.length > 1) {
      // Recorre las keys de los miembros para compararlas con el uid del usuario que se quiere agregar
      Map keys = snapshotMembers.value.keys;
      if (keys.containsKey(userToInvite.id)) {
        // Si el usuario que se quiere agregar ya esta en el grupo entonces retorna falso.
        return false;
      }
    }
    // Sino, se agrega al grupo
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await databaseReference
        .child('users_requests/${userToInvite.id}/groups')
        .update({
      group.id: {
        'name': group.name,
        'invited_by': prefs.getString('displayName'),
      }
    });
    return true;
  }

  acceptInvitationGroup(GroupModel group) async {
    databaseReference
        .child('users_requests/${user.uid}/groups/${group.id}/')
        .remove();

    final membersGroupPath =
        databaseReference.child('groups/${group.id}/members/').path;

    final usersGroupsPath = databaseReference
        .child('users_groups/${user.uid}/groups/${group.id}')
        .path;

    final Map<String, dynamic> data = {
      'name': group.name,
      'simplify_group_debts': group.simplifyGroupDebts,
      'admin_user': group.adminUser,
      'timestamp': group.timestamp,
    };

    final Map<String, dynamic> updateObj = {
      membersGroupPath: {user.uid: true},
      usersGroupsPath: data,
    };

    await databaseReference.update(updateObj).catchError((onError) {
      print("Error al aceptar invitacion: $onError");
      return false;
    });

    return true;
  }
}
