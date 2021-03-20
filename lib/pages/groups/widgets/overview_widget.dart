import 'package:flutter/material.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/member_model.dart';
import 'package:repartapp/pages/users/user_search.dart';

class OverviewWidget extends StatefulWidget {
  final GroupModel group;

  const OverviewWidget({Key key, this.group}) : super(key: key);
  @override
  _OverviewWidgetState createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text('Invitar a miembros'),
                onPressed: () async {
                  await showSearch(
                    context: context,
                    delegate: UserSearchDelegate(widget.group),
                  );
                },
              ),
              ElevatedButton(
                child: Text('Balancear cuentas'),
                onPressed: () => Navigator.pushNamed(context, '/balance_debts',
                    arguments: widget.group),
              ),
            ],
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _listMembers(context, widget.group.members[i]),
            childCount: widget.group.members.length,
          ),
        ),
      ],
    );
  }

  Widget _listMembers(BuildContext context, Member member) {
    return Card(
      child: ListTile(
        title: Text(member.id),
        trailing: Text(
          '\$${member.balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                (member.balance >= 0) ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
