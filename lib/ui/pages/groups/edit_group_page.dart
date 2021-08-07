import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:share/share.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
import 'package:splitex/domain/repositories/groups_repository_offline.dart';
import 'package:splitex/ui/helpers/snackbar_error.dart';

class EditGroupPage extends StatefulWidget {
  final bool online;
  final Group group;

  const EditGroupPage({required this.online, required this.group});
  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final formKeyGroupName = GlobalKey<FormState>();
  final formKeyNewMember = GlobalKey<FormState>();

  TextEditingController _groupNameController = TextEditingController();

  late Group newGroup;

  bool isSwitched = false;

  @override
  void initState() {
    super.initState();

    newGroup = Group(
      id: widget.group.id,
      name: widget.group.name,
      members: [...widget.group.members!],
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
        onPressed: () => _submit(context),
        child: const Icon(Icons.check_rounded),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Editar grupo'),
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
                  title: const Text('Miembros'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.online)
                        IconButton(
                          onPressed: () => Share.share(
                              'Unite a mi grupo de splitex: ${widget.group.link}'),
                          icon: const Icon(Icons.share_rounded),
                        ),
                      IconButton(
                        onPressed: () => dialogAddMember(context),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
              MembersList(members: newGroup.members!),
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
        style: const TextStyle(fontSize: 18),
        decoration: const InputDecoration(
          labelText: 'Nombre del grupo',
          counterText: "",
        ),
        validator: (value) {
          if (value!.trim().isEmpty) {
            return 'Ingresá un nombre para el grupo';
          } else if (value.trim().length > 25) {
            return 'Ingrese un nombre menor a 25 caracteres';
          } else {
            return null;
          }
        },
        initialValue: widget.group.name,
        onSaved: (value) {
          newGroup.name = value!.trim();
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
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                errorMaxLines: 3,
                labelText: 'Nombre',
                counterText: '',
              ),
              validator: (value) {
                if (value!.trim().isEmpty) {
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
                  (states) => states.contains(MaterialState.pressed)
                      ? const Color(0xffE29578)
                      : const Color(0xffee6c4d),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _addNewMember(_newMemberName),
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewMember(TextEditingController controller) async {
    formKeyNewMember.currentState!.save();

    if (!formKeyNewMember.currentState!.validate()) return;

    // Si es offline, crea una id basada en la fecha y hora actual.
    final String? id =
        (widget.online == false) ? DateTime.now().toString() : null;

    final Member member = Member(name: controller.text.trim(), id: id);

    setState(() {
      newGroup.members!.add(member);
    });

    Get.back();
  }

  Future<void> _submit(BuildContext context) async {
    if (!formKeyGroupName.currentState!.validate()) return;

    formKeyGroupName.currentState!.save();

    if (widget.group == newGroup) {
      Get.back();
      return;
    }

    try {
      if (widget.online) {
        await RepositoryProvider.of<GroupsRepository>(context)
            .updateGroup(group: widget.group, newGroup: newGroup);
      } else {
        await RepositoryProvider.of<GroupsRepositoryOffline>(context)
            .updateGroup(group: widget.group, newGroup: newGroup);
      }
      Get.back();
      snackbarSuccess();
    } catch (e) {
      snackbarError(message: 'Error al editar el grupo: ${e.toString()}');
    }
  }

  void snackbarSuccess() {
    return Get.snackbar(
      'Acción exitosa',
      'Grupo editado satisfactoriamente',
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  //void snackbarError({required String message}) {
  //  return Get.snackbar(
  //    'Error',
  //    'Error al editar el grupo: $message',
  //    icon: Icon(
  //      Icons.error_outline_rounded,
  //      color: Color(0xffee6c4d),
  //    ),
  //    snackPosition: SnackPosition.BOTTOM,
  //    margin: EdgeInsets.only(bottom: 85, left: 20, right: 20),
  //    backgroundColor: Color(0xffee6c4d).withOpacity(0.1),
  //  );
  //}
}

class MembersList extends StatefulWidget {
  final List<Member> members;

  const MembersList({
    Key? key,
    required this.members,
  }) : super(key: key);

  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 2),
        shrinkWrap: true,
        itemCount: widget.members.length,
        itemBuilder: (context, i) {
          widget.members[i].controller =
              TextEditingController(text: widget.members[i].name);
          return ListTile(
            title: Text(widget.members[i].name!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: () {
                      setState(() {
                        widget.members.remove(widget.members[i]);
                      });
                    }),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () async {
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
                            style: const TextStyle(fontSize: 18),
                            decoration: const InputDecoration(
                              errorMaxLines: 3,
                              labelText: 'Nombre',
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'El nombre no puede estar vacío';
                              }
                              if (value.trim().isEmpty) {
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
                                      states.contains(MaterialState.pressed)
                                          ? const Color(0xffE29578)
                                          : const Color(0xffee6c4d),
                                ),
                              ),
                              onPressed: () {
                                widget.members[i].controller!.text =
                                    widget.members[i].name!;
                                Navigator.pop(context);
                              },
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  widget.members[i] = Member(
                                    name: widget.members[i].controller!.text
                                        .trim(),
                                    id: widget.members[i].id,
                                    balance: widget.members[i].balance,
                                  );
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Guardar'),
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
