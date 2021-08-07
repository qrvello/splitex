import 'package:hive/hive.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/repositories/groups_repository_offline.dart';

class GroupsRepositoryOfflineImpl extends GroupsRepositoryOffline {
  final Box<Group> _groupsBox = Hive.box<Group>('groups');
  final Box _userBox = Hive.box('user');

  @override
  Stream<List<Group>> getGroupsList() async* {
    List<Group?> foundGroups = _groupsBox.values.toList();

    _groupsBox.watch().listen((event) {
      foundGroups = _groupsBox.values.toList();
    });

    yield foundGroups as List<Group>;
  }

  @override
  Future<bool> createGroup(Group _group) async {
    final String? name = _userBox.get('name') as String?;

    final Group group = Group(
      name: _group.name,
      members: [],
      transactions: [],
      expenses: [],
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    if (name != null) {
      final Member member = Member(id: DateTime.now().toString(), name: name);

      group.members!.add(member);
    }

    final int id = await _groupsBox.add(group);

    group.id = id;

    await _groupsBox.put(id, group);

    return true;
  }

  @override
  Future<void> updateGroup(
      {required Group group, required Group newGroup}) async {
    try {
      group.members = newGroup.members;
      group.name = newGroup.name;
      await _groupsBox.put(group.id, group);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteGroup(Group group) async {
    await _groupsBox.delete(group.id);

    return true;
  }

  @override
  Future<bool> addPersonToGroup(String name, Group group) async {
    final Member member = Member(name: name);

    group.members!.add(member);

    await _groupsBox.put(group.id, group);

    return true;
  }

  @override
  Future<bool> deleteMember(Group? group, Member member) async {
    group!.members!.remove(member);

    await _groupsBox.put(group.id, group);

    return true;
  }
}
