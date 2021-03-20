import 'member_model.dart';

class Transaction {
  Transaction({
    this.id,
    this.memberToPay,
    this.memberToReceive,
    this.amountToPay,
  });

  String id;
  Member memberToPay;
  Member memberToReceive;
  double amountToPay;

  factory Transaction.fromMap(Map<dynamic, dynamic> map, id) => Transaction(
        id: id,
        memberToPay: map["member_to_pay"],
        memberToReceive: map["member_to_receive"],
        amountToPay: map["amount_to_pay"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "member_to_pay": memberToPay,
        "member_to_receive": memberToReceive,
        "amount_to_pay": amountToPay,
      };
}
