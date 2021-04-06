import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/pages/home/groups_list.dart';
import 'package:repartapp/pages/home/widgets/side_menu.dart';
import 'package:repartapp/providers/groups_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GroupsProvider groupsProvider = GroupsProvider();

  final GlobalKey<FormState> formKeyCreateGroup = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyJoinGroup = GlobalKey<FormState>();

  Group group = Group();

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

        Group group = await groupsProvider.acceptInvitationGroup(groupId);

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

      Group group = await groupsProvider.acceptInvitationGroup(groupId);

      Navigator.pushNamed(context, '/group_details', arguments: group);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FlutterLogo(),
          ),
        ],
      ),
      body: GroupsList(),
      drawer: SideMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_rounded),
        onPressed: () => dialogCreateGroup(context),
      ),
    );
  }

  Future dialogCreateGroup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 65,
            child: Form(
              key: formKeyCreateGroup,
              child: TextFormField(
                onSaved: (value) {
                  group.name = value.trim();
                },
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
              onPressed: _submit,
            ),
          ],
        );
      },
    );
  }

  void _submit() async {
    if (!formKeyCreateGroup.currentState.validate()) return;

    formKeyCreateGroup.currentState.save();
    Get.back();

    bool resp = await groupsProvider
        .createGroup(group)
        .timeout(Duration(seconds: 5), onTimeout: () {
      Get.snackbar(
        'Error',
        'Error al crear el grupo',
        icon: Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xff25C0B7),
        ),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
        backgroundColor: Color(0xffee6c4d).withOpacity(0.1),
      );
      return;
    });

    if (resp == true) {
      Get.snackbar(
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
      setState(() {});
      return;
    } else {
      Get.snackbar(
        'Error',
        'Error al crear el grupo',
        icon: Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xffee6c4d),
        ),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
        backgroundColor: Color(0xffee6c4d).withOpacity(0.1),
      );
    }
  }

  void success(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grupo creado satisfactoriamente'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Back to the home page
            Navigator.pop(context);

            return;
          },
        ),
      ),
    );
  }

  void error(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xffe63946),
        content: Text('Error al crear grupo'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Back to the home page
            Navigator.of(context).pop();
            return;
          },
        ),
      ),
    );
  }
}
