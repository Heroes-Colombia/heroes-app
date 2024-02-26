import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
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

  void setSelectedCategoryId(String? categoryId) {
    emit(
      state.copyWith(
        status: BusinessViewCubitStatus.loading,
        selectedCategoryId: categoryId,
      ),
    );
  }

  void handleOnPop(BuildContext context) {
    emit(
      state.copyWith(
        status: BusinessViewCubitStatus.initial,
        businesses: [],
        selectedCategoryId: "",
      ),
    );
    Navigator.of(context).pop();
  }

  //This method is used to get all the businesses from the firestore service
  void getBusinesses() async {
    try {
      //We get the collection name from the app constants
      final collectionName = locator.get<AppConstants>().businessCollection;

      var businesses = List<ListableBusiness>.empty();
      //We check if the selectedCategoryId is not null to filter the businesses by category
      if (state.selectedCategoryId.isEmpty) {
        //We get the businesses from the firestore service
        final rawBusinesses = await locator<FirestoreService>()
            .readAllActiveDocuments(collectionName);

        //We convert the raw businesses to a list of ListableBusiness
        businesses =
            rawBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();
        //We emit the state with the new businesses
      } else {
        //We get the businesses from the firestore service filtreing by category
        final rawBusinesses = await locator<FirestoreService>()
            .readDocumentsWhereArrayContainsId(
                collectionName, 'categories', state.selectedCategoryId);

        //We convert the raw businesses to a list of ListableBusiness
        businesses =
            rawBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();
      }
      //We emit the state with the new businesses
      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        businesses: businesses,
      ));
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
      emit(state.copyWith(
        categories: businessCategories,
      ));
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log('Error: $e, Function: getBusinessCategories, File: all_business_cubit.dart');
    }
  }
}
