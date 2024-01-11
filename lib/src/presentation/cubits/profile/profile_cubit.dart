import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/repositories/shared_preferences_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());
  final locator = GetIt.instance;

  //This method is used to restore the previous state of the cubit
  void restoreProfileState() {
    //If the current state is ProfileError, we try to restore the previous state
    if (state is ProfileError) {
      emit(const ProfileInitial(user: null));
    }
  }

  //This method is used to get the initial profile info
  void getInitialProfileInfo() {
    getProfileInfo();
  }

  //This method is used to get the profile info
  void getProfileInfo() async {
    try {
      //First collect the user info collection from Firestore
      final userCollection = locator.get<AppConstants>().usersCollection;
      //Then get the user id from the auth service
      final userId = locator.get<AuthService>().getUserId();
      //Then get the user info from the firestore collection
      final userRawInfo = await locator
          .get<FirestoreService>()
          .readDocumentById(userCollection, userId, 'uid');
      //Finally create a user object from the raw info and emit the new state
      final user = User.fromJson(userRawInfo);
      emit(ProfileLoaded(user: user));
    } catch (e) {
      log("Error: $e, Function: getProfileInfo, File: profile_cubit.dart");
      emit(ProfileError());
    }
  }

  //This method is used to update the profile info
  Future<void> updateProfileInfo(Map<String, dynamic> data) async {
    try {
      //First collect the userCollection info from Firestore
      final userCollection = locator.get<AppConstants>().usersCollection;
      //Then get the user id from the auth service
      final userId = locator.get<AuthService>().getUserId();
      //Then update the user info from the firestore collection
      await locator
          .get<FirestoreService>()
          .editDocumentById(userCollection, userId, 'uid', data);
      //Finally call getProfileInfo() to get the updated info
      getProfileInfo();
    } catch (e) {
      log("Error: $e, Function: updateProfileInfo, File: profile_cubit.dart");
      emit(ProfileError());
    }
  }

  //This method is used to check if the user has notification preferences saved on the device
  Future<bool> getNotificationPreferencesForTopic(String topic) async {
    final isTopicActive =
        await locator.get<SharedPreferencesService>().getBool(topic);

    return isTopicActive;
  }

  //This method is used to check if the user has notification preferences saved on the device
  Future<bool> setNotificationPreferencesForTopic(String topic) async {
    final isTopicActive =
        await locator.get<SharedPreferencesService>().getBool(topic);
    await locator
        .get<SharedPreferencesService>()
        .setBool(topic, !isTopicActive);

    return isTopicActive;
  }
}
