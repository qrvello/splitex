import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: new FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 8,
              ),
              _inputText('Nombre del grupo', 'Vacaciones'),
              _inputText('Descripción', 'Vacaciones a Río Negro'),
              _inputText('Email de participantes', 'nicolas@gmail.com'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputText(label, hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 12,
        ),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            isDense: true,
          ),
        ),
        SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
