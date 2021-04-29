import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repartapp/data/repositories_impl/expenses_repository_impl.dart';
import 'package:repartapp/data/repositories_impl/expenses_repository_offline_impl.dart';
import 'package:repartapp/data/repositories_impl/groups_repository_impl.dart';
import 'package:repartapp/data/repositories_impl/groups_repository_offline_impl.dart';
import 'package:repartapp/domain/repositories/expenses_repository.dart';
import 'package:repartapp/domain/repositories/expenses_repository_offline.dart';
import 'package:repartapp/domain/repositories/groups_repository.dart';

import 'repositories/groups_repository_offline.dart';

List<RepositoryProvider> repositoriesProviders() => [
      RepositoryProvider<GroupsRepository>(
        create: (_) => GroupsRepositoryImpl(),
      ),
      RepositoryProvider<GroupsRepositoryOffline>(
        create: (_) => GroupsRepositoryOfflineImpl(),
      ),
      RepositoryProvider<ExpensesRepository>(
        create: (_) => ExpensesRepositoryImpl(),
      ),
      RepositoryProvider<ExpensesRepositoryOffline>(
        create: (_) => ExpensesRepositoryOfflineImpl(),
      ),
    ];
