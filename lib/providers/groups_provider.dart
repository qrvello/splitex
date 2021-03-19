//import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:repartapp/models/member_model.dart';
import 'package:repartapp/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsProvider {
  final user = auth.FirebaseAuth.instance.currentUser;

  final databaseReference = FirebaseDatabase.instance.reference();

  Stream<GroupModel> getGroup(GroupModel group) async* {
    GroupModel groupComplete;

    DatabaseReference groupReference =
        databaseReference.child('groups/${group.id}');

    Stream<Event> groupStream = groupReference.orderByKey().onValue;

    await for (Event event in groupStream) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        GroupModel thisGroup = GroupModel.fromMap(snapshot.value, snapshot.key);

        groupComplete = thisGroup;
      }

      yield groupComplete;
    }
  }

  Stream<List<GroupModel>> getGroupsList() async* {
    final List<GroupModel> foundGroups = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');

    DatabaseReference userGroups =
        databaseReference.child('users_groups/$uid/groups');

    Stream<Event> userGroupsStream = userGroups.orderByKey().onValue;

    await for (Event event in userGroupsStream) {
      foundGroups.clear();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> mapGroups = event.snapshot.value;

        mapGroups.forEach((id, group) {
          final GroupModel thisGroup = GroupModel.fromMap(group, id);
          foundGroups.add(thisGroup);
        });

        yield foundGroups;
      }
    }
  }

  Future<bool> createGroup(GroupModel group) async {
    // Guarda el id del creador del grupo
    group.adminUser = user.uid;

    // Crea la referencia con una key creada por firebase

    final newChildGroupRef = databaseReference.child('/groups').push();

    // Crea la referencia en usuarios con la key anterior
    final newChildUserGroupsRef = databaseReference
        .child('/users_groups/${user.uid}/groups/${newChildGroupRef.key}');

    // Guarda la data en un mapa

    final Map<String, dynamic> dataUser = {
      'name': group.name,
      'admin_user': group.adminUser,
      'timestamp': ServerValue.timestamp,
    };

    final data = Map.from(dataUser);

    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('displayName');

    data.putIfAbsent(
      'members',
      () => {
        name: {"balance": 0}
      },
    );

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
    };
    final members =
        await databaseReference.child('groups/${group.id}/members').once();

    members.value.keys.forEach((key) {
      updateObj.putIfAbsent(
          'users_groups/$key/groups/${group.id}/name', () => group.name);
    });

    databaseReference.update(updateObj).catchError((onError) {
      print("Error al actualizar el grupo: $onError");
      return false;
    });

    return true;
  }

  Future<bool> deleteGroup(GroupModel group) async {
    Map<String, dynamic> removeObj = {};

    // Valida que el admin del grupo sea el usuario que lo elimina sino solo lo borra de mis grupos
    if (group.adminUser == user.uid) {
      final groupPath = databaseReference.child('/groups/${group.id}').path;
      removeObj = {groupPath: null};
      final users =
          await databaseReference.child('/groups/${group.id}/users').once();

      // Si las keys recibe null (por ejemplo si solo hay una key) entonces solo borra del único miembro que está en el grupo.
      if (users.value != null) {
        users.value.keys.forEach((key) {
          removeObj.putIfAbsent(
              '/users_groups/$key/groups/${group.id}', () => null);
        });
      }
    } else {
      removeObj.putIfAbsent('/group/${group.id}/users/${user.uid}', () => null);
    }

    removeObj.putIfAbsent(
        '/users_groups/${user.uid}/groups/${group.id}', () => null);

    databaseReference.update(removeObj).catchError((error) {
      print('error al borrar o salir del grupo $error');
      return false;
    });

    return true;
  }

  Future<bool> addExpense(GroupModel group, Expense expense) async {
    final DatabaseReference newChildExpenseReference =
        databaseReference.child('groups/${group.id}/expenses').push();

    final DatabaseReference groupReference =
        databaseReference.child('groups/${group.id}');

    final List<Member> members = group.members;

    final int countMembers = members.length;

    Map<String, dynamic> updateObj = {
      '${newChildExpenseReference.path}': expense.toMap(),
    };

    // Solo usa 2 decimales
    final double debtForEach =
        double.parse((expense.amount / countMembers).toStringAsFixed(2));

    members.forEach((member) {
      double updatedBalance = 0;

      // Si el id del miembro es igual a el que pagó la expensa entonces suma el balance que
      // ya tiene en vez de restar

      if (member.id == expense.paidBy) {
        updatedBalance = member.balance + (expense.amount - debtForEach);
      } else {
        updatedBalance = member.balance - debtForEach;
      }

      updateObj.putIfAbsent(
        '${groupReference.path}/members/${member.id}/',
        () => {"balance": updatedBalance},
      );
    });

    await databaseReference.update(updateObj).catchError((error) {
      print(error);
      return false;
    });

    return true;
  }

  Future<bool> deleteExpense(GroupModel group, Expense expense) async {
    await databaseReference
        .child('groups/${group.id}/expenses/${expense.id}')
        .remove()
        .catchError((onError) {
      print('Error al borrar expensa $onError');
      return false;
    });
    return true;
  }

  Future<bool> addUserToGroup(User userToInvite, GroupModel group) async {
    final DataSnapshot snapshotMembers =
        await databaseReference.child('groups/${group.id}/users').once();

    if (snapshotMembers.value != null) {
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
    }).catchError((error) {
      print('Error al invitar a usuario $error');
      return false;
    });

    return true;
  }

  Future<bool> acceptInvitationGroup(GroupModel group) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final requestUserPath = databaseReference
        .child('users_requests/${user.uid}/groups/${group.id}/')
        .path;

    final usersGroupPath =
        databaseReference.child('groups/${group.id}/users/${user.uid}').path;

    final membersGroupPath = databaseReference
        .child('groups/${group.id}/members/${prefs.getString('displayName')}')
        .path;

    final groupsUserPath = databaseReference
        .child('users_groups/${user.uid}/groups/${group.id}')
        .path;

    final Map<String, dynamic> data = {
      'name': group.name,
      'admin_user': group.adminUser,
      'timestamp': group.timestamp,
    };

    final Map<String, dynamic> updateObj = {
      usersGroupPath: true,
      groupsUserPath: data,
      membersGroupPath: {'balance': 0},
      requestUserPath: null,
    };

    await databaseReference.update(updateObj).catchError((onError) {
      print("Error al aceptar invitacion: $onError");
      return false;
    });

    return true;
  }

  void addPersonToGroup(String name, GroupModel group) {
    final newChildMember =
        databaseReference.child('/groups/${group.id}/members/$name');

    newChildMember.update({
      "balance": 0,
    });
  }

  balanceDebts(List<Member> members) {
    //members.for
    members.asMap().forEach((name1, member1) {
      List<Member> members2 = members;
      members2.remove(member1);

      members2.asMap().forEach((name2, member2) {
        if (member2.balance >= member1.balance) {
          member2.balance += member1.balance;
          member1.balance += member2.balance;
          print(member1.balance);
        }
      });
    });
    //print(member.first.balance);
    //return member;
  }
}
