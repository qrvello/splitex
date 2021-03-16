import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/user_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

import 'package:repartapp/providers/search_users_provider.dart';

class UserSearchDelegate extends SearchDelegate<User> {
  @override
  final String searchFieldLabel = 'Buscar por email';

  List<User> users = [];

  final searchUsersProvider = new SearchUsersProvider();

  final groupProvider = new GroupsProvider();

  GroupModel group;

  UserSearchDelegate(this.group);

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

    return FutureBuilder(
      future: searchUsersProvider.getUserByEmail(query),
      builder: (_, snapshot) {
        if (snapshot.hasData && snapshot.data != []) {
          // crear la lista
          return _showUsers(snapshot.data);
        }
        //if (snapshot.connectionState == ConnectionState.active) {
        //  // Loading
        //  return Center(child: CircularProgressIndicator());
        //}

        return Center(
          child: Text(
            'No hay resultados',
            style: TextStyle(color: Colors.white),
          ),
        );
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
            icon: Icon(Icons.add_rounded),
            onPressed: () async {
              final bool resp = await groupProvider.addUserToGroup(user, group);
              if (resp == false) {
                return _error(context);
              }
              return _success(context);
            },
          ),
          onTap: () {
            this.close(context, user);
          },
        );
      },
    );
  }

  _success(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xff2a9d8f),
        content: Text(
          'Invitación enviada correctamente',
          style: TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Ok',
          onPressed: () {
            // Back to the group details page
            Navigator.pop(context);

            return;
          },
        ),
      ),
    );
  }

  _error(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xffe63946),
        content: Text(
          'Error invitando al usuario',
          style: TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          textColor: Colors.white,
          label: 'Ok',
          onPressed: () {
            // Back to group details page
            Navigator.of(context).pop();
            return;
          },
        ),
      ),
    );
  }
}
