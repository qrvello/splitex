import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:repartapp/domain/models/group_model.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';
import 'package:repartapp/domain/repositories/groups_repository_offline.dart';
import 'package:repartapp/ui/pages/home/groups_list.dart';
import 'package:repartapp/ui/pages/home/widgets/side_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKeyCreateGroup = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyJoinGroup = GlobalKey<FormState>();

  final TextEditingController _newGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();

    this.initDynamicLinks();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      if (deepLink != null && deepLink.queryParameters.containsKey('id')) {
        String groupId = deepLink.queryParameters['id'];

        Group group = await context
            .read<GroupsRepository>()
            .acceptInvitationGroup(groupId);

        Navigator.pushNamed(context, '/group_details', arguments: group);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null && deepLink.queryParameters.containsKey('id')) {
      String groupId = deepLink.queryParameters['id'];

      Group group =
          await context.read<GroupsRepository>().acceptInvitationGroup(groupId);

      Navigator.pushNamed(context, '/group_details', arguments: group);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Grupos'),
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: FlutterLogo(),
            ),
          ],
          bottom: TabBar(
            isScrollable: false,
            tabs: [
              Tab(
                child: Text('Online'),
              ),
              Tab(
                child: Text('Offline'),
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
      backgroundColor: Color(0xff0076FF).withOpacity(0.87),
      overlayColor: Theme.of(context).scaffoldBackgroundColor,
      icon: Icons.add_rounded,
      visible: true,
      children: [
        SpeedDialChild(
          child: Icon(Icons.cloud_rounded),
          backgroundColor: Theme.of(context).accentColor,
          labelWidget: Text(
            'Crear grupo online',
            style: TextStyle(fontSize: 18),
          ),
          onTap: () => dialogCreateGroup(context, true),
        ),
        SpeedDialChild(
          child: Icon(Icons.cloud_off_rounded),
          backgroundColor: Theme.of(context).accentColor,
          labelWidget: Text(
            'Crear grupo offline',
            style: TextStyle(fontSize: 18),
          ),
          onTap: () => dialogCreateGroup(context, false),
        ),
      ],
    );
  }

  Future dialogCreateGroup(BuildContext context, bool online) {
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
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                errorMaxLines: 3,
                labelText: 'Nombre del grupo',
              ),
              validator: (value) {
                if (value.trim().length < 1) {
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
                  (states) => (states.contains(MaterialState.pressed)
                      ? Color(0xffE29578)
                      : Color(0xffee6c4d)),
                ),
              ),
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () => _submit(context, online),
            ),
          ],
        );
      },
    );
  }

  void _submit(BuildContext context, bool online) async {
    if (!formKeyCreateGroup.currentState.validate()) return;

    Get.back();

    Group group = Group();

    group.name = _newGroupController.text.trim();

    _newGroupController.text = '';

    bool result;

    if (online == true) {
      result = await context.read<GroupsRepository>().createGroup(group);
    } else {
      result = await context.read<GroupsRepositoryOffline>().createGroup(group);
    }

    if (result == true) {
      snackbarSuccess();
    } else {
      snackbarError();
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Grupo creado satisfactoriamente',
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
      'Error al crear el grupo',
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
