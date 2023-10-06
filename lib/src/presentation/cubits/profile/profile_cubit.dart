import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());
  final locator = GetIt.instance;

  void restoreProfileState() {
    //If the current state is ProfileError, we try to restore the previous state
    if (state is ProfileError) {
      emit(const ProfileInitial(user: null));
    }
  }

  void getInitialProfileInfo() {
    getProfileInfo();
  }

  void getProfileInfo() async {
    try {
      final userCollection = locator.get<AppConstants>().usersCollection;
      final userId = locator.get<AuthService>().getUserId();
      final userRawInfo = await locator
          .get<FirestoreService>()
          .readDocumentById(userCollection, userId, 'uid');
      final user = User.fromJson(userRawInfo);
      emit(ProfileLoaded(user: user));
    } catch (e) {
      log(e.toString());
      emit(ProfileError());
    }
  }

  Future<void> updateProfileInfo(Map<String, dynamic> data) async {
    try {
      final userCollection = locator.get<AppConstants>().usersCollection;
      final userId = locator.get<AuthService>().getUserId();
      await locator
          .get<FirestoreService>()
          .editDocumentById(userCollection, userId, 'uid', data);
      getProfileInfo();
    } catch (e) {
      log(e.toString());
      emit(ProfileError());
    }
  }
}
