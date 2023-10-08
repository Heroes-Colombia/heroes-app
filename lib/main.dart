import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heroes_app/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:heroes_app/src/config/app_themes.dart';
import 'package:heroes_app/src/config/router/app_router.dart';
import 'package:heroes_app/src/locator.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //Splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //Firebase dependencies
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //DIO dependencies
  await initializeDependencies();
  //Theme dependencies
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final _appRouter = AppRouter();
  MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return AdaptiveTheme(
      light: AppTheme.light,
      dark: AppTheme.dark,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => _buildApp(theme, darkTheme),
    );
  }

  // This widget is the root of your application.
  _buildApp(ThemeData theme, ThemeData darkTheme) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
      ],
      child: MaterialApp.router(
        title: 'Heroes',
        theme: theme,
        darkTheme: darkTheme,
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
      ),
    );
  }
}
