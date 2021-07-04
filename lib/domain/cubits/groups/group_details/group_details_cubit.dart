import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';

part 'group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  GroupDetailsCubit(this._groupsRepository, this._group)
      : super(GroupDetailsInitial());

  final Group _group;

  final GroupsRepository _groupsRepository;

  void init() {
    _groupsRepository.getGroup(_group).listen((Group _group) {
      final List<dynamic> actions = [];

      for (final Expense expense in _group.expenses!) {
        actions.add(expense);
      }
      for (final Transaction transaction in _group.transactions!) {
        actions.add(transaction);
      }

      actions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(GroupDetailsLoaded(_group, actions));
    });
  }
}
