import 'package:firebase_database/firebase_database.dart';

class Expense {
  Expense({
    this.id,
    this.description,
    this.amount,
    this.paidBy,
    this.timestamp,
  });

  String id;
  String description;
  double amount;
  String paidBy;
  int timestamp;

  factory Expense.fromMap(Map<dynamic, dynamic> map, id) => Expense(
        id: id,
        description: map["description"],
        amount: map["amount"].toDouble(),
        paidBy: map["paid_by"],
        timestamp: map["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "description": description,
        "amount": amount,
        "paid_by": paidBy,
        "timestamp": ServerValue.timestamp
      };
}
