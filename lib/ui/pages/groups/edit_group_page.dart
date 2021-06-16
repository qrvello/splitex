import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
import 'package:splitex/domain/repositories/groups_repository_offline.dart';

class EditGroupPage extends StatefulWidget {
  final bool online;
  final Group group;

  EditGroupPage({Key key, this.online, this.group});
  @override
  _EditGroupPageState createState() => _EditGroupPageState(group);
}

class _EditGroupPageState extends State<EditGroupPage> {
  final formKeyGroupName = GlobalKey<FormState>();
  final formKeyNewMember = GlobalKey<FormState>();

  final Group group;
  TextEditingController _groupNameController = TextEditingController();

  Group newGroup;

  bool isSwitched = false;

  _EditGroupPageState(this.group);

  @override
  void initState() {
    super.initState();

    newGroup = Group(
      name: widget.group.name,
      members: [...widget.group.members],
    );

    _groupNameController = TextEditingController(text: widget.group.name);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check_rounded),
        onPressed: () => _submit(context),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Editar grupo'),
      ),
      body: Builder(
        builder: (context) => Form(
          key: formKeyGroupName,
          child: Column(
            children: <Widget>[
              _inputEditName(),
              Container(
                width: double.infinity,
                color: Colors.black.withOpacity(0.3),
                child: ListTile(
                  title: Text('Miembros del grupo'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => Share.share(
                            'Unite a mi grupo de splitex: ${widget.group.link}'),
                        icon: Icon(Icons.person_add_rounded),
                      ),
                      IconButton(
                        onPressed: () => dialogAddMember(context),
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
              MembersList(members: newGroup.members),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputEditName() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        maxLength: 25,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: 'Nombre del grupo',
        ),
        validator: (value) {
          if (value.trim().length < 1) {
            return 'Ingrese el nombre del grupo';
          } else if (value.trim().length > 25) {
            return 'Ingrese un nombre menor a 25 caracteres';
          } else {
            return null;
          }
        },
        onSaved: (value) {
          newGroup.name = value.trim();
        },
      ),
    );
  }

  Future dialogAddMember(BuildContext context) {
    final TextEditingController _newMemberName = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: formKeyNewMember,
            child: TextFormField(
              controller: _newMemberName,
              autofocus: true,
              maxLength: 20,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                errorMaxLines: 3,
                labelText: 'Nombre',
              ),
              validator: (value) {
                if (value.trim().length < 1) {
                  return 'Ingrese el nombre del nuevo miembro';
                } else if (value.trim().length > 20) {
                  return 'Ingrese un nombre menor a 20 caracteres';
                }
                return null;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => (states.contains(MaterialState.pressed)
                      ? Color(0xffE29578)
                      : Color(0xffee6c4d)),
                ),
              ),
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Agregar'),
              onPressed: () => _addNewMember(_newMemberName),
            ),
          ],
        );
      },
    );
  }

  void _addNewMember(TextEditingController controller) async {
    formKeyNewMember.currentState.save();

    if (!formKeyNewMember.currentState.validate()) return;

    if (widget.online == true) {
      Member member = Member(name: controller.text.trim());

      setState(() {
        newGroup.members.add(member);
      });

      Get.back();
    } else {
      await context
          .read<GroupsRepositoryOffline>()
          .addPersonToGroup(controller.text.trim(), widget.group);
    }
  }

  void _submit(context) async {
    if (widget.group.name == _groupNameController) return;

    if (!formKeyGroupName.currentState.validate()) return;

    formKeyGroupName.currentState.save();

    bool resp;

    if (widget.online == true) {
      resp = await RepositoryProvider.of<GroupsRepository>(context)
          .updateGroup(group: widget.group, newGroup: group);
    } else {
      resp = await RepositoryProvider.of<GroupsRepositoryOffline>(context)
          .updateGroup(widget.group);
    }

    if (resp == true) {
      snackbarSuccess();
    } else {
      snackbarError();
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Grupo editado satisfactoriamente',
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError() {
    return Get.snackbar(
      'Error',
      'Error al editar el grupo',
      icon: Icon(
        Icons.error_outline_rounded,
        color: Color(0xffee6c4d),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Color(0xffee6c4d).withOpacity(0.1),
    );
  }
}

class MembersList extends StatefulWidget {
  const MembersList({Key key, this.members, this.isOnline}) : super(key: key);
  final bool isOnline;
  final List<Member> members;

  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  @override
  Widget build(BuildContext context) {
    // TODO online
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 2),
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: context.height * 0.1),
        itemCount: widget.members.length,
        itemBuilder: (context, i) {
          widget.members[i].controller =
              TextEditingController(text: widget.members[i].name);
          return ListTile(
            title: Text(widget.members[i].name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(Icons.delete_rounded),
                    onPressed: () {
                      setState(() {
                        widget.members.remove(widget.members[i]);
                      });
                    }),
                IconButton(
                  icon: Icon(Icons.edit_rounded),
                  onPressed: () {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: widget.members[i].controller,
                            autofocus: true,
                            maxLength: 20,
                            style: TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              errorMaxLines: 3,
                              labelText: 'Nombre',
                            ),
                            validator: (value) {
                              if (value.trim().length < 1) {
                                return 'El nombre no puede estar vacío';
                              } else if (value.trim().length > 20) {
                                return 'Ingrese un nombre menor a 20 caracteres';
                              }
                              return null;
                            },
                          ),
                          actions: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) =>
                                      (states.contains(MaterialState.pressed)
                                          ? Color(0xffE29578)
                                          : Color(0xffee6c4d)),
                                ),
                              ),
                              child: Text('Cancelar'),
                              onPressed: () {
                                widget.members[i].controller.text =
                                    widget.members[i].name;
                                Navigator.pop(context);
                              },
                            ),
                            ElevatedButton(
                              child: Text('Guardar'),
                              onPressed: () {
                                setState(() {
                                  widget.members[i].name =
                                      widget.members[i].controller.text.trim();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
