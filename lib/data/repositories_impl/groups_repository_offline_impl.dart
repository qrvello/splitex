import 'package:hive/hive.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/member_model.dart';
import 'package:repartapp/domain/repositories/groups_repository_offline.dart';

class GroupsRepositoryOfflineImpl extends GroupsRepositoryOffline {
  Box<Group> _groupsBox = Hive.box<Group>('groups');
  Box _userBox = Hive.box('user');

  Stream<List<Group>> getGroupsList() async* {
    List<Group> foundGroups = _groupsBox.values.toList();

    _groupsBox.watch().listen((event) {
      foundGroups = _groupsBox.values.toList();
    });

    yield foundGroups;
  }

  Future<bool> createGroup(Group _group) async {
    final String name = _userBox.get('name');

    final Group group = Group(
      name: _group.name,
      members: [],
      transactions: [],
      expenses: [],
      totalBalance: 0.00,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    if (name != null) {
      final Member member = Member(id: name);

      group.members.add(member);
    }

    final int id = await _groupsBox.add(group);

    group.id = id;

    await _groupsBox.put(id, group);

    return true;
  }

  Future<bool> updateGroup(Group group) async {
    await _groupsBox.put(group.id, group);
    return true;
  }

  Future<bool> deleteGroup(Group group) async {
    await _groupsBox.delete(group.id);

    return true;
  }

  Future<bool> addPersonToGroup(String name, Group group) async {
    final Member member = Member(id: name, balance: 0);

    group.members.add(member);

    _groupsBox.put(group.id, group);

    return true;
  }
}
