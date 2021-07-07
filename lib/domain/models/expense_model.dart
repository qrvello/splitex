import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveField(0)
@HiveType(typeId: 3)
class Expense {
  Expense({
    this.id,
    this.description,
    this.amount,
    this.paidBy,
    this.timestamp,
    this.distributedBetween,
  });

  @HiveField(0)
  String? id;

  @HiveField(1)
  String? description;

  @HiveField(2)
  double? amount;

  @HiveField(3)
  String? paidBy;

  @HiveField(4)
  int? timestamp;

  Map<dynamic, dynamic>? distributedBetween;

  factory Expense.fromMap(Map<dynamic, dynamic> map, id) => Expense(
        id: id as String,
        description: map["description"].toString(),
        amount: map["amount"].toDouble() as double?,
        paidBy: map["paid_by"].toString(),
        timestamp: map["timestamp"] as int,
        distributedBetween: map["distributed_between"] as Map<dynamic, dynamic>,
      );

  Map<String, dynamic> toMap() => {
        "description": description,
        "amount": amount,
        "paid_by": paidBy,
        "timestamp": ServerValue.timestamp,
        "distributed_between": distributedBetween,
      };
}
