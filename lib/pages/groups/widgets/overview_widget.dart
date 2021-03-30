import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:repartapp/models/group_model.dart';
import 'package:repartapp/models/member_model.dart';
import 'package:repartapp/providers/groups_provider.dart';
import 'package:share/share.dart';

class OverviewWidget extends StatefulWidget {
  final Group group;

  const OverviewWidget({Key key, this.group}) : super(key: key);
  @override
  _OverviewWidgetState createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget> {
  final GroupsProvider groupProvider = GroupsProvider();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
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
                        'Unite a mi grupo de RepartApp: ${widget.group.link}');
                  },
                ),
              ),
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
                  onPressed: () => Navigator.pushNamed(
                      context, '/balance_debts',
                      arguments: widget.group),
                ),
              ),
            ],
          ),
        ),
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
      absorbing: (user.uid != widget.group.adminUser) ? true : false,
      child: Dismissible(
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (_) {
              if (member.balance == 0) {
                // Al deslizar muestra un cuadro de diálogo pidiendo confirmación
                return _confirmDeleteDialog(context, member);
              }
              return ErrorDialog(member: member);
            },
          );
        },
        onDismissed: (_) {
          setState(() {
            widget.group.members.remove(member);
          });
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

  Widget _confirmDeleteDialog(context, member) {
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
          onPressed: () {
            groupProvider.deleteMember(widget.group, member);
            Navigator.of(context).pop(true);
          },
          child: Text(
            'Confirmar',
          ),
        ),
      ],
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final Member member;
  const ErrorDialog({
    Key key,
    this.member,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmar eliminación'),
      content: Text(
          'Para borrar al miembro ${member.id} primero balancea sus cuentas.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Aceptar'),
        ),
      ],
    );
  }
}
