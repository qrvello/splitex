import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/providers/authentication_provider.dart';
import 'package:repartapp/widgets/google_sign_up_button_widget.dart';

import 'google_sign_up_button_widget.dart';

class FormSignUp extends StatefulWidget {
  @override
  _FormSignUpState createState() => _FormSignUpState();
}

class _FormSignUpState extends State<FormSignUp> {
  final _password = TextEditingController();
  final _email = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _email.dispose();
    _name.dispose();
    super.dispose();
  }

  bool _obscureText = true;
  bool _error = false;

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
              height: size.height * 0.025,
            ),
          ),
          Container(
            width: (size.width > 1200) ? size.width * 0.40 : size.width * 0.85,
            margin: EdgeInsets.symmetric(vertical: 30.0),
            padding: EdgeInsets.symmetric(vertical: 50.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 0.5,
                  offset: Offset(0.0, 1.0),
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                _error != false
                    ? Container(
                        height: 32,
                        child: Text(
                          'Error al iniciar sesión: $_error',
                          style:
                              TextStyle(color: Color(0xffe76f51), fontSize: 22),
                        ),
                      )
                    : SizedBox.shrink(),
                Text(
                  'Registrate',
                  style: TextStyle(fontSize: 20.0),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30.0),
                      _nameInput(),
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
          Container(
            width: size.width * 0.85,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: Text(
                '¿Ya te registraste? Iniciá sesión acá',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 17,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            child: Text(
              'Recuperá tu contraseña',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 17,
                letterSpacing: 1,
              ),
            ),
            // ignore: todo
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
          icon: Icon(Icons.alternate_email_rounded, color: Color(0xff2a9d8f)),
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
              _obscureText
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
            onPressed: () {
              _toggle();
            },
          ),
          icon: Icon(Icons.lock_outline_rounded, color: Color(0xff2a9d8f)),
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
    return Container(
      width: 250,
      padding: EdgeInsets.all(4),
      child: OutlinedButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _submit();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Color(0xff264653),
                behavior: SnackBarBehavior.floating,
                content: Text('Registrandose...'),
              ),
            );
          }
        },
        child: Text(
          'Registrarse',
          style: TextStyle(color: Colors.black87),
        ),
        style: OutlinedButton.styleFrom(
          shape: StadiumBorder(),
          side: BorderSide(color: Colors.black38),
        ),
      ),
    );
  }

  void _submit() async {
    final firebaseInstance = FirebaseAuth.instance;

    final resp = await AuthenticationProvider(firebaseInstance)
        .signUp(_email.text.trim(), _password.text, _name.text.trim());

    if (resp != true) {
      _error = resp;
      setState(() {});
      return;
    }
    Navigator.of(context).pushNamed('/home');
  }

  _nameInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          icon: Icon(Icons.person_rounded, color: Color(0xff2a9d8f)),
          labelStyle: TextStyle(color: Color(0xff264653)),
          labelText: 'Nombre',
        ),
        validator: (value) => (value.isEmpty) ? 'Ingrese un nombre' : null,
        controller: _name,
      ),
    );
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
