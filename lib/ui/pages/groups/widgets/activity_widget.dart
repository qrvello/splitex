import 'package:flutter/material.dart';
import 'package:repartapp/domain/models/expense_model.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/models/transaction_model.dart';
import 'package:intl/intl.dart';

class ActivityWidget extends StatelessWidget {
  final Group group;
  final List<dynamic> actions;

  ActivityWidget({@required this.group, this.actions});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xff0076ff).withOpacity(0.87),
              borderRadius: BorderRadius.circular(12),
            ),
            child: (group.totalBalance > 0)
                ? Text(
                    'Gasto total: \$${group.totalBalance}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  )
                : Text(
                    'Sin gastos',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
          centerTitle: true,
          floating: true,
        ),
        if (actions != null)
          SliverPadding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _createItem(actions[i]),
                childCount: actions.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _createItem(action) {
    if (action is Expense) {
      Expense expense = action;
      return Card(
        child: ListTile(
          //isThreeLine: true,
          //subtitle: Text('Pagado por ${expense.paidBy}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Pagado por ${expense.paidBy}'),
              Text(
                DateFormat('k:mm - EEEE d, MMMM, y', 'es_ES').format(
                  DateTime.fromMillisecondsSinceEpoch(expense.timestamp),
                ),
              ),
              //SizedBox(height: 10),
            ],
          ),
          title: Text(
            expense.description,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "\$${expense.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xffF4a74d),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          leading: Container(
            margin: EdgeInsets.only(left: 10),
            height: double.infinity,
            child: Icon(
              Icons.shopping_bag_rounded,
              color: Color(0xff0076FF),
            ),
          ),
        ),
      );
    }
    Transaction transaction = action;
    return Card(
      child: ListTile(
        title: Text(
            '${transaction.memberToPay.id} le pagó a ${transaction.memberToReceive.id}'),
        trailing: Text(
          '\$${transaction.amountToPay.toStringAsFixed(2)}',
          style: TextStyle(
            color: Color(0xff25C0B7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          DateFormat('k:mm - EEEE d, MMMM, y', 'es_ES').format(
            DateTime.fromMillisecondsSinceEpoch(transaction.timestamp),
          ),
        ),
        leading: Container(
          margin: EdgeInsets.only(left: 10),
          height: double.infinity,
          child: Icon(
            Icons.arrow_right_alt_rounded,
            color: Color(0xff0076FF),
          ),
        ),
      ),
    );
  }
}
