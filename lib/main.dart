import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injector/injector_container.dart';
import 'package:flutter/material.dart';

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
    return Placeholder();
  }
}