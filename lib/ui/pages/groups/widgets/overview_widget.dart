import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/ui/pages/groups/balance_debts_page.dart';

class OverviewWidget extends StatefulWidget {
  final Group group;
  final bool online;

  const OverviewWidget({required this.group, required this.online});

  @override
  _OverviewWidgetState createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: ElevatedButton(
            onPressed: () => Get.to(
              () => BalanceDebtsPage(),
              arguments: {
                'group': widget.group,
                'online': widget.online,
              },
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Balancear cuentas'),
                SizedBox(width: 8),
                Icon(
                  FontAwesomeIcons.balanceScale,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (widget.group.members != null)
          SliverPadding(
            padding: EdgeInsets.only(bottom: size.height * 0.1),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _listMembers(context, widget.group.members![i]),
                childCount: widget.group.members?.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _listMembers(BuildContext context, Member member) {
    return Card(
      child: ListTile(
        title: Text(member.name!),
        trailing: Text(
          '\$${member.balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: (member.balance >= 0)
                ? const Color(0xff25C0B7)
                : const Color(0xffF4a74d),
          ),
        ),
      ),
    );
  }
}
