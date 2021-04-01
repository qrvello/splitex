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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 35,
                    color: Color(0xff25c0b7),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xff25c0b7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cuentas balanceadas',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
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
                color: Color(0xff25C0B7),
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          title: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: transaction.memberToPay.id,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' le tiene que pagar a '),
                TextSpan(
                  text: transaction.memberToReceive.id,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xff25C0B7),
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
