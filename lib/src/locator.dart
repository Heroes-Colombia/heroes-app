import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

final locator = GetIt.instance;

Future<void> initializeDependencies() async {
  //Network dependencies
  final dio = Dio();
  locator.registerSingleton<Dio>(dio);
}
