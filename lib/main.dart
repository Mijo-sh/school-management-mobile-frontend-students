import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injector/injector_container.dart';
import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/theme/domain/enums/theme_type.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FirebaseService.initialize();
  // await NotificationsInitialize.initialize();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MultiBlocProvider(
    //   providers: [
    //
    //   ],
    //   child: BlocBuilder<, >(
    //     builder: (context, )
    //   )
    // );
    return BlocProvider(
      create: (_) => di<ThemeBloc>()..add(GetThemeEvent()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.type == ThemeType.dark;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.appRouter,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light
          );
        }
      )
    );
  }
}