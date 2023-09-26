import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:heroes_app/firebase_options.dart';
import 'package:heroes_app/src/config/app_themes.dart';
import 'package:heroes_app/src/config/router/app_router.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Platform.isAndroid || Platform.isIOS
      ? await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform)
      : null;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: MaterialApp.router(
        title: 'Heroes',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
      ),
    );
  }
}
