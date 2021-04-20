import 'package:flutter/material.dart';

class Member {
  Member({
    this.id,
    this.balance,
    this.checked = true,
    this.amountToPay = 0.00,
    this.weight = 1,
    this.controller,
  });

  String id;
  double balance;
  double amountToPay;
  int weight;
  bool checked;
  TextEditingController controller;

  factory Member.fromMap(Map<dynamic, dynamic> json, id) => Member(
        id: id,
        balance: json['balance'].toDouble(),
      );

  Map<dynamic, dynamic> toJson() => {
        "id": id,
        "balance": balance.toStringAsFixed(2),
      };
}
