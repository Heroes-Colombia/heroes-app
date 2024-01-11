import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/cloud_message_service.dart';
import 'package:heroes_app/src/domain/repositories/firestorage_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/repositories/shared_preferences_service.dart';
import 'package:heroes_app/src/locator.dart';
import 'package:image_picker/image_picker.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());
  final getIt = GetIt.instance;

  //This method is used to log in the user
  Future<bool> logIn(
      Map<String, dynamic> userData, BuildContext context) async {
    try {
      //First we log in the user in firebase auth
      await getIt<AuthService>().signInWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      //Then we get the user information from firestore
      final usersCollection = getIt.get<AppConstants>().usersCollection;
      final userUid = getIt.get<AuthService>().getUserId();
      final userJson = await getIt
          .get<FirestoreService>()
          .readDocumentById(usersCollection, userUid, "uid");
      final user = User.fromJson(userJson);

      //Check if the user has a device notification token and if not, we save it
      await locator.get<CloudMessageService>().handleDeviceNotificationToken(
          user.deviceNotificationToken, usersCollection, userUid);

      //Check if the user status is active (Verified)
      if (!user.verified) {
        if (!context.mounted) return false;
        AutoRouter.of(context).replaceAll([UnverifiedUserView()]);
        return true;
      }

      //Check if the user is a business
      if (user.permission == UserPermissions.business) {
        if (!context.mounted) return false;
        //We suscribe the user to the business user channel
        final businessTopic = locator.get<AppConstants>().businessUserTopic;
        locator.get<CloudMessageService>().subscribeToTopic(businessTopic);
        emit(const AuthState(authStatus: AuthStatus.businessLoggedIn));
        //And we replace the current route with the business dashboard
        AutoRouter.of(context).replaceAll([const BusinessDashBoardView()]);
        return true;
      }

      //If the user is a normal user, we suscribe the user to the default topics
      await setInitialTopicsForUser();

      //If the user is logged in and verified, we emit the userLoggedIn state
      if (!context.mounted) return false;
      AutoRouter.of(context).replaceAll([const DashBoardView()]);
      return true;
    } catch (e) {
      log('Error: $e, Function: logIn, File: auth_cubit.dart');
      return false;
    }
  }

  //This method is used to sign up the user or a business user with out a business
  Future<bool> signUp(
      Map<String, dynamic> userData, XFile? identification) async {
    try {
      //First we create the user in firebase auth
      final uid = await getIt<AuthService>().signUpWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      //Then we add the uid to the user data
      userData['uid'] = uid;

      await createUserInFirestore(userData);

      //Then we save in firebase storage the identification image if the user is not a business
      if (identification != null) {
        await getIt
            .get<FireStorageService>()
            .uploadUserIdentification(identification, uid);
      }

      //Get user information from firestore
      final usersCollection = getIt.get<AppConstants>().usersCollection;
      //Set the new user device notification token
      locator
          .get<CloudMessageService>()
          .handleDeviceNotificationToken(null, usersCollection, uid);

      //Check if the user is a business user
      if (identification != null) {
        //If is business user Then we suscribe the user to the business channel
        final businessTopic = locator.get<AppConstants>().businessUserTopic;
        locator.get<CloudMessageService>().subscribeToTopic(businessTopic);
      } else {
        //If is normal user Then we suscribe the user to the user channel
        await setInitialTopicsForUser();
      }

      //And return true or false in case of error
      return true;
    } catch (e) {
      log('Error: $e, Function: signUp, File: auth_cubit.dart');
      return false;
    }
  }

  //This method is used to sign up the business with the owner user
  Future<bool> signUpBusiness(Map<String, dynamic> userData,
      Map<String, dynamic> businessData, XFile? identification) async {
    try {
      //First we create the user from the business info in firebase auth
      final uid = await getIt<AuthService>().signUpWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      //Then we add the uid to the user data
      userData['uid'] = uid;

      //Then we create the user in firestore
      await createUserInFirestore(userData);

      //Then we save in firebase storage the RUT image
      if (identification != null) {
        await getIt
            .get<FireStorageService>()
            .uploadBusinessRut(identification, uid);
      }

      //Then we add the owner_uid to the business data
      businessData['owner_uid'] = uid;

      //Then we create the business in firestore
      await createBusinessInFirestore(businessData);

      //Get user information from firestore
      final usersCollection = getIt.get<AppConstants>().usersCollection;
      //Check if the user has a device notification token and if not, we save it
      locator
          .get<CloudMessageService>()
          .handleDeviceNotificationToken(null, usersCollection, uid);

      //Then we suscribe the user to the business user channel
      final businessTopic = locator.get<AppConstants>().businessUserTopic;
      locator.get<CloudMessageService>().subscribeToTopic(businessTopic);

      //And return true or false in case of error
      return true;
    } catch (e) {
      log('Error: $e, Function: signUpBusiness, File: auth_cubit.dart');
      return false;
    }
  }

  //This method is used to log out the user
  Future<bool> logOut() async {
    try {
      //First we log out the user from firebase auth
      await getIt<AuthService>().signOut();
      //Then we return true or false in case of error
      return true;
    } catch (e) {
      log('Error: $e, Function: logOut, File: auth_cubit.dart');
      return false;
    }
  }

  //This method is used to restore the password
  Future<bool> restorePassword(String email) async {
    try {
      //First we send the password reset email
      await getIt<AuthService>().sendPasswordResetEmail(email);
      //Then we return true or false in case of error
      return true;
    } catch (e) {
      log('Error: $e, Function: restorePassword, File: auth_cubit.dart');
      return false;
    }
  }

  /*
   This method is used to create the user in firestore,
   it is called inside signUp method if the user is created in firebase auth,
  */
  Future<void> createUserInFirestore(Map<String, dynamic> userData) async {
    //We create the user in firestore
    await getIt<FirestoreService>().createDocument(
      locator<AppConstants>().usersCollection,
      userData,
    );
  }

  //This method is used to create a business in firestore,
  Future<void> createBusinessInFirestore(
      Map<String, dynamic> businessData) async {
    //We create the business in firestore
    await getIt<FirestoreService>().createDocument(
      locator<AppConstants>().businessCollection,
      businessData,
    );
  }

  //This method is used for the appEntryPoint states
  void getUserInformation() async {
    try {
      emit(state.copyWith(authStatus: AuthStatus.loading));

      //Check if the user is logged in
      final userIsLoggedIn = getIt.get<AuthService>().checkUserSession();
      if (!userIsLoggedIn) {
        emit(const AuthState(authStatus: AuthStatus.userNotLoggedIn));
        return;
      }

      //Check if the user status is active (Verified)
      final userUid = getIt.get<AuthService>().getUserId();
      final userJson = await getIt.get<FirestoreService>().readDocumentById(
          getIt.get<AppConstants>().usersCollection, userUid, "uid");
      final user = User.fromJson(userJson);
      if (!user.verified) {
        emit(const AuthState(authStatus: AuthStatus.userLoggedInNotVerified));
        return;
      }

      //Check if the user is a business
      if (user.permission == UserPermissions.business) {
        emit(const AuthState(authStatus: AuthStatus.businessLoggedIn));
        return;
      }

      //If the user is logged in and verified, we emit the userLoggedIn state
      emit(const AuthState(authStatus: AuthStatus.userLoggedIn));
    } catch (e) {
      log('Error: $e, Function: getUserInformation, File: auth_cubit.dart');
      emit(const AuthState(authStatus: AuthStatus.error));
    }
  }

  //This method handles the normal user subscription to the default topics
  Future<void> setInitialTopicsForUser() async {
    final normalTopic = locator.get<AppConstants>().normalUserTopic;
    final favoritesTopic = locator.get<AppConstants>().favoriteTopic;
    final discoverPromotionsTopic = locator.get<AppConstants>().discoverTopic;

    //We check if the user already has a device notification preferences
    final containsDiscoverTopicKey = await locator
        .get<SharedPreferencesService>()
        .containsKey(discoverPromotionsTopic);

    final containsFavoritesTopicKey = await locator
        .get<SharedPreferencesService>()
        .containsKey(favoritesTopic);

    //If the user doesn't have a device notification preferences, we save it
    if (!containsDiscoverTopicKey && !containsFavoritesTopicKey) {
      await locator.get<CloudMessageService>().subscribeToTopic(normalTopic);

      await locator
          .get<SharedPreferencesService>()
          .setBool(favoritesTopic, true);
      await locator.get<CloudMessageService>().subscribeToTopic(favoritesTopic);

      await locator
          .get<SharedPreferencesService>()
          .setBool(discoverPromotionsTopic, true);
      await locator
          .get<CloudMessageService>()
          .subscribeToTopic(discoverPromotionsTopic);

      return;
    }

    //If the user already has a device notification preferences, we subscribe the user to the default topics
    await locator.get<CloudMessageService>().subscribeToTopic(normalTopic);

    final favoritesTopicSavedValue =
        await locator.get<SharedPreferencesService>().getBool(favoritesTopic);

    favoritesTopicSavedValue
        ? await locator
            .get<CloudMessageService>()
            .subscribeToTopic(favoritesTopic)
        : null;

    final discoverTopicSavedValue = await locator
        .get<SharedPreferencesService>()
        .getBool(discoverPromotionsTopic);

    discoverTopicSavedValue
        ? await locator
            .get<CloudMessageService>()
            .subscribeToTopic(discoverPromotionsTopic)
        : null;
  }
}
