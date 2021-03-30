class User {
  User({
    this.email,
    this.name,
    this.id,
  });

  String email;
  String name;
  String id;

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
