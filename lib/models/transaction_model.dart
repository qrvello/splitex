import 'package:firebase_database/firebase_database.dart';

import 'member_model.dart';

class Transaction {
  Transaction({
    this.id,
    this.memberToPay,
    this.memberToReceive,
    this.amountToPay,
    this.timestamp = 0,
  });

  String id;
  Member memberToPay;
  Member memberToReceive;
  double amountToPay;
  int timestamp;

  factory Transaction.fromMap(Map<dynamic, dynamic> map, id) {
    Member memberToPay = Member();
    memberToPay.id = map["member_to_pay"];
    Member memberToReceive = Member();
    memberToReceive.id = map["member_to_receive"];

    return Transaction(
      id: id,
      memberToPay: memberToPay,
      memberToReceive: memberToReceive,
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