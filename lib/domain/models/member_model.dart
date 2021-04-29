import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'member_model.g.dart';

@HiveType(typeId: 1)
class Member {
  Member({
    this.id,
    this.balance = 0.00,
    this.checked = true,
    this.amountToPay = 0.00,
    this.weight = 1,
    this.controller,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
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
