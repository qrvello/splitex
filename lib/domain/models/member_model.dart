import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'member_model.g.dart';

@HiveType(typeId: 1)
class Member {
  Member({
    this.name,
    this.newName,
    this.id,
    this.balance = 0.00,
    this.checked = true,
    this.amountToPay = 0.00,
    this.weight = 1,
    this.controller,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  double balance;

  String id;
  String newName;
  double amountToPay;
  int weight;
  bool checked;
  TextEditingController controller;

  factory Member.fromMap(Map<dynamic, dynamic> json, id) => Member(
        id: id,
        name: json['name'],
        balance: json['balance'].toDouble(),
      );

  Map<dynamic, dynamic> toMap() => {
        "name": name,
        "balance": balance.toStringAsFixed(2),
      };
}
