import 'package:flutter/material.dart';
import 'package:repartapp/styles/elevated_button_style.dart';

class FriendsListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _totalBalance(),
          _buttonAddFriends(),
        ],
      ),
    );
  }

  Widget _totalBalance() {
    return Container(
      constraints: BoxConstraints(minWidth: 500, maxWidth: 900),
      height: 85,
      color: Color(0xff264653),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: Text(
              'Balance total:',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Container(
            child: Text(
              'No debés nada',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buttonAddFriends() {
    return Container(
      child: ElevatedButton(
        style: elevatedButtonStyle,
        child: Text(
          'Agregar amigo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
