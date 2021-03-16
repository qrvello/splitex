// To parse this JSON data, do
//
//     final member = memberFromJson(jsonString);

import 'dart:convert';

String memberToJson(Member data) => json.encode(data.toJson());

class Member {
  Member({
    this.id,
    this.balance,
  });

  String id;
  dynamic balance;

  factory Member.fromJson(Map<dynamic, dynamic> json, id) => Member(
        id: id,
        balance: json["balance"].toDouble(),
      );

  Map<dynamic, dynamic> toJson() => {
        "id": id,
        "balance": balance,
      };
}
