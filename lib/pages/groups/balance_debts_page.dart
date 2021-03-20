import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/transaction_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

class BalanceDebtsPage extends StatefulWidget {
  final GroupModel group;
  BalanceDebtsPage({this.group});

  @override
  _BalanceDebtsPageState createState() => _BalanceDebtsPageState();
}

final GroupsProvider groupProvider = GroupsProvider();

class _BalanceDebtsPageState extends State<BalanceDebtsPage> {
  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions = groupProvider.balanceDebts(widget.group);
    return Scaffold(
      appBar: AppBar(
        //leading: Container(),
        title: Text('Balancear cuentas'),
      ),
      body: (transactions.length > 0)
          ? ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, i) => _createItem(transactions[i]),
            )
          : Center(
              child: Text('No hay nada que balancear.'),
            ),
    );
  }

  Widget _createItem(Transaction transaction) {
    return Card(
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

            setState(() {});
          },
        ),
      ),
    );
  }
}
