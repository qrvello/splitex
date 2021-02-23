import 'dart:convert';

import 'package:gastos_grupales/models/group_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class GroupsProvider {
  final String _url =
      'https://gastos-grupales-4b8a6-default-rtdb.firebaseio.com/';

  Future<bool> createGroup(GroupModel group) async {
    final idToken = await FirebaseAuth.instance.currentUser.getIdToken();

    final url = '$_url/groups.json?auth=$idToken';

    await http.post(url, body: groupModelToJson(group));

    return true;
  }

  Future<List<GroupModel>> loadGroups() async {
    final idToken = await FirebaseAuth.instance.currentUser.getIdToken();

    final url = '$_url/groups.json?auth=$idToken';
    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<GroupModel> productos = new List();

    if (decodedData == null) return [];

    decodedData.forEach((id, producto) {
      final prodTemp = GroupModel.fromJson(producto);
      prodTemp.id = id;

      productos.add(prodTemp);
    });

    return productos;
  }
}
