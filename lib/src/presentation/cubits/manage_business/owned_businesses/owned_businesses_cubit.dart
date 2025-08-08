import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
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
          .readAllDocumentsByCondition(
            collectionName,
            "owner_uid",
            user.uid,
            99,
          );
      final ownerBusinesses =
          rawOwnerBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();

      // Add owner businesses to the list
      businesses.addAll(ownerBusinesses);

      // Get businesses that the user manages (if any)
      if (ownedBusinessesIds.isNotEmpty) {
        final rawManagedBusinesses = await locator<FirestoreService>()
            .readAllDocumentsByDocumentIDs(collectionName, ownedBusinessesIds);

        final managedBusinesses =
            rawManagedBusinesses
                .map((e) => ListableBusiness.fromJson(e))
                .toList();

        // Add managed businesses that aren't already in the owner list
        businesses.addAll(
          managedBusinesses.where(
            (element) => !ownerBusinesses.contains(element),
          ),
        );
      }

      // Get the business categories from firestore
      final businessCategoriesRaw = await locator
          .get<FirestoreService>()
          .readAllActiveDocuments(
            locator.get<AppConstants>().businessCategoryCollection,
          );

      // Convert raw data to a list of business categories
      final businessCategories =
          businessCategoriesRaw
              .map((e) => BusinessCategory.fromJson(e))
              .toList();

      // Set the category for each business (using the first category ID)
      for (var business in businesses) {
        if (business.categoryIds.isNotEmpty) {
          try {
            business.category = businessCategories.firstWhere(
              (category) => category.id == business.categoryIds.first,
            );
          } catch (e) {
            // If the category isn't found, log it
            log(
              'Category not found for business ${business.id}, categoryId: ${business.categoryIds.first}',
            );
          }
        }
      }

      //We emit the state with the businesses
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          businesses: businesses,
          businessCategories: businessCategories,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log(
        'Error: $e, Function: ownedBusinesses, File: owned_business_cubit.dart',
      );
    }
  }
}
