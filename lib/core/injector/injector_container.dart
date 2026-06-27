import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:school_management_mobile_frontend_students/features/auth/data/data_sources/local_data_source/auth_local_data_source.dart';
import 'package:school_management_mobile_frontend_students/features/auth/data/data_sources/remote_data_source/auth_remote_datasource.dart';
import 'package:school_management_mobile_frontend_students/features/auth/domain/use_cases/log_out.dart';
import 'package:school_management_mobile_frontend_students/features/auth/presentation/manager/auth_bloc.dart';

import '../../features/app_intro/data/data_sources/app_session_local_data_source.dart';
import '../../features/app_intro/data/repositories/app_session_repository_impl.dart';
import '../../features/app_intro/domain/use_cases/complete_onboarding_use_case.dart';
import '../../features/app_intro/domain/use_cases/delete_app_session_use_case.dart';
import '../../features/app_intro/presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../features/auth/domain/use_cases/resend_otp_usecase.dart';
import '../../features/home/presentation/manager/main_cubit.dart';
import '../../features/language/data/data_sources/language_local_data_source.dart';
import '../../features/app_intro/domain/repositories/app_session_repository.dart';
import '../../features/app_intro/domain/use_cases/save_app_session_use_case.dart';
import '../../features/language/data/repositories/language_repository_impl.dart';
import '../../features/app_intro/domain/use_cases/get_app_session_use_case.dart';
import '../../features/language/domain/use_cases/save_language_use_case.dart';
import '../../features/language/domain/repositories/language_repository.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../features/language/domain/use_cases/get_language_use_case.dart';
import '../../features/auth/data/repositories/auth_repository_imp.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/log_in_usecase.dart';
import '../../features/auth/domain/use_cases/send_otp_usecase.dart';
import '../../features/profile/data/data_sources/remote_data_source/guardian_remote_data_source.dart';
import '../../features/profile/data/data_sources/remote_data_source/student_remote_data_source.dart';
import '../../features/profile/data/repositories/guardian_repository_imp.dart';
import '../../features/profile/data/repositories/student_repository_imp.dart';
import '../../features/profile/domain/repositories/quardian_repository.dart';
import '../../features/profile/domain/repositories/student_repository.dart';
import '../../features/profile/domain/use_cases/get_cached_user_usecase.dart';
import '../../features/profile/domain/use_cases/get_children_usecase.dart';
import '../../features/profile/domain/use_cases/get_student_usecase.dart';
import '../../features/profile/presentation/manager/guardian_cubit.dart';
import '../../features/profile/presentation/manager/student_cubit.dart';
import '../../features/theme/data/data_sources/theme_local_data_source.dart';
import '../../features/app_intro/presentation/bloc/splash/splash_bloc.dart';
import '../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../features/app_intro/domain/services/app_entry_decider.dart';
import '../../features/theme/domain/use_cases/save_theme_use_case.dart';
import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/use_cases/get_theme_use_case.dart';
import '../../features/language/presentation/bloc/language_bloc.dart';
import '../../features/theme/presentation/bloc/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../network/auth_interceptor.dart';
import '../network/network_info.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

Future<void> init() async {
  // ====================   External   ====================
  final sharedPreferences = await SharedPreferences.getInstance();
  di.registerLazySingleton(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  di.registerLazySingleton(() => secureStorage);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.103:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AuthInterceptor(secureStorage: secureStorage));
  di.registerLazySingleton<Dio>(() => dio);
  di.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  di.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.createInstance());

  // ====================   Core   ====================
  di.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectionChecker: di()));

  // ====================   Features   ====================

  // ********** Auth Feature **********
  di.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(secureStorage: di()));
  di.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dio: di()));

  di.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: di(), localDataSource: di()));

  di.registerLazySingleton<LoginUseCase>(() => LoginUseCase(di()));
  di.registerLazySingleton<SendOtpUsecase>(() => SendOtpUsecase(di()));
  di.registerLazySingleton<ResendOtpUsecase>(() => ResendOtpUsecase(di()));
  di.registerLazySingleton<LogOutUsecase>(() => LogOutUsecase(di()));

  di.registerFactory(() => AuthBloc(
    loginUseCase: di(),
    sendOtpUsecase: di(),
    resendOtpUsecase: di(),
    // logOutUsecase: di(),
  ),
  );

  // ********** Theme   **********
  di.registerLazySingleton<ThemeLocalDataSource>(() => ThemeLocalDataSourceImpl(preferences: di()));
  di.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(localDataSource: di()));
  di.registerLazySingleton<GetThemeUseCase>(() => GetThemeUseCase(repository: di()));
  di.registerLazySingleton<SaveThemeUseCase>(() => SaveThemeUseCase(repository: di()));
  di.registerFactory(() => ThemeBloc(getTheme: di(), saveTheme: di()));

  // ********** Language   **********
  di.registerLazySingleton<LanguageLocalDataSource>(() => LanguageLocalDataSourceImpl(preferences: di()));
  di.registerLazySingleton<LanguageRepository>(() => LanguageRepositoryImpl(localDataSource: di()));
  di.registerLazySingleton<GetLanguageUseCase>(() => GetLanguageUseCase(repository: di()));
  di.registerLazySingleton<SaveLanguageUseCase>(() => SaveLanguageUseCase(repository: di()));
  di.registerFactory(() => LanguageBloc(getLanguage: di(), saveLanguage: di()));

  // ********** App Intro & Splash   **********
  di.registerLazySingleton<AppSessionLocalDataSource>(() => AppSessionLocalDataSourceImpl( storage: di()));
  di.registerLazySingleton<AppSessionRepository>(() => AppSessionRepositoryImpl(localDataSource: di()));
  di.registerLazySingleton<GetAppSessionUseCase>(() => GetAppSessionUseCase(repository: di()));
  di.registerLazySingleton<SaveAppSessionUseCase>(() => SaveAppSessionUseCase(repository: di()));
  di.registerLazySingleton<DeleteAppSessionUseCase>(() => DeleteAppSessionUseCase(repository: di()));
  di.registerLazySingleton<CompleteOnboardingUseCase>(() => CompleteOnboardingUseCase(repository: di()));

  di.registerLazySingleton<AppEntryDecider>(() => AppEntryDecider());

  di.registerFactory(() => SplashBloc(getAppSession: di(), decider: di()));
  di.registerFactory(() => OnboardingBloc(completeOnboarding: di()));
  // ********** profile  **********
  // ********** 👤 Profile  **********

  // اليوزكيس المشترك: قراءة المستخدم المخزّن (لاسم الطالب)
  di.registerLazySingleton<GetCachedUserUsecase>(
          () => GetCachedUserUsecase(di()));

  // ----- Guardian (الأولاد) -----
  di.registerLazySingleton<GuardianRemoteDataSource>(
          () => GuardianRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<GuardianRepository>(
          () => GuardianRepositoryImpl(remoteDataSource: di()));
  di.registerLazySingleton<GetChildrenUsecase>(
          () => GetChildrenUsecase(di()));
  di.registerFactory(() => GuardianCubit(getChildrenUsecase: di()));

  // ----- Student (المعلومات الأكاديمية + الاسم) -----
  di.registerLazySingleton<StudentRemoteDataSource>(
          () => StudentRemoteDataSourceImpl(dio: di()));
  di.registerLazySingleton<StudentRepository>(
          () => StudentRepositoryImpl(remoteDataSource: di()));
  di.registerLazySingleton<GetAcademicInfoUsecase>(
          () => GetAcademicInfoUsecase(di()));
  di.registerFactory(() => StudentCubit(
    getAcademicInfoUsecase: di(),
    getCachedUserUsecase: di(),
  ));
  di.registerFactory(() => MainCubit(getCachedUserUsecase: di()));

}