import 'package:internet_connection_checker/internet_connection_checker.dart';
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

}