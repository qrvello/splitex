import 'package:flutter/material.dart';
import 'package:gastos_grupales/bloc/provider.dart';
import 'package:gastos_grupales/provider/user_provider.dart';
import 'package:gastos_grupales/widgets/google_sign_up_button_widget.dart';

class FormLogIn extends StatelessWidget {
  final userProvider = new UserProvider();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = Provider.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            child: Container(
              height: 120.0,
            ),
          ),
          Container(
            width: size.width * 0.85,
            margin: EdgeInsets.symmetric(vertical: 30.0),
            padding: EdgeInsets.symmetric(vertical: 50.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3.0,
                  offset: Offset(0.0, 2.0),
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Iniciá sesión',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 30.0),
                _email(bloc),
                SizedBox(height: 30.0),
                _password(bloc),
                SizedBox(height: 30.0),
                _button(bloc),
                GoogleSignUpButtonWidget(),
              ],
            ),
          ),
          FlatButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, 'register'),
            child: Text('¿Todavía no te registraste? Registrate acá'),
          ),
          SizedBox(height: 100.0),
        ],
      ),
    );
  }

  Widget _email(LoginBloc bloc) {
    return StreamBuilder<Object>(
        stream: bloc.emailStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                icon: Icon(Icons.alternate_email, color: Colors.deepPurple),
                hintText: 'ejemplo@correo.com',
                labelText: 'Correo electrónico',
                counterText: snapshot.data,
                errorText: snapshot.error,
              ),
              onChanged: bloc.changeEmail,
            ),
          );
        });
  }

  Widget _password(LoginBloc bloc) {
    return StreamBuilder<Object>(
        stream: bloc.passwordStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline, color: Colors.deepPurple),
                labelText: 'Contraseña',
                counterText: snapshot.data,
                errorText: snapshot.error,
              ),
              onChanged: bloc.changePassword,
            ),
          );
        });
  }

  Widget _button(LoginBloc bloc) {
    return StreamBuilder<Object>(
        stream: bloc.formValidStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return OutlineButton(
            onPressed: snapshot.hasData ? () => _login(bloc, context) : null,
            child: Container(
              child: Text('Iniciar sesión'),
              padding: EdgeInsets.symmetric(horizontal: 55),
            ),
            shape: StadiumBorder(),
            borderSide: BorderSide(color: Colors.black),
            textColor: Colors.black,
          );
        });
  }

  _login(LoginBloc bloc, BuildContext context) async {
    Map info = await userProvider.login(bloc.email, bloc.password);
    if (info['ok']) {
      Navigator.pushReplacementNamed(context, 'home');
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Los datos ingresados son incorrectos.'),
              content: Text(info['message']),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Ok'))
              ],
            );
          });
    }
  }
}
