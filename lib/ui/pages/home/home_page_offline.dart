import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/ui/pages/home/widgets/side_menu.dart';

class HomePageOffline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: FlutterLogo(),
          ),
        ],
      ),
      body: Container(),
      drawer: SideMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_rounded),
        onPressed: () {},
        //onPressed: () => dialogCreateGroup(context),
      ),
    );
  }
}
