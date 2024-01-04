import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'owned_businesses_state.dart';

class OwnedBusinessesCubit extends Cubit<OwnedBusinessesState> {
  OwnedBusinessesCubit() : super(const OwnedBusinessesState());
  final locator = GetIt.instance;

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  //This method is used to get the businesses that the user can manage
  Future<void> getOwnedBusinesses() async {
    try {
      //First we get the collection name from the constants file
      final collectionName = locator.get<AppConstants>().businessCollection;
      final user = await locator.get<AuthService>().getBusinessUser();

      final ownedBusinessesIds = user!.ownedBusinesses;

      final List<ListableBusiness> businesses = [];

      //We get the business that the user owns
      final rawOwnerBusinesses = await locator<FirestoreService>()
          .readActiveDocumentsByCondition(
              collectionName, "owner_uid", user.uid, 1);
      final ownerBusinesses =
          rawOwnerBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();

      //Check if the user is not managing any business
      if (ownedBusinessesIds.isEmpty) {
        businesses.addAll(ownerBusinesses);
        emit(state.copyWith(
          status: BusinessViewCubitStatus.success,
          businesses: businesses,
        ));
        return;
      }

      //We get the businesses that the user manages
      final rawManagedBusinesses = await locator<FirestoreService>()
          .readActiveDocumentsByDocumentIDs(collectionName, ownedBusinessesIds);

      final managedBusinesses = rawManagedBusinesses
          .map((e) => ListableBusiness.fromJson(e))
          .toList();

      //We check if we have the owned business inside our managed businesses list
      businesses.addAll(ownerBusinesses);
      businesses.addAll(managedBusinesses
          .where((element) => !ownerBusinesses.contains(element)));

      //We emit the state with the businesses
      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        businesses: businesses,
      ));
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log('Error: $e, Function: ownedBusinesses, File: owned_business_cubit.dart');
    }
  }
}
