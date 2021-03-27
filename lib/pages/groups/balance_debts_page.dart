import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/transaction_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

class BalanceDebtsPage extends StatefulWidget {
  final Group group;
  BalanceDebtsPage({this.group});

  @override
  _BalanceDebtsPageState createState() => _BalanceDebtsPageState();
}

class _BalanceDebtsPageState extends State<BalanceDebtsPage> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final GroupsProvider groupProvider = GroupsProvider();

  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions =
        groupProvider.balanceDebts(widget.group.members);

    return Scaffold(
      appBar: AppBar(
        //leading: Container(),
        title: Text('Balancear cuentas'),
      ),
      body: (transactions.length > 0)
          ? AnimatedList(
              key: listKey,
              initialItemCount: transactions.length,
              itemBuilder: (context, i, animation) =>
                  _createItem(transactions[i], i, animation),
            )
          : Center(
              child: Text('No hay nada que balancear.'),
            ),
    );
  }

  Widget _createItem(Transaction transaction, int index, Animation animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: Card(
        child: ListTile(
          subtitle: Text(
            '\$${transaction.amountToPay.toStringAsFixed(2)}',
            style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: transaction.memberToPay.id,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.87),
                  ),
                ),
                TextSpan(
                  text: ' le tiene que pagar a ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                TextSpan(
                  text: transaction.memberToReceive.id,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.87),
                  ),
                ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.greenAccent,
              size: 32,
            ),
            onPressed: () async {
              await groupProvider.checkTransaction(transaction, widget.group);

              listKey.currentState.removeItem(
                index,
                (context, animation) =>
                    _createItem(transaction, index, animation),
              );
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  void removeItem(int index) {}
}
