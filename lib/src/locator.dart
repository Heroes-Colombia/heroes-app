import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';

final locator = GetIt.instance;

Future<void> initializeDependencies() async {
  //Network dependencies
  final dio = Dio();

  //Repositories dependencies
  locator.registerSingleton<Dio>(dio);
  locator.registerSingleton<AuthService>(
    AuthService(),
  );
}
