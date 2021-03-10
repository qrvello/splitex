import 'package:flutter/material.dart';
import 'package:repartapp/models/user_model.dart';

import 'package:repartapp/providers/search_users_provider.dart';

class UserSearchDelegate extends SearchDelegate<User> {
  @override
  final String searchFieldLabel = 'Buscar por email';
  List<User> users = [];
  final searchUsersProvider = new SearchUsersProvider();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () => this.query = '')
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => this.close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().length == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text(
            'Por favor ingresa un email de un usuario registrado en la aplicación.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // query!
    return FutureBuilder(
      future: searchUsersProvider.getUserByEmail(query),
      builder: (_, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return ListTile(title: Text('No hay nada con ese término'));
        }

        if (snapshot.hasData && snapshot.data != []) {
          // crear la lista
          return _showUsers(snapshot.data);
        } else {
          // Loading
          return Center(child: CircularProgressIndicator(strokeWidth: 4));
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _showUsers(this.users);
  }

  Widget _showUsers(List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, i) {
        final user = users[i];

        return ListTile(
          title: Text(user.email),
          subtitle: Text(user.name),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          onTap: () {
            // print( pais );
            this.close(context, user);
          },
        );
      },
    );
  }
}
