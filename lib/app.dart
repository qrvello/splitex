import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:repartapp/config/routes/routes.dart' as router;
import 'package:repartapp/domain/cubits/app_theme_cubit.dart';
import 'package:repartapp/domain/dependency_injection.dart';
import 'domain/cubits/auth/auth_cubit.dart';
import 'ui/themes/dark_theme.dart';
import 'ui/themes/light_theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>(create: (_) => AppThemeCubit()..init()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()..init()),
      ],
      child: MultiRepositoryProvider(
        providers: repositoriesProviders(),
        child: BlocBuilder<AppThemeCubit, bool>(
          builder: (context, isDark) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'RepartApp',
              initialRoute: '/',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              onGenerateRoute: router.Router.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
