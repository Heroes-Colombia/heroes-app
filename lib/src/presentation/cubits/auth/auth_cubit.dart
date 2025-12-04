import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/auth_result.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/cloud_message_service.dart';
import 'package:heroes_app/src/domain/repositories/firestorage_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/repositories/shared_preferences_service.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:heroes_app/src/locator.dart';
import 'package:image_picker/image_picker.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());
  final getIt = GetIt.instance;

  //This method is used to log in the user
  Future<AuthResult> logIn(
    Map<String, dynamic> userData,
    BuildContext context,
  ) async {
    try {
      // Note: We don't need to reset the ProfileCubit here directly
      // The profile state will be reset in the ProfileView during logout
      // This prevents dependency issues with GetIt

      //First we log in the user in firebase auth
      await getIt<AuthService>().signInWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      //Then we get the user information from firestore
      final usersCollection = getIt.get<AppConstants>().usersCollection;
      final userUid = getIt.get<AuthService>().getUserId();
      final userJson = await getIt.get<FirestoreService>().readDocumentById(
        usersCollection,
        userUid,
        "uid",
      );
      final user = User.fromJson(userJson);

      //Check if the user is a business - block them from logging in via mobile app
      if (user.permission == UserPermissions.business) {
        // Log out the business user immediately
        await getIt<AuthService>().signOut();

        // Return error message directing them to web dashboard
        return AuthResult.failure(
          errorMessage:
              'Esta cuenta es de negocio, por favor use la plataforma web en app.heroescolombia.com',
        );
      }

      //Check if the user has a device notification token and if not, we save it
      await locator.get<CloudMessageService>().handleDeviceNotificationToken(
        user.deviceNotificationToken,
        usersCollection,
        userUid,
      );

      //Check if the user status is active (Verified)
      if (!user.verified) {
        if (!context.mounted)
          return AuthResult.failure(errorMessage: 'Context no disponible');
        AutoRouter.of(context).replaceAll([UnverifiedUserView()]);
        return AuthResult.unverified();
      }

      //IT IS DISABLED FOR NOW AS BUSINESSES WILL USE THE DASHBOARD WEB
      //Check if the user is a business
      // if (user.permission == UserPermissions.business) {
      //   if (!context.mounted)
      //     return AuthResult.failure(errorMessage: 'Context no disponible');
      //   //We suscribe the user to the business user channel
      //   final businessTopic = locator.get<AppConstants>().businessUserTopic;
      //   locator.get<CloudMessageService>().subscribeToTopic(businessTopic);
      //   emit(const AuthState(authStatus: AuthStatus.businessLoggedIn));
      //   //And we replace the current route with the business dashboard
      //   AutoRouter.of(context).replaceAll([const BusinessDashBoardView()]);
      //   return AuthResult.success();
      // }

      //If the user is a normal user, we suscribe the user to the default topics
      await setInitialTopicsForUser();

      //If the user is logged in and verified, we emit the userLoggedIn state
      if (!context.mounted)
        return AuthResult.failure(errorMessage: 'Context no disponible');
      AutoRouter.of(context).replaceAll([DashBoardView()]);
      return AuthResult.success();
    } catch (e) {
      log('Error: $e, Function: logIn, File: auth_cubit.dart');
      return AuthResult.fromFirebaseException(e);
    }
  }

  //This method is used to sign up the user (no image needed - will be verified via OCR later)
  Future<AuthResult> signUp(Map<String, dynamic> userData) async {
    try {
      //First we create the user in firebase auth
      final uid = await getIt<AuthService>().signUpWithEmailAndPassword(
        userData['email'],
        userData['password'],
      );

      //Then we add the uid to the user data
      userData['uid'] = uid;

      await createUserInFirestore(userData);

      //Get user information from firestore
      final usersCollection = getIt.get<AppConstants>().usersCollection;
      //Set the new user device notification token
      locator.get<CloudMessageService>().handleDeviceNotificationToken(
        null,
        usersCollection,
        uid,
      );

      //Subscribe user to the regular user channel (they will be verified via OCR)
      await setInitialTopicsForUser();

      //Return success result with userId
      return AuthResult.success(userId: uid);
    } catch (e) {
      log('Error: $e, Function: signUp, File: auth_cubit.dart');
      return AuthResult.fromFirebaseException(e);
    }
  }

  //This method is used to sign up the business with the owner user
  Future<AuthResult> signUpBusiness(
    Map<String, dynamic> userData,
    Map<String, dynamic> businessData,
    XFile? identification,
  ) async {
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
        await getIt.get<FireStorageService>().uploadBusinessRut(
          identification,
          uid,
        );
      }

      //Then we add the owner_uid to the business data
      businessData['owner_uid'] = uid;

      //Then we create the business in firestore
      await createBusinessInFirestore(businessData);

      //Get user information from firestore
      final usersCollection = getIt.get<AppConstants>().usersCollection;
      //Check if the user has a device notification token and if not, we save it
      locator.get<CloudMessageService>().handleDeviceNotificationToken(
        null,
        usersCollection,
        uid,
      );

      //Then we suscribe the user to the business user channel
      final businessTopic = locator.get<AppConstants>().businessUserTopic;
      locator.get<CloudMessageService>().subscribeToTopic(businessTopic);

      //And return success result with userId
      return AuthResult.success(userId: uid);
    } catch (e) {
      log('Error: $e, Function: signUpBusiness, File: auth_cubit.dart');
      return AuthResult.fromFirebaseException(e);
    }
  }

  //This method is used to delete a user account and cleanup data when signup fails
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user document from Firestore
      final usersCollection = getIt.get<AppConstants>().usersCollection;
      await getIt.get<FirestoreService>().deleteDocumentByDocumentProperty(
        usersCollection,
        'uid',
        userId,
      );

      // Delete user from Firebase Auth
      await getIt<AuthService>().deleteAccount();

      log('Successfully cleaned up user account: $userId');
    } catch (e) {
      log('Error deleting user account $userId: $e');
      throw Exception('Error limpiando cuenta de usuario');
    }
  }

  //This method is used to log out the user
  Future<bool> logOut() async {
    try {
      //First we log out the user from firebase auth
      await getIt<AuthService>().signOut();

      //Then we unsubscribe the user from all topics
      locator.get<CloudMessageService>().unsubscribeFromTopic(
        locator.get<AppConstants>().normalUserTopic,
      );
      locator.get<CloudMessageService>().unsubscribeFromTopic(
        locator.get<AppConstants>().favoriteTopic,
      );
      locator.get<CloudMessageService>().unsubscribeFromTopic(
        locator.get<AppConstants>().discoverTopic,
      );
      locator.get<CloudMessageService>().unsubscribeFromTopic(
        locator.get<AppConstants>().businessUserTopic,
      );

      // Note: We don't need to reset the ProfileCubit here
      // It will automatically reset when the user logs in again
      // or navigates to a new route

      //Then we return true or false in case of error
      return true;
    } catch (e) {
      log('Error: $e, Function: logOut, File: auth_cubit.dart');
      return false;
    }
  }

  Future<bool> deleteAccount(BuildContext context, dynamic texts) async {
    try {
      final userUid = getIt.get<AuthService>().getUserId();
      //First we mark the user as inactive
      await getIt.get<FirestoreService>().makeDocumentInactive(
        getIt.get<AppConstants>().usersCollection,
        "uid",
        userUid,
      );

      //then we delete the user from firebase auth
      final requiredRefreshLogin = await getIt<AuthService>().deleteAccount();

      if (!requiredRefreshLogin) {
        //In case that the token is expired, we show a dialog to the user
        if (!context.mounted) return false;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(texts["refresh-account-title"]!),
                content: Text(texts["refresh-account-confirmation"]!),
                actions: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(texts["confirm"]!),
                  ),
                ],
              ),
        );
      }

      //Then we return true or false in case of error
      return true;
    } catch (e) {
      log('Error: $e, Function: deleteAccount, File: auth_cubit.dart');
      return false;
    }
  }

  //This method is used to restore the password
  Future<AuthResult> restorePassword(String email) async {
    try {
      //First we send the password reset email
      await getIt<AuthService>().sendPasswordResetEmail(email);
      //Then we return success result
      return AuthResult.success();
    } catch (e) {
      log('Error: $e, Function: restorePassword, File: auth_cubit.dart');
      return AuthResult.fromFirebaseException(e);
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
    Map<String, dynamic> businessData,
  ) async {
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

      late final User user;

      try {
        final userJson = await getIt.get<FirestoreService>().readDocumentById(
          getIt.get<AppConstants>().usersCollection,
          userUid,
          "uid",
        );
        user = User.fromJson(userJson);
      } catch (e) {
        // User has Firebase Auth session but no Firestore document
        // This can happen if signup was incomplete or account was partially deleted
        log(
          'User document not found for UID: $userUid. Cleaning up auth session.',
        );

        // Sign out the orphaned auth session
        await getIt<AuthService>().signOut();
        emit(const AuthState(authStatus: AuthStatus.userNotLoggedIn));
        return;
      }
      if (!user.verified) {
        // Check if user is in the middle of verification process
        if (user.status == UserStatus.pending) {
          // User just signed up and needs to complete verification
          log(
            'User $userUid is in pending verification status - redirecting to verification flow',
          );
          emit(const AuthState(authStatus: AuthStatus.userNeedsVerification));
          return;
        } else {
          // User has failed verification or is in other non-verified state
          // For existing users without status field, treat as legacy unverified
          emit(const AuthState(authStatus: AuthStatus.userLoggedInNotVerified));
          return;
        }
      }

      //Check if the user is a business
      if (user.permission == UserPermissions.business) {
        emit(const AuthState(authStatus: AuthStatus.businessLoggedIn));
        return;
      }

      // V2: Initialize analytics session with user context (including V3 demographics)
      try {
        final analyticsService = locator.get<AnalyticsService>();
        analyticsService.initializeSession(
          userId: user.uid,
          userContext: {
            'rank': user.rank,
            'city': user.city ?? 'Bogotá', // City from GPS or default to Bogotá
            if (user.sex != null) 'sex': user.sex!, // V3 demographic
            if (user.ageRange != null)
              'age_range': user.ageRange!, // V3 demographic
          },
        );
      } catch (e) {
        log('Error initializing analytics session: $e');
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

    //We always subscribe the user to the normal topic
    await locator.get<CloudMessageService>().subscribeToTopic(normalTopic);

    //If the user doesn't have a device notification preferences, we create the default topics
    if (!containsDiscoverTopicKey && !containsFavoritesTopicKey) {
      await locator.get<SharedPreferencesService>().setBool(
        favoritesTopic,
        true,
      );
      await locator.get<CloudMessageService>().subscribeToTopic(favoritesTopic);

      await locator.get<SharedPreferencesService>().setBool(
        discoverPromotionsTopic,
        true,
      );
      await locator.get<CloudMessageService>().subscribeToTopic(
        discoverPromotionsTopic,
      );

      return;
    }

    //If the user already has a device notification preferences, we subscribe the user to the default topics
    await locator.get<CloudMessageService>().subscribeToTopic(normalTopic);

    final favoritesTopicSavedValue = await locator
        .get<SharedPreferencesService>()
        .getBool(favoritesTopic);

    favoritesTopicSavedValue
        ? await locator.get<CloudMessageService>().subscribeToTopic(
          favoritesTopic,
        )
        : null;

    final discoverTopicSavedValue = await locator
        .get<SharedPreferencesService>()
        .getBool(discoverPromotionsTopic);

    discoverTopicSavedValue
        ? await locator.get<CloudMessageService>().subscribeToTopic(
          discoverPromotionsTopic,
        )
        : null;
  }
}
