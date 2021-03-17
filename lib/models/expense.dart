// To parse this JSON data, do
//
//     final expense = expenseFromJson(jsonString);

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

Expense expenseFromJson(String str, key) =>
    Expense.fromJson(json.decode(str), key);

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

  factory Expense.fromJson(Map<dynamic, dynamic> json, key) => Expense(
        id: key,
        description: json["description"],
        amount: json["amount"],
        paidBy: json["paid_by"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "description": description,
        "amount": amount,
        "paid_by": paidBy,
        "timestamp": ServerValue.timestamp
      };
}
