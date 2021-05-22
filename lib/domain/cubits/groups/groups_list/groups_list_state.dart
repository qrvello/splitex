import 'package:splitex/domain/models/group_model.dart';

abstract class GroupsListState {
  GroupsListState();
}

class GroupListInitialState extends GroupsListState {}

class GroupListLoading extends GroupsListState {}

class GroupsListLoaded extends GroupsListState {
  final List<Group> groups;

  GroupsListLoaded(this.groups);
}

class GroupListEmpty extends GroupsListState {}

class GroupListError extends GroupsListState {
  final String message;

  GroupListError(this.message);
}
