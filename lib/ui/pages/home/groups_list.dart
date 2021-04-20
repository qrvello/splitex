import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:repartapp/domain/cubits/auth/auth_cubit.dart';
import 'package:repartapp/domain/cubits/auth/auth_state.dart';
import 'package:repartapp/domain/cubits/groups/groups_list/groups_list_cubit.dart';
import 'package:repartapp/domain/cubits/groups/groups_list/groups_list_state.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';

class GroupsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        if (auth is AuthLoggedInAnonymously || auth is AuthLoggedInWithGoogle) {
          return BlocProvider(
            create: (context) =>
                GroupsListCubit(context.read<GroupsRepository>())..init(),
            child: BlocBuilder<GroupsListCubit, GroupsListState>(
              builder: (BuildContext context, GroupsListState state) {
                if (state is GroupListError) {
                  return Center(
                    child: Text('Ha ocurrido un error al cargar tus grupos.'),
                  );
                }

                if (state is GroupListLoading) {
                  return buildLoading();
                }

                if (state is GroupListLoaded) {
                  return Column(
                    children: [
                      Divider(
                        height: 1,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding:
                              EdgeInsets.only(bottom: context.height * 0.1),
                          itemCount: state.groups.length,
                          itemBuilder: (_, i) =>
                              _createItem(context, state.groups[i]),
                        ),
                      ),
                    ],
                  );
                }

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
              },
            ),
          );
        }
        return buildLoading();
      },
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
        Dismissible(
          // Al deslizar muestra un cuadro de diálogo pidiendo confirmación
          confirmDismiss: (_) => showDialog(
            context: context,
            builder: (_) => _confirmDeleteDialog(_, group),
          ),

          key: UniqueKey(),
          background: Container(
            decoration: BoxDecoration(
              color: Color(0xffE29578),
            ),
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          direction: DismissDirection.endToStart,
          child: ListTile(
            title: Hero(
              child: Text(
                group.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              tag: group.id,
            ),
            onTap: () => Navigator.pushNamed(
              context,
              '/group_details',
              arguments: group,
            ),
            trailing: Icon(
              Icons.circle,
              size: 10,
              color: Color(0xff06d6a0),
            ),
          ),
        ),
        Divider(
          height: 0,
        ),
      ],
    );
  }

  Widget _confirmDeleteDialog(BuildContext context, group) {
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
          onPressed: () {
            _deleteGroup(context, group);
          },
          child: Text(
            'Confirmar',
            style: TextStyle(color: Color(0xffe76f51)),
          ),
        ),
      ],
    );
  }

  void _deleteGroup(BuildContext context, group) async {
    bool result = await context.read<GroupsRepository>().deleteGroup(group);

    if (result == true) {
      Navigator.of(context).pop(result);
      snackbarSuccess(context);
    } else {
      Navigator.of(context).pop(result);

      snackbarError();
    }
  }

  void snackbarSuccess(BuildContext context) {
    return Get.snackbar(
      'Acción exitosa',
      'Grupo borrado satisfactoriamente',
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError() {
    return Get.snackbar(
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
