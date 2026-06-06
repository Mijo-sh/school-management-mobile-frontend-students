import '../../features/app_intro/data/data_sources/app_session_local_data_source.dart';
import '../../features/app_intro/data/repositories/app_session_repository_impl.dart';
import '../../features/app_intro/domain/use_cases/complete_onboarding_use_case.dart';
import '../../features/app_intro/domain/use_cases/delete_app_session_use_case.dart';
import '../../features/app_intro/presentation/bloc/onboarding/onboarding_bloc.dart';
import '../../features/language/data/data_sources/language_local_data_source.dart';
import '../../features/app_intro/domain/repositories/app_session_repository.dart';
import '../../features/app_intro/domain/use_cases/save_app_session_use_case.dart';
import '../../features/language/data/repositories/language_repository_impl.dart';
import '../../features/app_intro/domain/use_cases/get_app_session_use_case.dart';
import '../../features/language/domain/use_cases/save_language_use_case.dart';
import '../../features/language/domain/repositories/language_repository.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../features/language/domain/use_cases/get_language_use_case.dart';
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
import 'package:http/http.dart' as http;
import '../network/network_info.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

Future<void> init() async {
  // ====================   External   ====================
  final sharedPreferences = await SharedPreferences.getInstance();

  di.registerLazySingleton(() => sharedPreferences);
  di.registerLazySingleton<http.Client>(() => http.Client());
  di.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  di.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker.createInstance());

  // ====================   Core   ====================
  di.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectionChecker: di()));

  // ====================   Features   ====================
  // **********   Theme   **********
  // Data source
  di.registerLazySingleton<ThemeLocalDataSource>(() => ThemeLocalDataSourceImpl(preferences: di()));

  // Repository
  di.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(localDataSource: di()));

  // Use cases
  di.registerLazySingleton<GetThemeUseCase>(() => GetThemeUseCase(repository: di()));
  di.registerLazySingleton<SaveThemeUseCase>(() => SaveThemeUseCase(repository: di()));

  // Bloc
  di.registerFactory(() => ThemeBloc(getTheme: di(), saveTheme: di()));

  // **********   Language   **********
  // Data source
  di.registerLazySingleton<LanguageLocalDataSource>(() => LanguageLocalDataSourceImpl(preferences: di()));

  // Repository
  di.registerLazySingleton<LanguageRepository>(() => LanguageRepositoryImpl(localDataSource: di()));

  // Use cases
  di.registerLazySingleton<GetLanguageUseCase>(() => GetLanguageUseCase(repository: di()));
  di.registerLazySingleton<SaveLanguageUseCase>(() => SaveLanguageUseCase(repository: di()));

  // Bloc
  di.registerFactory(() => LanguageBloc(getLanguage: di(), saveLanguage: di()));

  // **********   app intro   **********
  // Data source
  di.registerLazySingleton<AppSessionLocalDataSource>(() => AppSessionLocalDataSourceImpl(preferences: di()));

  // Repository
  di.registerLazySingleton<AppSessionRepository>(() => AppSessionRepositoryImpl(localDataSource: di()));

  // Use cases
  di.registerLazySingleton<GetAppSessionUseCase>(() => GetAppSessionUseCase(repository: di()));
  di.registerLazySingleton<SaveAppSessionUseCase>(() => SaveAppSessionUseCase(repository: di()));
  di.registerLazySingleton<DeleteAppSessionUseCase>(() => DeleteAppSessionUseCase(repository: di()));
  di.registerLazySingleton<CompleteOnboardingUseCase>(() => CompleteOnboardingUseCase(repository: di()));

  // Services
  di.registerLazySingleton<AppEntryDecider>(() => AppEntryDecider());

  // Bloc
  di.registerFactory(() => SplashBloc(getAppSession: di(), decider: di()));
  di.registerFactory(() => OnboardingBloc(completeOnboarding: di()));
}