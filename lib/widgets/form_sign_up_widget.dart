//import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:gastos_grupales/bloc/login_bloc.dart';
//import 'package:gastos_grupales/bloc/provider.dart' as providerBloc;

//import 'package:gastos_grupales/provider/google_sign_in.dart';
//import 'package:gastos_grupales/provider/user_provider.dart';
//import 'package:provider/provider.dart';

//class FormSignUp extends StatelessWidget {
//  final userProvider = new UserProvider();

//  @override
//  Widget build(BuildContext context) {
//    final size = MediaQuery.of(context).size;
//    final bloc = providerBloc.Provider.of(context);

//    return SingleChildScrollView(
//      child: Column(
//        children: [
//          SafeArea(
//            child: Container(
//              height: 120.0,
//            ),
//          ),
//          Container(
//            width: size.width * 0.85,
//            margin: EdgeInsets.symmetric(vertical: 30.0),
//            padding: EdgeInsets.symmetric(vertical: 50.0),
//            decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.circular(5.0),
//              boxShadow: <BoxShadow>[
//                BoxShadow(
//                  color: Colors.black26,
//                  blurRadius: 3.0,
//                  offset: Offset(0.0, 2.0),
//                  spreadRadius: 1.0,
//                ),
//              ],
//            ),
//            child: Column(
//              children: <Widget>[
//                Text(
//                  'Registrate',
//                  style: TextStyle(fontSize: 20.0),
//                ),
//                SizedBox(height: 30.0),
//                _email(bloc),
//                SizedBox(height: 30.0),
//                _password(bloc),
//                SizedBox(height: 30.0),
//                _button(bloc),
//                _googleSignUpButton(context)
//              ],
//            ),
//          ),
//          FlatButton(
//            onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
//            child: Text('¿Ya te registraste? Iniciá sesión acá'),
//          ),
//          SizedBox(height: 100.0),
//        ],
//      ),
//    );
//  }

//  Widget _email(LoginBloc bloc) {
//    return StreamBuilder<Object>(
//        stream: bloc.emailStream,
//        builder: (BuildContext context, AsyncSnapshot snapshot) {
//          return Container(
//            padding: EdgeInsets.symmetric(horizontal: 20.0),
//            child: TextField(
//              keyboardType: TextInputType.emailAddress,
//              decoration: InputDecoration(
//                icon: Icon(Icons.alternate_email, color: Colors.deepPurple),
//                hintText: 'ejemplo@correo.com',
//                labelText: 'Correo electrónico',
//                counterText: snapshot.data,
//                errorText: snapshot.error,
//              ),
//              onChanged: bloc.changeEmail,
//            ),
//          );
//        });
//  }

//  Widget _password(LoginBloc bloc) {
//    return StreamBuilder<Object>(
//        stream: bloc.passwordStream,
//        builder: (BuildContext context, AsyncSnapshot snapshot) {
//          return Container(
//            padding: EdgeInsets.symmetric(horizontal: 20.0),
//            child: TextField(
//              obscureText: true,
//              decoration: InputDecoration(
//                icon: Icon(Icons.lock_outline, color: Colors.deepPurple),
//                labelText: 'Contraseña',
//                counterText: snapshot.data,
//                errorText: snapshot.error,
//              ),
//              onChanged: bloc.changePassword,
//            ),
//          );
//        });
//  }

//  Widget _button(LoginBloc bloc) {
//    return StreamBuilder<Object>(
//        stream: bloc.formValidStream,
//        builder: (BuildContext context, AsyncSnapshot snapshot) {
//          return OutlineButton(
//            onPressed: snapshot.hasData ? () => _register(bloc, context) : null,
//            child: Container(
//              child: Text('Registrarse'),
//              padding: EdgeInsets.symmetric(horizontal: 55),
//            ),
//            shape: StadiumBorder(),
//            borderSide: BorderSide(color: Colors.black),
//            textColor: Colors.black,
//          );
//        });
//  }

//  Widget _googleSignUpButton(context) {
//    return Container(
//      padding: EdgeInsets.all(4),
//      child: OutlineButton.icon(
//        onPressed: () {
//          final provider =
//              Provider.of<GoogleSignInProvider>(context, listen: false);
//          provider.login();
//        },
//        icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
//        label: Text('Iniciá sesión con Google'),
//        shape: StadiumBorder(),
//        borderSide: BorderSide(color: Colors.black),
//        padding: EdgeInsets.symmetric(horizontal: 20),
//        textColor: Colors.black,
//      ),
//    );
//  }

//  _register(LoginBloc bloc, BuildContext context) async {
//    Map info = await userProvider.register(bloc.email, bloc.password);
//    if (info['ok']) {
//      Navigator.pushReplacementNamed(context, 'home');
//    } else {
//      showDialog(
//          context: context,
//          builder: (context) {
//            return AlertDialog(
//              title: Text('Los datos ingresados son incorrectos.'),
//              content: Text(info['message']),
//              actions: <Widget>[
//                FlatButton(
//                    onPressed: () => Navigator.of(context).pop(),
//                    child: Text('Ok'))
//              ],
//            );
//          });
//    }
//  }
//}
