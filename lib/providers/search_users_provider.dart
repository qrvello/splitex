import 'package:firebase_database/firebase_database.dart';
import 'package:repartapp/models/user_model.dart';

class SearchUsersProvider {
  final databaseReference = FirebaseDatabase.instance.reference();

  Future getUserByEmail(String email) async {
    List<User> users = [];

    DataSnapshot snapshot = await databaseReference
        .child('users')
        .orderByChild('email')
        .startAt(email)
        .limitToFirst(10)
        .once();

    if (snapshot.value != null) {
      final decodedData = new Map<String, dynamic>.from(snapshot.value);

      decodedData.forEach((key, value) {
        User user = User.fromJson(value, key);
        users.add(user);
      });
    }
    return users;
  }
}
