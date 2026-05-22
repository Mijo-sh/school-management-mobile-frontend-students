import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/language/presentation/bloc/language_bloc.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';
import 'features/theme/domain/enums/theme_type.dart';
import 'core/localization/app_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injector/injector_container.dart';
import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => di<ThemeBloc>()..add(GetThemeEvent())
        ),

        BlocProvider<LanguageBloc>(
          create: (context) => di<LanguageBloc>()..add(GetLanguageEvent())
        )
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final isDark = themeState.type == ThemeType.dark;
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.appRouter,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                locale: Locale(languageState.type.name),
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar')
                ],
                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ]
              );
            }
          );
        }
      )
    );
  }
}