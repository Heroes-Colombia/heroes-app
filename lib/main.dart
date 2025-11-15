import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:heroes_app/src/config/app_themes.dart';
import 'package:heroes_app/src/domain/repositories/cloud_message_service.dart';
import 'package:heroes_app/src/locator.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/all_business/all_business_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_details/business_details_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_search_results/business_search_resutls_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/favourite_businesses/favourite_businesses_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/manage_business/owned_business_details/owned_business_details_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/manage_business/owned_businesses/owned_businesses_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/map/map_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:heroes_app/src/presentation/cubits/promotion/promotion_details_cubit.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/config/router/app_router.dart';

//This method is used to handle the notifications listeners on background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage mesasage,
) async {}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //Load env file
  await dotenv.load(fileName: ".env");
  //Splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //Firebase dependencies
  if (Platform.isIOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  //DIO dependencies
  await initializeDependencies();

  //Cloud messaging dependencies
  final userAcceptNotifications =
      await GetIt.instance
          .get<CloudMessageService>()
          .getNotificationsPermission();
  if (userAcceptNotifications) {
    await GetIt.instance.get<CloudMessageService>().initLocalNotifications();
    //This method is used to handle the notifications when the app is in background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    //This will handle the notification tap when the app is in foreground
  }
  //Formating locale
  await initializeDateFormatting('es', null);
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
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(
          create: (context) {
            // Always initialize a fresh ProfileCubit to avoid stale data
            return ProfileCubit();
          },
        ),
        BlocProvider(
          create: (context) => BusinessHomeViewCubit()..getInitial(),
        ),
        BlocProvider(create: (context) => BusinessDetailsCubit()..getInitial()),
        BlocProvider(create: (context) => BusinessSearchResutlsCubit()),
        BlocProvider(create: (context) => AllBusinessCubit()..getInitial()),
        BlocProvider(
          create: (context) => FavouriteBusinessesCubit()..getInitial(),
        ),
        BlocProvider(create: (context) => OwnedBusinessesCubit()..getInitial()),
        BlocProvider(
          create: (context) => OwnedBusinessDetailsCubit()..getInitial(),
        ),
        BlocProvider(create: (context) => MapCubit()..getInitial()),
        BlocProvider(
          create: (context) => PromotionDetailsCubit()..getInitial(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Heroes',
        //We obtain the theme and darkTheme from the AdaptiveTheme builder
        theme: theme,
        darkTheme: darkTheme,
        routerConfig: _appRouter.config(
          navigatorObservers:
              () => [GetIt.instance.get<AnalyticsService>().observer],
        ),
      ),
    );
  }
}
