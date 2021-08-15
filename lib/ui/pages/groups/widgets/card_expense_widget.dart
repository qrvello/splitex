import 'package:flutter/material.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:intl/intl.dart';

class CardExpenseWidget extends StatelessWidget {
  const CardExpenseWidget({
    required this.expense,
    required this.group,
  });

  final Expense expense;
  final Group group;

  @override
  Widget build(BuildContext context) {
    print(expense.distributedBetween!.values.toList());
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor:
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Text(expense.description!),
                  const SizedBox(height: 8),
                  Text(
                    '\$${expense.amount!.toString()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xffF4a74d),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Pagado por ${expense.paidBy!.values.elementAt(0)['name']}'),
                  const SizedBox(height: 8),
                  const Text('Cuánto gastó cada miembro:'),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: expense.distributedBetween!.length,
                    itemBuilder: (context, index) {
                      final item =
                          expense.distributedBetween!.values.elementAt(index);

                      return ListTile(
                        title: Text(item['name'].toString()),
                        trailing: Text(
                          '\$${item['to_pay'].toString()}',
                          style: const TextStyle(
                            color: Color(0xffF4a74d),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: Card(
        child: ListTile(
          //isThreeLine: true,
          //subtitle: Text('Pagado por ${paidBy.name}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  'Pagado por ${expense.paidBy!.values.elementAt(0)['name'] ?? 'miembro borrado'}'),
              Text(
                DateFormat.yMMMd().add_Hm().format(
                    DateTime.fromMillisecondsSinceEpoch(expense.timestamp!)),
              ),
              //SizedBox(height: 10),
            ],
          ),
          title: Text(
            expense.description!,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "\$${expense.amount!.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xffF4a74d),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          leading: Container(
            margin: const EdgeInsets.only(left: 10),
            height: double.infinity,
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Color(0xff0076FF),
            ),
          ),
        ),
      ),
    );
  }
}
