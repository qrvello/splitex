import 'package:bloc/bloc.dart';
import 'package:repartapp/domain/models/expense_model.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/transaction_model.dart';
import 'package:repartapp/domain/repositories/groups_repository_offline.dart';

import 'group_details_cubit.dart';

class GroupDetailsOfflineCubit extends Cubit<GroupDetailsState> {
  GroupDetailsOfflineCubit(this._groupsRepository, this.group)
      : super(GroupDetailsInitial());

  Group group;

  final GroupsRepositoryOffline _groupsRepository;

  void init() {
    _groupsRepository.getGroup(group).listen((Group _group) {
      List<dynamic> actions = [];

      for (Expense expense in _group.expenses) {
        actions.add(expense);
      }
      for (Transaction transaction in _group.transactions) {
        actions.add(transaction);
      }

      actions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _group.expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(GroupDetailsLoaded(_group, actions));
    });
  }
}
