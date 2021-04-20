import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';

import 'groups_list_state.dart';

class GroupsListCubit extends Cubit<GroupsListState> {
  GroupsListCubit(this._groupsRepository) : super(GroupListInitialState());

  final GroupsRepository _groupsRepository;

  void init() {
    emit(GroupListLoading());

    _groupsRepository.getGroupsList().listen((List<Group> groups) {
      print(groups);
      if (groups.length > 0) {
        groups.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        emit(GroupListLoaded(groups));
      }
    });

    emit(GroupListEmpty());
  }
}
