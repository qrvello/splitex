import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:splitex/domain/cubits/groups/group_details/group_details_cubit.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
import 'package:splitex/ui/pages/groups/add_expense_page.dart';
import 'package:splitex/ui/pages/groups/edit_group_page.dart';
import 'package:splitex/ui/pages/groups/widgets/activity_widget.dart';
import 'package:splitex/ui/pages/groups/widgets/overview_widget.dart';

// ignore: must_be_immutable
class DetailsGroupPage extends StatefulWidget {
  @override
  _DetailsGroupPageState createState() => _DetailsGroupPageState();
}

class _DetailsGroupPageState extends State<DetailsGroupPage> {
  final bool online = Get.arguments['online'] as bool;
  Group group = Get.arguments['group'] as Group;

  @override
  Widget build(BuildContext context) {
    if (online == true) {
      return _buildOnline();
    } else {
      return _buildOffline();
    }
  }

  ValueListenableBuilder<Box<Group>> _buildOffline() => ValueListenableBuilder(
        valueListenable: Hive.box<Group>('groups').listenable(keys: [group.id]),
        builder: (BuildContext context, Box<Group> box, widget) {
          group = box.get(group.id)!;

          final List<dynamic> actions = [];

          if (group.expenses != null) {
            for (final Expense expense in group.expenses!) {
              actions.add(expense);
            }
          }

          if (group.transactions != null) {
            for (final Transaction transaction in group.transactions!) {
              actions.add(transaction);
            }
          }

          actions.sort((a, b) => b.timestamp.compareTo(a.timestamp) as int);

          return Stack(
            children: [
              DefaultTabController(
                length: 2,
                child: Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => Get.to(() => AddExpensePage(),
                        arguments: {'group': group, 'online': online}),
                    child: const Icon(Icons.add),
                  ),
                  extendBodyBehindAppBar: true,
                  appBar: buildAppBar(context),
                  body: TabBarView(
                    children: [
                      OverviewWidget(group: group, online: online),
                      ActivityWidget(group: group, actions: actions),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      );

  BlocProvider<GroupDetailsCubit> _buildOnline() => BlocProvider(
        create: (context) =>
            GroupDetailsCubit(context.read<GroupsRepository>(), group)..init(),
        child: BlocConsumer<GroupDetailsCubit, GroupDetailsState>(
          listener: (context, state) {
            if (state is GroupDetailsLoaded) group = state.group;
          },
          builder: (BuildContext context, GroupDetailsState state) =>
              _builderDetails(context, state),
        ),
      );

  Stack _builderDetails(BuildContext context, GroupDetailsState state) => Stack(
        children: [
          DefaultTabController(
            length: 2,
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () => Get.to(() => AddExpensePage(),
                    arguments: {'group': group, 'online': online}),
                child: const Icon(Icons.add),
              ),
              extendBodyBehindAppBar: true,
              appBar: buildAppBar(context),
              body: (state is GroupDetailsLoaded)
                  ? TabBarView(
                      children: [
                        OverviewWidget(
                          group: state.group,
                          online: online,
                        ),
                        ActivityWidget(
                          group: state.group,
                          actions: state.actions,
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          )
        ],
      );

  AppBar buildAppBar(BuildContext context) => AppBar(
        actions: [
          if (online)
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<GroupDetailsCubit>(context),
                      child: EditGroupPage(
                        group: group,
                        online: true,
                      ),
                    ),
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditGroupPage(
                      group: group,
                      online: false,
                    ),
                  ),
                );
              },
            ),
        ],
        elevation: 0,
        title: Text(
          group.name!,
          style: Theme.of(context).textTheme.headline5,
        ),
        bottom: const TabBar(
          tabs: [
            Tab(
              child: Text('Resumen'),
            ),
            Tab(
              child: Text('Actividad'),
            ),
          ],
        ),
      );

  void snackbarSuccess() {
    Get.snackbar(
      'Acción exitosa',
      'Miembro agregado satisfactoriamente',
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: Color(0xff25C0B7),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void snackbarError() {
    Get.snackbar(
      'Error',
      'Error al agregar miembro al grupo',
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Color(0xffee6c4d),
      ),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.only(bottom: 85, left: 20, right: 20),
      backgroundColor: const Color(0xffee6c4d).withOpacity(0.1),
    );
  }
}
