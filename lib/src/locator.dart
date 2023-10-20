import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/repositories/shared_preferences_service.dart';

final locator = GetIt.instance;

//This function initialize all the dependencies with the locator
//GetIt is used to get the dependencies in the app using the singleton pattern
Future<void> initializeDependencies() async {
  //Network dependencies
  final dio = Dio();

  //Repositories dependencies
  locator.registerSingleton<Dio>(dio);
  locator.registerSingleton<AppConstants>(AppConstants());
  locator.registerSingleton<AuthService>(
    AuthService(),
  );
  locator.registerSingleton<FirestoreService>(
    FirestoreService(),
  );

  locator.registerSingleton<AppMethods>(
    AppMethods(),
  );

  locator.registerSingleton<SharedPreferencesService>(
    SharedPreferencesService(),
  );
}
