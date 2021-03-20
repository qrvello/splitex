import 'package:flutter/material.dart';
import 'package:repartapp/models/expense.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/transaction_model.dart';

class ActivityWidget extends StatefulWidget {
  final GroupModel group;

  const ActivityWidget({Key key, this.group}) : super(key: key);
  @override
  _ActivityWidgetState createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  List actions = [];
  @override
  void initState() {
    super.initState();
    for (Expense expense in widget.group.expenses) {
      actions.add(expense);
    }
    for (Transaction transaction in widget.group.transactions) {
      actions.add(transaction);
    }
    setState(() {
      actions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: (widget.group.totalBalance > 0)
              ? Text(
                  'Gasto total: ${widget.group.totalBalance}',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )
              : Text(
                  'Sin gastos',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
          centerTitle: true,
          floating: true,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _createItem(actions[i]),
            childCount: actions.length,
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
          //subtitle: Text('Pagado por ${expense.paidBy}'),
          subtitle: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: 'Pagado por ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                TextSpan(
                  text: expense.paidBy,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.87),
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            expense.description,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          trailing: Text(
            "\$${expense.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    Transaction transaction = action;
    return Card(
      child: ListTile(
        title: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16),
            children: [
              TextSpan(
                text: transaction.memberToPay.id,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.87),
                ),
              ),
              TextSpan(
                text: ' le pagó a ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              TextSpan(
                text: transaction.memberToReceive.id,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.87),
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          '\$${transaction.amountToPay.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
