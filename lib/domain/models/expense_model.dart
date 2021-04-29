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
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String paidBy;

  @HiveField(4)
  int timestamp;

  factory Expense.fromMap(Map<dynamic, dynamic> map, id) => Expense(
        id: id,
        description: map["description"],
        amount: map["amount"].toDouble(),
        paidBy: map["paid_by"],
        timestamp: map["timestamp"],
      );

  Map<String, dynamic> toMap() => {
        "description": description,
        "amount": amount,
        "paid_by": paidBy,
        "timestamp": ServerValue.timestamp
      };
}
