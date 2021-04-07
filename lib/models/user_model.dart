import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  final Box box = Hive.box('user');

  User({
    this.id,
    this.email,
    this.name,
    this.photoURL,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String email;
  @HiveField(2)
  String name;
  @HiveField(3)
  String photoURL;

  factory User.fromMap(Map<dynamic, dynamic> json, key) => User(
        email: json["email"],
        name: json["name"],
        id: key,
      );

  Map<String, dynamic> toMap() => {
        "email": email,
        "name": name,
        "id": id,
      };
}
