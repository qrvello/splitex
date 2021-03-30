import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

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
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
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
      floatingActionButton: speedDial(context),
    );
  }

  SpeedDial speedDial(BuildContext context) {
    return SpeedDial(
      backgroundColor: Color(0xff0076FF).withOpacity(0.87),
      overlayColor: Colors.black12,
      icon: Icons.add_rounded,
      activeIcon: Icons.add_rounded,
      visible: true,
      children: [
        buttonCreateGroup(context),
        buttonJoinGroup(context),
      ],
    );
  }

  SpeedDialChild buttonJoinGroup(BuildContext context) {
    return SpeedDialChild(
      child: Icon(Icons.keyboard_arrow_right_rounded),
      backgroundColor: Colors.white10,
      labelWidget: Text(
        'Unirse a un grupo',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  SpeedDialChild buttonCreateGroup(BuildContext context) {
    return SpeedDialChild(
      child: Icon(Icons.group_rounded),
      backgroundColor: Colors.white10,
      labelWidget: Text(
        'Crear grupo',
        style: TextStyle(fontSize: 18),
      ),
      onTap: () => dialogCreateGroup(context),
    );
  }

  Future dialogCreateGroup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xff212529),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(18.0),
            ),
          ),
          content: Container(
            height: 65,
            child: Form(
              key: formKeyCreateGroup,
              child: TextFormField(
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
                controller: _groupNameController,
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
                _groupNameController.clear();
              },
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () async {
                if (!formKeyCreateGroup.currentState.validate()) return;

                Group group = Group();

                group.name = _groupNameController.text.trim();

                bool resp = await groupsProvider.createGroup(group);

                _groupNameController.clear();
                Navigator.pop(context);

                (resp == true) ? success(context) : error(context);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Future dialogJoinGroup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xff212529),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(18.0),
            ),
          ),
          content: Container(
            height: 65,
            child: Form(
              key: formKeyJoinGroup,
              child: TextFormField(
                autofocus: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLength: 20,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  errorMaxLines: 3,
                  labelText: 'Link del grupo a unirse',
                ),
                validator: (value) {
                  if (value.trim().length < 1) {
                    return 'Ingrese el link del grupo';
                  }
                  // TODO expresion regular para aceptar links validos
                  return null;
                },
                controller: _linkController,
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
                _linkController.clear();
              },
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () async {
                //if (!formKeyJoinGroup.currentState.validate()) return;

                //String groupId = deepLink.queryParameters['id'];

                //Group group =
                //    await groupsProvider.acceptInvitationGroup(groupId);

                //Navigator.pushNamed(context, '/group_details',
                //    arguments: group);

                // TODO Join group
              },
            ),
          ],
        );
      },
    );
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
