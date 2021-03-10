import 'package:firebase_database/firebase_database.dart';
import 'package:repartapp/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final String emailUser = prefs.getString('email');

    if (snapshot.value != null) {
      final decodedData = new Map<String, dynamic>.from(snapshot.value);

      decodedData.forEach((key, value) {
        User user = User.fromJson(value, key);

        // Valida que no aparezca uno mismo
        if (user.email != emailUser) {
          users.add(user);
        }
      });
    }
    return users;
  }
}
