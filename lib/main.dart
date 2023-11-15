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
import 'package:heroes_app/src/presentation/cubits/business/all_business/all_business_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_details/business_details_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_search_results/business_search_resutls_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/favourite_businesses/favourite_businesses_cubit.dart';
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
  // First get the saved theme mode and the app router
  final AdaptiveThemeMode? savedThemeMode;
  final _appRouter = AppRouter();
  MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    // Remove the splash screen after the app is loaded
    FlutterNativeSplash.remove();

    // Return the AdaptiveTheme widget withe the main app
    return AdaptiveTheme(
      light: AppTheme.light,
      dark: AppTheme.dark,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => _buildApp(theme, darkTheme),
    );
  }

  // This widget is the root of your application.
  _buildApp(ThemeData theme, ThemeData darkTheme) {
    // Return the MultiBlocProvider widget with the app router
    // to handle the cubits and the routes
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => ProfileCubit(),
        ),
        BlocProvider(
          create: (context) => BusinessHomeViewCubit()..getInitial(),
        ),
        BlocProvider(
          create: (context) => BusinessDetailsCubit()..getInitial(),
        ),
        BlocProvider(
          create: (context) => BusinessSearchResutlsCubit(),
        ),
        BlocProvider(
          create: (context) => AllBusinessCubit()..getInitial(),
        ),
        BlocProvider(
          create: (context) => FavouriteBusinessesCubit()..getInitial(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Heroes',
        //We obtain the theme and darkTheme from the AdaptiveTheme builder
        theme: theme,
        darkTheme: darkTheme,
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
      ),
    );
  }
}
