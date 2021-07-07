import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
import 'package:splitex/domain/repositories/groups_repository_offline.dart';
import 'package:splitex/ui/pages/groups/details_group_page.dart';
import 'package:splitex/ui/pages/home/groups_list.dart';
import 'package:splitex/ui/pages/home/widgets/side_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKeyCreateGroup = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null && deepLink.queryParameters.containsKey('id')) {
        final String groupId = deepLink.queryParameters['id']!;
        try {
          final Group group = await context
              .read<GroupsRepository>()
              .acceptInvitationGroup(groupId);

          Get.to(
            () => DetailsGroupPage(),
            arguments: {
              'group': group,
              'online': true,
            },
          );
        } catch (e) {
          print(e.toString());
          snackbarError('Error', 'Error al unirse al grupo');
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
      snackbarError('Error', 'Error al unirse al grupo');
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri? deepLink = data?.link;

    if (deepLink != null && deepLink.queryParameters.containsKey('id')) {
      final String groupId = deepLink.queryParameters['id']!;
      try {
        final Group group = await context
            .read<GroupsRepository>()
            .acceptInvitationGroup(groupId);

        Get.to(
          () => DetailsGroupPage(),
          arguments: {
            'group': group,
            'online': true,
          },
        );
      } catch (e) {
        snackbarError('Error', 'Error al unirse al grupo');
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grupos'),
          actions: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: FlutterLogo(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                child: Icon(
                  Icons.cloud_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Tab(
                child: Icon(
                  Icons.cloud_off_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        body: GroupsList(),
        drawer: SideMenu(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: buildSpeedDial(context),
      ),
    );
  }

  SpeedDial buildSpeedDial(BuildContext context) {
    return SpeedDial(
      marginEnd: 32,
      backgroundColor: const Color(0xff0076FF).withOpacity(0.87),
      overlayColor: Theme.of(context).scaffoldBackgroundColor,
      icon: Icons.add_rounded,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.cloud_rounded),
          backgroundColor: Theme.of(context).accentColor,
          labelWidget: const Text(
            'Crear un grupo con conexión',
            style: TextStyle(fontSize: 18),
          ),
          onTap: () => dialogCreateGroup(context, online: true),
        ),
        SpeedDialChild(
          child: const Icon(Icons.cloud_off_rounded),
          backgroundColor: Theme.of(context).accentColor,
          labelWidget: const Text(
            'Crear un grupo sin conexión',
            style: TextStyle(fontSize: 18),
          ),
          onTap: () => dialogCreateGroup(context, online: false),
        ),
      ],
    );
  }

  Future dialogCreateGroup(BuildContext context, {required bool online}) {
    final TextEditingController _newGroupController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: formKeyCreateGroup,
            child: TextFormField(
              controller: _newGroupController,
              autofocus: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 20,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                errorMaxLines: 3,
                labelText: 'Nombre del grupo',
              ),
              validator: (value) {
                if (value == null) {
                  return 'Ingrese el nombre del grupo nuevo';
                }
                if (value.trim().length > 20) {
                  return 'Ingrese un nombre menor a 20 caracteres';
                }
                return null;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => states.contains(MaterialState.pressed)
                      ? const Color(0xffE29578)
                      : const Color(0xffee6c4d),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _submit(context, online, _newGroupController),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit(BuildContext context, bool online,
      TextEditingController _controller) async {
    if (!formKeyCreateGroup.currentState!.validate()) return;

    Get.back();

    final Group group = Group();

    group.name = _controller.text.trim();

    try {
      if (online) {
        await context.read<GroupsRepository>().createGroup(group);
      } else {
        await context.read<GroupsRepositoryOffline>().createGroup(group);
      }

      snackbarSuccess();
    } catch (e) {
      snackbarError('Error', 'Error al crear grupo: ${e.toString()}');
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Grupo creado satisfactoriamente',
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError(String title, String message) {
    return Get.snackbar(
      title,
      message,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Color(0xffee6c4d),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: const Color(0xffee6c4d).withOpacity(0.1),
    );
  }
}
