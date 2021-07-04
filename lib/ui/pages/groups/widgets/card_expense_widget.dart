import 'package:flutter/material.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:intl/intl.dart';

class CardExpenseWidget extends StatelessWidget {
  const CardExpenseWidget({Key? key, required this.expense, this.paidBy})
      : super(key: key);
  final Expense expense;
  final Member? paidBy;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.black,
            child: Container(
              padding: EdgeInsets.all(25),
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    child: Text(expense.description!),
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
              Text('Pagado por ${paidBy?.name ?? 'miembro borrado'}'),
              Text(
                DateFormat('k:mm - EEEE d, MMMM, y', 'es_ES').format(
                  DateTime.fromMillisecondsSinceEpoch(expense.timestamp!),
                ),
              ),
              //SizedBox(height: 10),
            ],
          ),
          title: Text(
            expense.description!,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "\$${expense.amount!.toStringAsFixed(2)}",
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
      ),
    );
  }
}
