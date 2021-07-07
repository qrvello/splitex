import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'member_model.g.dart';

@HiveType(typeId: 1)
class Member {
  Member({
    this.name,
    this.id,
    this.balance = 0.00,
    this.checked = true,
    this.amountToPay = 0.00,
    this.weight = 1,
    this.controller,
  });

  @HiveField(0)
  String? name;

  @HiveField(1)
  double balance;

  String? id;
  String? newName;
  double? amountToPay;
  int? weight;
  bool? checked;
  TextEditingController? controller;

  factory Member.fromMap(Map<dynamic, dynamic> json, id) => Member(
        id: id as String,
        name: json['name'] as String,
        balance: json['balance'].toDouble().roundToDouble() as double,
      );

  Map<dynamic, dynamic> toMap() => {
        "name": name,
        "balance": double.parse(balance.toStringAsFixed(2)),
      };
}
