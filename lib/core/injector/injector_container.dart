import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../features/theme/data/data_sources/theme_local_data_source.dart';
import '../../features/theme/data/repositories/theme_repository_impl.dart';
import '../../features/theme/domain/use_cases/save_theme_use_case.dart';
import '../../features/theme/domain/repositories/theme_repository.dart';
import '../../features/theme/domain/use_cases/get_theme_use_case.dart';
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
}