import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/member_model.dart';
import 'package:repartapp/providers/groups_provider.dart';

//ignore: must_be_immutable
class BalanceDebtsPage extends StatefulWidget {
  GroupModel group;
  BalanceDebtsPage({this.group});

  @override
  _BalanceDebtsPageState createState() => _BalanceDebtsPageState();
}

class _BalanceDebtsPageState extends State<BalanceDebtsPage> {
  final GroupsProvider groupProvider = GroupsProvider();
  List<Member> members = [];

  @override
  void initState() {
    super.initState();
    //widget.group.members.forEach((key, value) {
    //  Member member = Member.fromJson(value, key);

    //  members.add(member);
    //});

    setState(() {
      members = groupProvider.balanceDebts(members);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balancear cuentas'),
      ),
      //body: ListView.builder(
      //  itemCount: members.length,
      //  itemBuilder: ,
      //));
      body: Center(
        child: Text('hola'),
      ),
    );
  }
}
