part of 'group_details_cubit.dart';

@immutable
abstract class GroupDetailsState {
  const GroupDetailsState();
}

class GroupDetailsInitial extends GroupDetailsState {}

class GroupDetailsLoaded extends GroupDetailsState {
  final Group group;
  final List<dynamic> actions;
  const GroupDetailsLoaded(this.group, this.actions);
}
