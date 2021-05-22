import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
import 'package:splitex/domain/repositories/groups_repository_offline.dart';
import 'package:splitex/ui/pages/groups/balance_debts_page.dart';

import 'package:share/share.dart';

class OverviewWidget extends StatefulWidget {
  final Group group;
  final bool online;

  OverviewWidget({@required this.group, @required this.online});

  @override
  _OverviewWidgetState createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  final User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (widget.online == true)
                  ? Container(
                      width: size.width * 0.45,
                      child: ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Invitar a miembros'),
                            SizedBox(width: 5),
                            Icon(
                              Icons.share_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                        onPressed: () {
                          Share.share(
                              'Unite a mi grupo de splitex: ${widget.group.link}');
                        },
                      ),
                    )
                  : SizedBox.shrink(),
              if (widget.online == true) SizedBox(width: 5),
              Container(
                width: size.width * 0.45,
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Balancear cuentas'),
                      SizedBox(width: 5),
                      Icon(
                        FontAwesomeIcons.balanceScale,
                        size: 16,
                      ),
                    ],
                  ),
                  onPressed: () => Get.to(() => BalanceDebtsPage(), arguments: {
                    'group': widget.group,
                    'online': widget.online
                  }),
                ),
              ),
            ],
          ),
        ),
        if (widget.group.members != null)
          SliverPadding(
            padding: EdgeInsets.only(bottom: size.height * 0.1),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _listMembers(context, widget.group.members[i]),
                childCount: widget.group.members.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _listMembers(BuildContext context, Member member) {
    // Si el usuario actual no es el admin entonces no se le permite borrar miembros
    return AbsorbPointer(
      absorbing:
          (user.uid == widget.group.adminUser || widget.group.adminUser == null)
              ? false
              : true,
      child: Dismissible(
        // Al deslizar muestra un cuadro de diálogo pidiendo confirmación
        confirmDismiss: (direction) => showDialog(
          context: context,
          builder: (context) => _confirmDeleteDialog(context, member),
        ),
        onDismissed: (_) {
          if (this.mounted) setState(() {});
          //widget.group.members.remove(member);
        },
        key: UniqueKey(),
        background: Container(
          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xffE29578),
          ),
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.endToStart,
        child: Card(
          child: ListTile(
            title: Text(member.id),
            trailing: Text(
              '\$${member.balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: (member.balance >= 0)
                    ? Color(0xff25C0B7)
                    : Color(0xffF4a74d),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmDeleteDialog(BuildContext context, member) {
    return AlertDialog(
      title: Text('Confirmar eliminación'),
      content: Text('¿Seguro/a deseas borrar del grupo a ${member.id}?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Color(0xffe76f51),
            ),
          ),
        ),
        TextButton(
          onPressed: () => _removeMember(context, member),
          child: Text(
            'Confirmar',
          ),
        ),
      ],
    );
  }

  void _removeMember(BuildContext context, Member member) async {
    if (widget.online == true) {
      Navigator.of(context).pop(true);

      await RepositoryProvider.of<GroupsRepository>(context)
          .deleteMember(widget.group, member);
    } else {
      Navigator.of(context).pop(true);

      await RepositoryProvider.of<GroupsRepositoryOffline>(context)
          .deleteMember(widget.group, member);
    }
  }
}
