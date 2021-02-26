import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/provider/authentication_provider.dart';
import 'package:gastos_grupales/widgets/google_sign_up_button_widget.dart';

class FormSignUp extends StatefulWidget {
  @override
  _FormSignUpState createState() => _FormSignUpState();
}

class _FormSignUpState extends State<FormSignUp> {
  final _password = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _password.dispose();
    _email.dispose();
    super.dispose();
  }

  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            child: Container(
              height: .0,
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
                  'Registrarse',
                  style: TextStyle(fontSize: 20.0),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30.0),
                      _emailInput(),
                      SizedBox(height: 30.0),
                      _passwordInput(),
                      SizedBox(height: 30.0),
                      _button(_formKey, context),
                    ],
                  ),
                ),
                GoogleSignUpButtonWidget(),
              ],
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text('¿Ya te registraste? Iniciá sesión acá'),
          ),
          FlatButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            child: Text('Recuperá tu contraseña'),
            // TODO recuperar contraseña
          ),
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
          icon: Icon(Icons.alternate_email, color: Color(0xff2a9d8f)),
          labelStyle: TextStyle(color: Color(0xff264653)),
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
        obscureText: _obscureText,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              _toggle();
            },
          ),
          icon: Icon(Icons.lock_outline, color: Color(0xff2a9d8f)),
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

          Scaffold.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Color(0xff264653),
              behavior: SnackBarBehavior.floating,
              content: Text('Registrandose...'),
            ),
          );
        }
      },
      child: Container(
        child: Text(
          'Registrarse',
          style: TextStyle(color: Colors.black87),
        ),
        padding: EdgeInsets.symmetric(horizontal: 55),
      ),
      shape: StadiumBorder(),
      borderSide: BorderSide(color: Colors.black54),
      textColor: Colors.black,
    );
  }

  void _submit() async {
    final firebaseInstance = FirebaseAuth.instance;

    await AuthenticationProvider(firebaseInstance)
        .signUp(_email.text, _password.text);
    Navigator.of(context).pushNamed('/home');
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}