import 'package:repartapp/domain/models/group_model.dart';

abstract class GroupsRepositoryOffline {
  Stream<List<Group>> getGroupsList();

  Future<bool> createGroup(Group group);

  Future<bool> updateGroup(Group group);

  Future<bool> deleteGroup(Group group);

  Future<bool> addPersonToGroup(String name, Group group);
}
