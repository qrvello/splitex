import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/provider/authentication_provider.dart';
import 'package:gastos_grupales/widgets/google_sign_up_button_widget.dart';

class FormLogIn extends StatefulWidget {
  @override
  _FormLogInState createState() => _FormLogInState();
}

class _FormLogInState extends State<FormLogIn> {
  final firebaseInstance = FirebaseAuth.instance;

  final _password = TextEditingController();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _formKey = GlobalKey<FormState>();

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
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Iniciá sesión',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 30.0),
                  _emailInput(),
                  SizedBox(height: 30.0),
                  _passwordInput(),
                  SizedBox(height: 30.0),
                  _button(_formKey, context),
                  GoogleSignUpButtonWidget(),
                ],
              ),
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

  Widget _emailInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          icon: Icon(Icons.alternate_email, color: Colors.deepPurple),
          hintText: 'ejemplo@correo.com',
          labelText: 'Correo electrónico',
        ),
        validator: (input) =>
            input.isValidEmail() ? null : "El email ingresado es incorrecto",
        controller: _email,
      ),
    );
  }

  Widget _passwordInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          icon: Icon(Icons.lock_outline, color: Colors.deepPurple),
          labelText: 'Contraseña',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Ingrese una contraseña';
          }
          if (value.length < 6) {
            return 'Ingrese una contraseña mayor a 6 caracteres';
          }
          return null;
        },
        controller: _password,
      ),
    );
  }

  Widget _button(_formKey, context) {
    return OutlineButton(
      onPressed: () {
        // Validate returns true if the form is valid, otherwise false.
        if (_formKey.currentState.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.
          _submit();
          print(_email.text);
          print(_password.text);

          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Processing Data')));
        }
      },
      child: Container(
        child: Text('Iniciar sesión'),
        padding: EdgeInsets.symmetric(horizontal: 55),
      ),
      shape: StadiumBorder(),
      borderSide: BorderSide(color: Colors.black),
      textColor: Colors.black,
    );
  }

  void _submit() {
    AuthenticationProvider(firebaseInstance)
        .signUp(_email.text, _password.text);
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

//_login() async {

//    showDialog(
//          return AlertDialog(
//            title: Text('Los datos ingresados son incorrectos.'),
//            content: Text(info['message']),
//            actions: <Widget>[
//              FlatButton(
//                  onPressed: () => Navigator.of(context).pop(),
//                  child: Text('Ok'))
//            ],
//          ),
//    );
//  }
