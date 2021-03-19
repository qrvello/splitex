// To parse this JSON data, do
//
//     final expense = expenseFromJson(jsonString);

import 'package:firebase_database/firebase_database.dart';

//Expense expenseFromJson(String str, key) =>
//    Expense.fromJson(json.decode(str), key);

//String expenseToJson(Expense data) => json.encode(data.toJson());

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
  dynamic amount;
  String paidBy;
  int timestamp;

  factory Expense.fromMap(Map<dynamic, dynamic> map, id) => Expense(
        id: id,
        description: map["description"],
        amount: map["amount"],
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
