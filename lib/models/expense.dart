// To parse this JSON data, do
//
//     final expense = expenseFromJson(jsonString);

import 'dart:convert';

//Expense expenseFromJson(String str) => Expense.fromJson(json.decode(str));

String expenseToJson(Expense data) => json.encode(data.toJson());

class Expense {
  Expense({
    this.id,
    this.description,
    this.amount,
    this.paidBy,
  });
  String id;
  String description;
  dynamic amount;
  String paidBy;

  factory Expense.fromJson(Map<dynamic, dynamic> json, key) => Expense(
        id: key,
        description: json["description"],
        amount: json["amount"],
        paidBy: json["paid_by"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "amount": amount,
        "paid_by": paidBy,
      };
}
