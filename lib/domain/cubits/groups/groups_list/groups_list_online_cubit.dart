import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';

import 'groups_list_state.dart';

class GroupsListOnlineCubit extends Cubit<GroupsListState> {
  GroupsListOnlineCubit(this.groupsRepository) : super(GroupListInitialState());

  final GroupsRepository groupsRepository;

  void init() {
    emit(GroupListLoading());

    groupsRepository.getGroupsList().listen((List<Group> groups) {
      if (groups.length > 0) {
        groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        emit(GroupsListLoaded(groups));
      } else {
        emit(GroupListEmpty());
      }
    });

    emit(GroupListEmpty());
  }
}
