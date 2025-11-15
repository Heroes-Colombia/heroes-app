import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'favourite_businesses_state.dart';

class FavouriteBusinessesCubit extends Cubit<FavouriteBusinessesState> {
  FavouriteBusinessesCubit() : super(const FavouriteBusinessesState());
  final locator = GetIt.instance;

  void getInitial() {
    emit(state.copyWith(
      status: BusinessViewCubitStatus.loading,
      promotionsStatus: BusinessViewCubitStatus.loading,
    ));
  }

  Future<void> getFavouriteBusinesses() async {
    try {
      final collectionName = locator.get<AppConstants>().businessCollection;
      final categoriesCollectionName =
          locator.get<AppConstants>().businessCategoryCollection;

      final user = await locator.get<AuthService>().getUser();

      final favouriteBusinesses = user!.favouriteBusinesses;

      if (favouriteBusinesses.isEmpty) {
        emit(state.copyWith(
          status: BusinessViewCubitStatus.success,
          businesses: [],
        ));
        return;
      }

      final rawBusinessCategories = await locator<FirestoreService>()
          .readAllActiveDocuments(categoriesCollectionName);

      final rawBusinesses = await locator<FirestoreService>()
          .readActiveDocumentsByDocumentIDs(
              collectionName, favouriteBusinesses);

      final businesses =
          rawBusinesses.map((e) => ListableBusiness.fromJson(e)).toList();

      final categories = rawBusinessCategories
          .map((e) => BusinessCategory.fromJson(e))
          .toList();

      for (var business in businesses) {
        business.category = categories.firstWhere(
          (element) => element.id == business.categoryIds.first,
        );
      }

      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        businesses: businesses,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log('Error: $e, Function: getFavouriteBusinesses, File: favourite_business_cubit.dart');
    }
  }

  Future<void> getFavouritePromotions() async {
    try {
      final promotionsCollectionName = locator.get<AppConstants>().advertisementCollection;
      final user = await locator.get<AuthService>().getUser();
      final favouritePromotions = user!.favouritePromotions;

      if (favouritePromotions.isEmpty) {
        emit(state.copyWith(
          promotionsStatus: BusinessViewCubitStatus.success,
          promotions: [],
        ));
        return;
      }

      final rawPromotions = await locator<FirestoreService>()
          .readActiveDocumentsByDocumentIDs(
              promotionsCollectionName, favouritePromotions);

      final promotions =
          rawPromotions.map((e) => Promotion.fromJson(e)).toList();

      emit(state.copyWith(
        promotionsStatus: BusinessViewCubitStatus.success,
        promotions: promotions,
      ));
    } catch (e) {
      emit(state.copyWith(promotionsStatus: BusinessViewCubitStatus.error));
      log('Error: $e, Function: getFavouritePromotions, File: favourite_business_cubit.dart');
    }
  }
}
