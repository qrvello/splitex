import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';

abstract class GroupsRepositoryOffline {
  Stream<List<Group>> getGroupsList();

  Future<bool> createGroup(Group group);

  Future<void> updateGroup({required Group group, required Group newGroup});

  Future<bool> deleteGroup(Group group);

  Future<bool> deleteMember(Group group, Member member);

  Future<bool> addPersonToGroup(String name, Group group);
}
