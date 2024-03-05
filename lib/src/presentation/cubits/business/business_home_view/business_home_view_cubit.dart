import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'business_home_view_state.dart';

class BusinessHomeViewCubit extends Cubit<BusinessHomeViewState> {
  BusinessHomeViewCubit() : super(const BusinessHomeViewState());

  final locator = GetIt.instance;

  //This method is used to get the initial state of BusinessHomeViewCubit
  void getInitial() {
    emit(const BusinessHomeViewState(
        businessHomeViewState: BusinessViewCubitStatus.initial));
  }

  //This method is used to get the loading state of BusinessHomeViewCubit
  void getRequiredData() async {
    //We emit the loading state
    emit(const BusinessHomeViewState(
        businessHomeViewState: BusinessViewCubitStatus.loading));
    try {
      //We get the business collection
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //We get the featured businesses from firestore
      final featuredBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveDocumentsByCondition(
              businessCollection, "featured", true, 5);

      //We convert the raw data to a list of business
      final featuredBusiness =
          featuredBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //We get the normal businesses from firestore
      final normalBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveDocumentsByCondition(
              businessCollection, "featured", false, 5);

      //we convert the raw data to a list of business
      final normalBusiness =
          normalBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Then we get the business categories from firestore
      final businessCategoriesRaw = await locator
          .get<FirestoreService>()
          .readAllActiveDocuments(
              locator.get<AppConstants>().businessCategoryCollection);

      //We convert the raw data to a list of business categories
      final businessCategories = businessCategoriesRaw
          .map((e) => BusinessCategory.fromJson(e))
          .toList();

      //Then we add the first category data to the list of business categories
      for (var business in normalBusiness) {
        business.category = businessCategories.firstWhere(
            (category) => category.id == business.categoryIds.first);
      }

      for (var business in featuredBusiness) {
        business.category = businessCategories.firstWhere(
            (category) => category.id == business.categoryIds.first);
      }

      emit(
        state.copyWith(
          businessHomeViewState: BusinessViewCubitStatus.success,
          featuredBusinesses: featuredBusiness,
          normalBusinesses: normalBusiness,
          businessCategories: businessCategories,
        ),
      );
    } catch (e) {
      log('Error: $e, Function: getRequiredData, File: business_home_view_cubit.dart');
      emit(
        state.copyWith(businessHomeViewState: BusinessViewCubitStatus.error),
      );
    }
  }
}
