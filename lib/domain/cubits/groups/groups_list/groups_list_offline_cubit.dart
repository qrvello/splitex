import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repartapp/domain/models/group_model.dart';

import 'package:repartapp/domain/repositories/groups_repository_offline.dart';

import 'groups_list_state.dart';

class GroupsListOfflineCubit extends Cubit<GroupsListState> {
  GroupsListOfflineCubit(this.groupsRepositoryOffline)
      : super(GroupListInitialState());

  final GroupsRepositoryOffline groupsRepositoryOffline;

  void init() {
    emit(GroupListLoading());

    groupsRepositoryOffline.getGroupsList().listen((List<Group> groups) {
      print(groups);
      if (groups.length > 0) {
        emit(GroupsListLoaded(groups));
      }
    });

    emit(GroupListEmpty());
  }
}
