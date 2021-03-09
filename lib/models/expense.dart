// To parse this JSON data, do
//
//     final expense = expenseFromJson(jsonString);

import 'dart:convert';

Expense expenseFromJson(String str) => Expense.fromJson(json.decode(str));

String expenseToJson(Expense data) => json.encode(data.toJson());

class Expense {
  Expense({
    this.description,
    this.amount,
    this.paidBy,
  });

  String description;
  double amount;
  String paidBy;

  factory Expense.fromJson(Map<dynamic, dynamic> json) => Expense(
        description: json["description"],
        amount: json["amount"],
        paidBy: json["paid_by"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "amount": amount,
        "paid_by": paidBy,
      };
}
