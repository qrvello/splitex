import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:repartapp/pages/home/widgets/drawer_header_widget.dart';
import 'package:repartapp/pages/users/widgets/google_sign_up_button_widget.dart';
import 'package:repartapp/providers/theme_provider.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool darkTheme = true;
  @override
  void initState() {
    Box box = Hive.box('theme');

    if (box.get('isDark') != null) {
      darkTheme = box.get('isDark');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        children: <Widget>[
          _drawer(context),
          ListTile(
            leading: Icon(Icons.share_rounded),
            title: Text('Invitar a un amigo'),
          ),
          ListTile(
            leading: Icon(Icons.star_rate_rounded),
            title: Text('Opiná de la aplicación'),
          ),
          SwitchListTile(
            activeColor: Theme.of(context).primaryColor,
            value: darkTheme,
            secondary: FaIcon(FontAwesomeIcons.moon),
            title: Text('Modo noche'),
            onChanged: (bool value) {
              setState(() {
                darkTheme = value;
              });
              themeProvider.switchTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawer(context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (FirebaseAuth.instance.currentUser == null) {
          return DrawerHeader(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: GoogleSignUpButtonWidget(),
              ),
            ),
          );
        } else {
          return DrawerHeaderWidget();
        }
      },
    );
  }
}
