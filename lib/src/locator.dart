import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/business_subscription_service.dart';
import 'package:heroes_app/src/domain/repositories/cloud_message_service.dart';
import 'package:heroes_app/src/domain/repositories/firestorage_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/repositories/shared_preferences_service.dart';
import 'package:heroes_app/src/domain/services/places_service.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/domain/services/military_id_ocr_service.dart';
import 'package:heroes_app/src/domain/services/military_verification_service.dart';

final locator = GetIt.instance;

//This function initialize all the dependencies with the locator
//GetIt is used to get the dependencies in the app using the singleton pattern
Future<void> initializeDependencies() async {
  final dio = Dio();
  locator.registerSingleton<Dio>(dio);

  final appConstants = AppConstants();
  locator.registerSingleton<AppConstants>(appConstants);

  final sharedPreferencesService = SharedPreferencesService();
  locator.registerSingleton<SharedPreferencesService>(sharedPreferencesService);

  locator.registerSingleton<AuthService>(AuthService());
  locator.registerSingleton<FirestoreService>(FirestoreService());
  locator.registerSingleton<AppMethods>(AppMethods());
  locator.registerSingleton<FireStorageService>(FireStorageService());
  locator.registerSingleton<CloudMessageService>(CloudMessageService());
  locator.registerSingleton<AppRouter>(AppRouter());

  locator.registerSingleton<BusinessSubscriptionService>(
    BusinessSubscriptionService(),
  );

  locator.registerSingleton<PlacesService>(PlacesService());

  // Register AnalyticsService with dependencies
  locator.registerSingleton<AnalyticsService>(
    AnalyticsService(
      analytics: FirebaseAnalytics.instance,
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );

  // Register Military Verification Services
  locator.registerSingleton<MilitaryIDOCRService>(MilitaryIDOCRService());
  locator.registerSingleton<MilitaryVerificationService>(MilitaryVerificationService());
}
