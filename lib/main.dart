import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/injector/injector_container.dart';
import 'core/localization/app_localization.dart';
import 'core/notifications/domain/repositories/push_notification_repository.dart';
import 'core/notifications/presentation/manager/notification_handler.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/manager/auth_bloc.dart';
import 'features/language/presentation/bloc/language_bloc.dart';
import 'features/theme/domain/enums/theme_type.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة الـ Firebase
  await Firebase.initializeApp();

  // 2. تهيئة حقن التبعيات (DI)
  await init();

  // 3. جلب الـ Service محقونة وجاهزة عبر الـ DI
  final pushNotificationService = di<PushNotificationRepository>();
  await pushNotificationService.initialize();

  // جلب التوكن وطباعته للفحص
  final token = await pushNotificationService.getDeviceToken();
  print("🔥 [FCM Token]: $token");

  runApp(MyApp(notificationService: pushNotificationService));
}

class MyApp extends StatefulWidget {
  final PushNotificationRepository notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late NotificationHandler _notificationHandler;

  // 🔥 إضافة هذا المتغير لمنع تكرار فتح الـ Stream عند كل Rebuild (تغيير ثيم أو لغة)
  bool _isListeningToNotifications = false;

  @override
  void initState() {
    super.initState();
    // جلب الـ Handler المسؤول عن توجيه الروابط عند ضغط الإشعار
    _notificationHandler = di<NotificationHandler>();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => di<ThemeBloc>()..add(GetThemeEvent()),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => di<LanguageBloc>()..add(GetLanguageEvent()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => di<AuthBloc>(),
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final isDark = themeState.type == ThemeType.dark;

              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.appRouter,

                // 🎨 Themes
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

                // 🌍 Localization
                locale: Locale(languageState.type.name),
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                ],
                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                // تشغيل الاستماع للإشعارات هنا لضمان وجود الـ MaterialApp والـ Router جاهزين في الـ Context
                builder: (context, child) {
                  // 🔥 التعديل: نتحقق أولاً؛ إذا لم نكن نستمع مسبقاً، نفتح الـ Stream لمرة واحدة فقط
                  if (!_isListeningToNotifications) {
                    _notificationHandler.listenForRoutes(context);
                    _isListeningToNotifications = true;
                  }
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}