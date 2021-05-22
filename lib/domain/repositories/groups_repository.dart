import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';

abstract class GroupsRepository {
  Stream<List<Group>> getGroupsList();

  Stream<Group> getGroup(Group group);

  Future<bool> createGroup(Group group);

  Future<bool> updateGroup(Group group);

  Future<bool> deleteGroup(Group group);

  Future<bool> deleteMember(Group group, Member member);

  Future<Group> acceptInvitationGroup(String groupId);

  Future<bool> addPersonToGroup(String name, Group group);
}
