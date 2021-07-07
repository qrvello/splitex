import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'package:splitex/domain/repositories/expenses_repository.dart';
import 'package:splitex/domain/repositories/expenses_repository_offline.dart';

class BalanceDebtsPage extends StatefulWidget {
  @override
  _BalanceDebtsPageState createState() => _BalanceDebtsPageState();
}

class _BalanceDebtsPageState extends State<BalanceDebtsPage> {
  final Group group = Get.arguments['group'] as Group;
  final bool online = Get.arguments['online'] as bool;

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  List<Transaction> transactions = [];

  @override
  void initState() {
    transactions = RepositoryProvider.of<ExpensesRepository>(context)
        .balanceDebts(group.members!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balancear cuentas'),
      ),
      body: (transactions.isNotEmpty)
          ? buildAnimatedList()
          : buildAccountsBalanced(),
    );
  }

  AnimatedList buildAnimatedList() {
    return AnimatedList(
      key: listKey,
      initialItemCount: transactions.length,
      itemBuilder: (context, i, animation) =>
          _createItem(transactions[i], i, animation),
    );
  }

  Center buildAccountsBalanced() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 35,
            color: Color(0xff25c0b7),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xff25c0b7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Cuentas balanceadas',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createItem(Transaction transaction, int index, Animation animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: const Offset(0, 0),
      ).animate(CurvedAnimation(
        parent: animation as Animation<double>,
        curve: Curves.easeInOut,
      )),
      child: Card(
        child: ListTile(
          subtitle: Text(
            '\$${transaction.amountToPay.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Color(0xff25C0B7),
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          title: Text(
            '${transaction.memberToPay.name!} le tiene que pagar a ${transaction.memberToReceive.name!}',
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xff25C0B7),
              size: 32,
            ),
            onPressed: () async {
              if (online == true) {
                await RepositoryProvider.of<ExpensesRepository>(context)
                    .checkTransaction(group, transaction);
              } else {
                await RepositoryProvider.of<ExpensesRepositoryOffline>(context)
                    .checkTransaction(group, transaction);
              }

              setState(() {
                transactions.remove(transaction);

                listKey.currentState!.removeItem(
                  index,
                  (context, animation) =>
                      _createItem(transaction, index, animation),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
