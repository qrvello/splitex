import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:splitex/domain/cubits/auth/auth_cubit.dart';
import 'package:splitex/domain/cubits/auth/auth_state.dart';
import 'package:splitex/domain/cubits/app_theme_cubit.dart';
import 'package:splitex/ui/pages/home/widgets/drawer_header_widget.dart';
import 'package:splitex/ui/pages/users/profile_page.dart';
import 'package:splitex/ui/pages/users/widgets/google_sign_up_button_widget.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          _drawerHeader(context),
          ListTile(
            leading: Icon(Icons.person_rounded),
            title: Text('Mi perfil'),
            onTap: () {
              Get.to(() => ProfilePage());
            },
          ),
          ListTile(
            leading: Icon(Icons.share_rounded),
            title: Text('Invitar a un amigo'),
          ),
          ListTile(
            leading: Icon(Icons.star_rate_rounded),
            title: Text('Opiná de la aplicación'),
          ),
          BlocBuilder<AppThemeCubit, bool>(
            builder: (context, isDark) {
              return SwitchListTile(
                activeColor: Theme.of(context).primaryColor,
                value: isDark,
                secondary: FaIcon(FontAwesomeIcons.moon),
                title: Text('Modo noche'),
                onChanged: (bool value) {
                  context.read<AppThemeCubit>().switchTheme(value);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerHeader(context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, AuthState auth) {
        if (auth is AuthLoggedInWithGoogle) {
          return DrawerHeaderWidget(auth.user);
        }

        return DrawerHeader(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: GoogleSignUpButtonWidget(),
            ),
          ),
        );
      },
    );
  }
}
