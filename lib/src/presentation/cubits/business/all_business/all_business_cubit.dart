import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/business_filter.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'all_business_state.dart';

class AllBusinessCubit extends Cubit<AllBusinessState> {
  AllBusinessCubit() : super(const AllBusinessState());
  final locator = GetIt.instance;

  //This is the first method that is called when the cubit is created
  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  void setInitialFilter(BusinessFilter? filter) {
    if (filter != null) {
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.loading,
          filter: filter,
          selectedCategoryId: filter.categoryId ?? '',
        ),
      );
    }
  }

  void setSelectedCategoryId(String? categoryId) {
    // Update both the selectedCategoryId and the filter
    final updatedFilter = state.filter.copyWith(
      categoryId: categoryId ?? '',
    );
    emit(
      state.copyWith(
        status: BusinessViewCubitStatus.loading,
        selectedCategoryId: categoryId,
        filter: updatedFilter,
      ),
    );
  }

  void handleOnPop(BuildContext context) {
    emit(
      state.copyWith(
        status: BusinessViewCubitStatus.initial,
        businesses: [],
        selectedCategoryId: "",
        filter: const BusinessFilter(),
      ),
    );
    Navigator.of(context).pop();
  }

  //This method is used to get all the businesses from the firestore service
  void getBusinesses() async {
    try {
      //We get the collection name from the app constants
      final collectionName = locator.get<AppConstants>().businessCollection;

      List<Map<String, dynamic>> rawBusinesses;

      //First, apply Firestore-level filters (category, featured)
      if (state.filter.categoryId != null && state.filter.categoryId!.isNotEmpty) {
        // Filter by category
        rawBusinesses = await locator<FirestoreService>()
            .readDocumentsWhereArrayContainsId(
              collectionName,
              'categories',
              state.filter.categoryId!,
            );
      } else if (state.filter.featuredOnly == true) {
        // Filter by featured status
        rawBusinesses = await locator<FirestoreService>()
            .readActiveDocumentsByCondition(
              collectionName,
              'featured',
              true,
              1000, // Get all featured businesses
            );
      } else {
        // Get all active businesses
        rawBusinesses = await locator<FirestoreService>()
            .readAllActiveDocuments(collectionName);
      }

      //Convert the raw businesses to a list of ListableBusiness
      var businesses =
          rawBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();

      //Apply client-side filters (business type, additional featured filtering)
      if (state.filter.businessTypes != null && state.filter.businessTypes!.isNotEmpty) {
        businesses = businesses.where((business) {
          return state.filter.businessTypes!.contains(business.type);
        }).toList();
      }

      // If featured filter is combined with category, apply it client-side
      if (state.filter.featuredOnly == true && state.filter.categoryId != null) {
        businesses = businesses.where((business) => business.featured).toList();
      }

      //We emit the state with the new businesses
      emit(
        state.copyWith(
          status: BusinessViewCubitStatus.success,
          businesses: businesses,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log('Error: $e, Function: getBusinesses, File: all_business_cubit.dart');
    }
  }

  void getBusinessCategories() async {
    try {
      final categoriesCollectionName =
          locator.get<AppConstants>().businessCategoryCollection;

      //We get the categories from the firestore service
      final categories = await locator<FirestoreService>()
          .readAllActiveDocuments(categoriesCollectionName);
      //We convert the raw categories to a list of BusinessCategories
      final businessCategories =
          categories.map((e) => BusinessCategory.fromJson(e)).toList();

      //We emit the state with the new business categories
      emit(state.copyWith(categories: businessCategories));
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log(
        'Error: $e, Function: getBusinessCategories, File: all_business_cubit.dart',
      );
    }
  }
}
