import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
part 'group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  GroupDetailsCubit({
    this.groupsRepository,
    required this.group,
  }) : super(GroupDetailsInitial());

  Group group;

  final GroupsRepository? groupsRepository;
  final Box<Group> _groupsBox = Hive.box<Group>('groups');

  Future<void> init() async {
    if (groupsRepository != null) {
      groupsRepository!.getGroup(group).listen((Group _group) {
        final List<dynamic> actions = [
          ..._group.expenses!,
          ..._group.transactions!
        ];

        actions.sort((a, b) => b.timestamp.compareTo(a.timestamp) as int);

        emit(GroupDetailsLoaded(_group, actions));
      });
    } else {
      _groupsBox.watch(key: group.id).listen((event) {
        group = event.value as Group;

        final List<dynamic> actions = [
          ...group.expenses!,
          ...group.transactions!
        ];

        actions.sort((a, b) => b.timestamp.compareTo(a.timestamp) as int);

        emit(GroupDetailsLoaded(group, actions));
      });

      final List<dynamic> actions = [
        ...group.expenses!,
        ...group.transactions!
      ];

      actions.sort((a, b) => b.timestamp.compareTo(a.timestamp) as int);
      emit(GroupDetailsLoaded(group, actions));
    }
  }
}
