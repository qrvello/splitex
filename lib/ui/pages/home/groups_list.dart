import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:splitex/domain/cubits/auth/auth_cubit.dart';
import 'package:splitex/domain/cubits/auth/auth_state.dart';

import 'package:splitex/domain/cubits/groups/groups_list/groups_list_state.dart';
import 'package:splitex/domain/cubits/groups/groups_list/groups_list_online_cubit.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:splitex/domain/repositories/groups_repository_offline.dart';
import 'package:splitex/ui/pages/groups/details_group_page.dart';

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  bool? online;

  List<Group> groupsOnline = [];

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        _groupsOnline(),
        _groupsOffline(),
      ],
    );
  }

  ValueListenableBuilder<Box<Group>> _groupsOffline() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Group>('groups').listenable(),
      builder: (BuildContext context, Box<Group> box, widget) {
        online = false;

        List<Group> groups = box.values.toList();

        groups.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));

        if (groups.length > 0) {
          return _groupsListsLoaded(context, groups);
        } else {
          return MessageNonGroups();
        }
      },
    );
  }

  Widget _groupsOnline() {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, auth) async {
        if (auth is AuthLoggedOut) {
          await context.read<AuthCubit>().signInAnonymously();
        }
        if (auth is AuthError) {
          await context.read<AuthCubit>().init();
        }
      },
      builder: (context, auth) {
        online = true;

        if (auth is AuthLoggedInAnonymously || auth is AuthLoggedInWithGoogle) {
          return BlocProvider(
            create: (context) => GroupsListOnlineCubit(
              context.read<GroupsRepository>(),
            )..init(),
            child: BlocBuilder<GroupsListOnlineCubit, GroupsListState>(
              builder: (BuildContext context, GroupsListState state) {
                return _groupsListCubitBuilder(context, state);
              },
            ),
          );
        }
        return buildLoading();
      },
    );
  }

  Widget _groupsListCubitBuilder(BuildContext context, state) {
    if (state is GroupListError) {
      return ErrorLoadingGroups();
    }

    if (state is GroupListLoading) {
      return buildLoading();
    }

    if (state is GroupsListLoaded) {
      return _groupsListsLoaded(context, state.groups);
    }

    return MessageNonGroups();
  }

  Widget _groupsListsLoaded(BuildContext context, List<Group> groups) {
    return ListView.separated(
      separatorBuilder: (context, i) => const Divider(height: 1),
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: context.height * 0.1),
      itemCount: groups.length,
      itemBuilder: (context, int i) => _createItem(context, groups[i]),
    );
  }

  Center buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _createItem(BuildContext context, Group group) {
    return Column(
      children: [
        ListTile(
          trailing: IconButton(
            icon: Icon(Icons.delete),
            color: (context.isDarkMode) ? Colors.white : Colors.black,
            onPressed: () => showDialog(
              context: context,
              builder: (context) => _confirmDeleteDialog(context, group),
            ),
          ),
          title: Text(group.name!),
          onTap: () => Get.to(
            () => DetailsGroupPage(),
            arguments: {
              'group': group,
              'online': online,
            },
          ),
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }

  Widget _confirmDeleteDialog(BuildContext context, Group group) {
    return AlertDialog(
      title: Text('Confirmar eliminación'),
      content: Text(
          '¿Seguro/a deseas borrar el grupo ${group.name}? Una vez eliminado no se podrá recuperar la información'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => _deleteGroup(context, group),
          child: Text(
            'Confirmar',
            style: TextStyle(color: Color(0xffe76f51)),
          ),
        ),
      ],
    );
  }

  Future<dynamic> _deleteGroup(BuildContext context, Group group) async {
    if (online == true) {
      bool result = await context.read<GroupsRepository>().deleteGroup(group);

      if (result == true) {
        Navigator.of(context).pop(true);

        snackbarSuccess(context);
      } else {
        Navigator.of(context).pop(false);

        snackbarError();
      }
    } else {
      Navigator.of(context).pop(true);

      snackbarSuccess(context);

      await RepositoryProvider.of<GroupsRepositoryOffline>(context)
          .deleteGroup(group);
    }
  }

  void snackbarSuccess(BuildContext context) {
    Get.snackbar(
      'Acción exitosa',
      'Grupo borrado satisfactoriamente',
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      //isDismissible: true,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError() {
    Get.snackbar(
      'Error',
      'Error al borrar el grupo',
      icon: Icon(
        Icons.error_outline_rounded,
        color: Color(0xffee6c4d),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Color(0xffee6c4d).withOpacity(0.1),
    );
  }
}

class ErrorLoadingGroups extends StatelessWidget {
  const ErrorLoadingGroups({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Ha ocurrido un error al cargar tus grupos.'),
    );
  }
}

class MessageNonGroups extends StatelessWidget {
  const MessageNonGroups({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No participás de ningún grupo',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
