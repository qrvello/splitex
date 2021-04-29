import 'package:repartapp/domain/models/group_model.dart';

abstract class GroupsRepositoryOffline {
  Stream<List<Group>> getGroupsList();

  Stream<Group> getGroup(Group group);

  Future<bool> createGroup(Group group);

  Future<bool> updateGroup(Group group);

  Future<bool> deleteGroup(Group group);

  Future<dynamic> acceptInvitationGroup(String groupId);

  Future<bool> addPersonToGroup(String name, Group group);
}
