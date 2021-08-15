import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitex/domain/models/group_model.dart';

import 'package:splitex/domain/repositories/groups_repository_offline.dart';

import 'groups_list_state.dart';

class GroupsListOfflineCubit extends Cubit<GroupsListState> {
  GroupsListOfflineCubit(this.groupsRepositoryOffline)
      : super(GroupListInitialState());

  final GroupsRepositoryOffline groupsRepositoryOffline;

  void init() {
    emit(GroupListLoading());

    groupsRepositoryOffline.getGroupsList().listen((List<Group> groups) {
      print(groups);
      if (groups.isNotEmpty) {
        emit(GroupsListLoaded(groups));
      }
    });

    emit(GroupListEmpty());
  }
}
