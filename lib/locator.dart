import 'package:get_it/get_it.dart';
import 'package:repartapp/providers/groups_provider.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerFactory<GroupsProvider>(() => GroupsProvider());
}
