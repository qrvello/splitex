import 'package:flutter/material.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:splitex/domain/models/transaction_model.dart';
import 'package:splitex/ui/pages/groups/widgets/card_expense_widget.dart';
import 'package:splitex/ui/pages/groups/widgets/card_transaction_widget.dart';

class ActivityWidget extends StatelessWidget {
  final Group group;
  final List<dynamic> actions;

  const ActivityWidget({required this.group, required this.actions});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff0076ff).withOpacity(0.87),
              borderRadius: BorderRadius.circular(12),
            ),
            child: (group.totalBalance! > 0)
                ? Text(
                    'Gasto total: \$${group.totalBalance}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  )
                : const Text(
                    'Sin gastos',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
          centerTitle: true,
          floating: true,
        ),
        SliverPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, i) => _createItem(actions[i], context),
              childCount: actions.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _createItem(action, context) {
    if (action is Expense) {
      final Member? paidBy = group.members!
          .firstWhereOrNull((element) => element.id == action.paidBy);

      return CardExpenseWidget(
        expense: action,
        paidBy: paidBy,
      );
    } else {
      final Member? memberToPay = group.members!
          .firstWhereOrNull((element) => element.id == action.memberToPay.id);

      final Member? memberToReceive = group.members!.firstWhereOrNull(
          (element) => element.id == action.memberToReceive.id);

      return CardTransactionWidget(
        transaction: action as Transaction,
        memberToPay: memberToPay,
        memberToReceive: memberToReceive,
      );
    }
  }
}
