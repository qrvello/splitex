import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';

import 'member_model.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
class Transaction {
  Transaction({
    this.id,
    required this.memberToPay,
    required this.memberToReceive,
    required this.amountToPay,
    this.timestamp,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  Member memberToPay;

  @HiveField(2)
  Member memberToReceive;

  @HiveField(3)
  double amountToPay;

  @HiveField(4)
  int? timestamp;

  factory Transaction.fromMap(Map<dynamic, dynamic> map, id) {
    return Transaction(
      id: id,
      memberToPay: Member(id: map["member_to_pay"]),
      memberToReceive: map["member_to_receive"],
      amountToPay: map["amount_to_pay"].toDouble(),
      timestamp: map["timestamp"],
    );
  }

  Map<String, dynamic> toMap() => {
        "member_to_pay": memberToPay.id,
        "member_to_receive": memberToReceive.id,
        "amount_to_pay": amountToPay,
        "timestamp": ServerValue.timestamp,
      };
}
