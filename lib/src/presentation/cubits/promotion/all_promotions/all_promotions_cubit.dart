import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/promotion_filter.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'all_promotions_state.dart';

class AllPromotionsCubit extends Cubit<AllPromotionsState> {
  AllPromotionsCubit() : super(const AllPromotionsState());
  final locator = GetIt.instance;

  //This is the first method that is called when the cubit is created
  void getInitial() {
    emit(state.copyWith(status: PromotionViewCubitStatus.loading));
  }

  void setInitialFilter(PromotionFilter? filter) {
    if (filter != null) {
      emit(
        state.copyWith(
          status: PromotionViewCubitStatus.loading,
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
        status: PromotionViewCubitStatus.loading,
        selectedCategoryId: categoryId,
        filter: updatedFilter,
      ),
    );
  }

  void handleOnPop(BuildContext context) {
    emit(
      state.copyWith(
        status: PromotionViewCubitStatus.initial,
        promotions: [],
        selectedCategoryId: "",
        filter: const PromotionFilter(),
      ),
    );
    Navigator.of(context).pop();
  }

  //This method is used to get all the promotions from the firestore service
  void getPromotions() async {
    try {
      //We get the collection names from the app constants
      final promotionsCollection = locator.get<AppConstants>().advertisementCollection;
      final businessCollection = locator.get<AppConstants>().businessCollection;

      // Get all active promotions (no Firestore filtering, will filter client-side)
      final rawPromotions = await locator<FirestoreService>()
          .readAllActiveDocuments(promotionsCollection);

      //Convert the raw promotions to a list of Promotion
      var promotions =
          rawPromotions.map((e) => Promotion.fromJson(e)).toList();

      // Filter out expired promotions
      promotions = promotions.where((promotion) {
        return !promotion.isExpired;
      }).toList();

      // Get unique business IDs from promotions
      final businessIds = promotions
          .map((promotion) => promotion.businessId)
          .toSet()
          .toList();

      // Fetch full business data (names and categories) for all promotions
      final businessDataList = await locator<FirestoreService>()
          .readAllDocumentsByDocumentIDs(businessCollection, businessIds);

      // Create maps for business names and categories
      final Map<String, String> businessNamesMap = {};
      final Map<String, List<String>> businessCategoriesMap = {};

      for (var businessData in businessDataList) {
        final businessId = businessData['id'] as String;
        businessNamesMap[businessId] = businessData['name'] as String? ?? '';

        if (businessData['categories'] != null) {
          businessCategoriesMap[businessId] = List<String>.from(businessData['categories']);
        } else {
          businessCategoriesMap[businessId] = [];
        }
      }

      // Add business names and categories to promotions
      promotions = promotions.map((promotion) {
        final businessName = businessNamesMap[promotion.businessId];
        final businessCategories = businessCategoriesMap[promotion.businessId];
        return promotion.copyWith(
          businessName: businessName,
          businessCategories: businessCategories,
        );
      }).toList();

      // Apply client-side category filter if specified
      if (state.filter.categoryId != null && state.filter.categoryId!.isNotEmpty) {
        promotions = promotions.where((promotion) {
          return promotion.businessCategories?.contains(state.filter.categoryId) ?? false;
        }).toList();
      }

      // Sort promotions: Higher percentage first, then more urgent (fewer days until expiration)
      promotions.sort((a, b) {
        // Primary sort: Higher percentage first
        final percentageComparison = b.percentage.compareTo(a.percentage);
        if (percentageComparison != 0) return percentageComparison;

        // Secondary sort: More urgent (fewer days) first
        return a.daysUntilExpiration.compareTo(b.daysUntilExpiration);
      });

      //We emit the state with the new promotions
      emit(
        state.copyWith(
          status: PromotionViewCubitStatus.success,
          promotions: promotions,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PromotionViewCubitStatus.error));
      log('Error: $e, Function: getPromotions, File: all_promotions_cubit.dart');
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
      emit(state.copyWith(status: PromotionViewCubitStatus.error));
      log(
        'Error: $e, Function: getBusinessCategories, File: all_promotions_cubit.dart',
      );
    }
  }
}
