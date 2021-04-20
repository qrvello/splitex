part of 'add_expense_cubit.dart';

@immutable
abstract class AddExpenseState {}

class AddExpenseInitial extends AddExpenseState {}

class AddExpenseLoaded extends AddExpenseState {
  final List<DropdownMenuItem<String>> dropdownMenuItems;
  final String dropdownValue;
  AddExpenseLoaded({this.dropdownMenuItems, this.dropdownValue});
}
