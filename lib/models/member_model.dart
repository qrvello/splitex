// To parse this JSON data, do
//
//     final member = memberFromJson(jsonString);

import 'dart:convert';

String memberToJson(Member data) => json.encode(data.toJson());

class Member {
  Member({
    this.id,
    this.balance,
    //this.debt,
  });

  String id;
  dynamic balance;
  //dynamic debt;

  factory Member.fromMap(Map<dynamic, dynamic> json, id) => Member(
        id: id,
        balance: json["balance"].toDouble(),
        //debt: json["debt"].toDouble(),
      );

  Map<dynamic, dynamic> toJson() => {
        "id": id,
        "balance": balance,
        //"debt": debt,
      };
}
