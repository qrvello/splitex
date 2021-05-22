import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';

part 'group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  GroupDetailsCubit(this._groupsRepository, this.group)
      : super(GroupDetailsInitial());

  Group group;

  final GroupsRepository _groupsRepository;

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
      //_group.expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(GroupDetailsLoaded(_group, actions));
    });
  }
}
