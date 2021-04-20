import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'balance_debts_state.dart';

class BalanceDebtsCubit extends Cubit<BalanceDebtsState> {
  BalanceDebtsCubit() : super(BalanceDebtsInitial());
}
