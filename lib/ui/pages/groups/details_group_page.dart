import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:splitex/domain/cubits/groups/group_details/group_details_cubit.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/repositories/groups_repository.dart';
import 'package:splitex/ui/pages/groups/add_expense_page.dart';
import 'package:splitex/ui/pages/groups/edit_group_page.dart';
import 'package:splitex/ui/pages/groups/widgets/activity_widget.dart';
import 'package:splitex/ui/pages/groups/widgets/overview_widget.dart';

class DetailsGroupPage extends StatelessWidget {
  const DetailsGroupPage({required this.group, required this.online});

  final bool online;
  final Group group;

  @override
  Widget build(BuildContext context) {
    if (online) {
      return GroupDetailsOnline(group: group);
    } else {
      return GroupDetailsOffline(group: group);
    }
  }
}

class GroupDetailsOnline extends StatefulWidget {
  const GroupDetailsOnline({
    Key? key,
    required this.group,
  }) : super(key: key);

  final Group group;

  @override
  _GroupDetailsOnlineState createState() => _GroupDetailsOnlineState();
}

class _GroupDetailsOnlineState extends State<GroupDetailsOnline> {
  Group? group;

  @override
  void initState() {
    super.initState();
    group = widget.group;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupDetailsCubit(
        group: widget.group,
        groupsRepository: context.read<GroupsRepository>(),
      )..init(),
      child: BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
        builder: (BuildContext context, GroupDetailsState state) {
          if (state is GroupDetailsLoaded) group = state.group;

          return Stack(
            children: [
              DefaultTabController(
                length: 2,
                child: Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => Get.to(() => AddExpensePage(),
                        arguments: {'group': group, 'online': true}),
                    child: const Icon(Icons.add),
                  ),
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value:
                                    BlocProvider.of<GroupDetailsCubit>(context),
                                child: EditGroupPage(
                                  group: group!,
                                  online: true,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                    elevation: 0,
                    title: Text(
                      widget.group.name!,
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
                  ),
                  body: (state is GroupDetailsLoaded)
                      ? TabBarView(
                          children: [
                            OverviewWidget(
                              group: state.group,
                              online: true,
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
        },
      ),
    );
  }
}

class GroupDetailsOffline extends StatefulWidget {
  const GroupDetailsOffline({
    Key? key,
    required this.group,
  }) : super(key: key);

  final Group group;

  @override
  _GroupDetailsOfflineState createState() => _GroupDetailsOfflineState();
}

class _GroupDetailsOfflineState extends State<GroupDetailsOffline> {
  Group? group;

  @override
  void initState() {
    super.initState();
    group = widget.group;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupDetailsCubit(group: widget.group)..init(),
      child: BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
        builder: (BuildContext context, GroupDetailsState state) {
          if (state is GroupDetailsLoaded) group = state.group;
          return Stack(
            children: [
              DefaultTabController(
                length: 2,
                child: Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => Get.to(() => AddExpensePage(),
                        arguments: {'group': widget.group, 'online': false}),
                    child: const Icon(Icons.add),
                  ),
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value:
                                    BlocProvider.of<GroupDetailsCubit>(context),
                                child: EditGroupPage(
                                  group: group!,
                                  online: false,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                    elevation: 0,
                    title: Text(
                      group!.name!,
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
                  ),
                  body: (state is GroupDetailsLoaded)
                      ? TabBarView(
                          children: [
                            OverviewWidget(
                              group: state.group,
                              online: false,
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
        },
      ),
    );
  }
}
