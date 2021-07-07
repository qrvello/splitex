import 'package:flutter/material.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'package:intl/intl.dart';

class CardTransactionWidget extends StatelessWidget {
  const CardTransactionWidget({
    Key? key,
    required this.transaction,
    this.memberToPay,
    this.memberToReceive,
  }) : super(key: key);

  final Transaction transaction;
  final Member? memberToPay;
  final Member? memberToReceive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
            "${memberToPay?.name ?? 'miembro borrado'} le pagó a ${memberToReceive?.name ?? 'miembro borrado'}"),
        trailing: Text(
          '\$${transaction.amountToPay.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xff25C0B7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          DateFormat('k:mm - EEEE d, MMMM, y', 'es_ES').format(
            DateTime.fromMillisecondsSinceEpoch(transaction.timestamp!),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          height: double.infinity,
          child: const Icon(
            Icons.arrow_right_alt_rounded,
            color: Color(0xff0076FF),
          ),
        ),
      ),
    );
  }
}
