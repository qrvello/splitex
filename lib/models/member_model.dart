class Member {
  Member({
    this.id,
    this.balance,
  });

  String id;
  double balance;

  factory Member.fromMap(Map<dynamic, dynamic> json, id) => Member(
        id: id,
        balance: json['balance'].toDouble(),
      );

  Map<dynamic, dynamic> toJson() => {
        "id": id,
        "balance": balance.toStringAsFixed(2),
      };
}
