part of 'group_details_cubit.dart';

@immutable
abstract class GroupDetailsState {}

class GroupDetailsInitial extends GroupDetailsState {}

class GroupDetailsLoaded extends GroupDetailsState {
  final Group group;
  final List<dynamic> actions;
  GroupDetailsLoaded(this.group, this.actions);
}
