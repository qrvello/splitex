import 'package:flutter/material.dart';

class ConfirmDelete extends StatelessWidget {
  final String? message;
  final String? title;
  final Function? onPressed;

  const ConfirmDelete({this.message, this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title!),
      content: Text(message!),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: onPressed as void Function()?,
          child: const Text(
            'Confirmar',
            style: TextStyle(color: Color(0xffe76f51)),
          ),
        ),
      ],
    );
  }
}
