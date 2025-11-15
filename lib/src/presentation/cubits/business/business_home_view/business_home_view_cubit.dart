import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/listable_business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

part 'business_home_view_state.dart';

class BusinessHomeViewCubit extends Cubit<BusinessHomeViewState> {
  BusinessHomeViewCubit() : super(const BusinessHomeViewState());
  final firestoreService = GetIt.instance.get<FirestoreService>();
  final authService = GetIt.instance.get<AuthService>();

  final locator = GetIt.instance;

  //This method is used to get the initial state of BusinessHomeViewCubit
  void getInitial() {
    emit(
      const BusinessHomeViewState(
        businessHomeViewState: BusinessViewCubitStatus.initial,
      ),
    );

    updateUserLastLocation();
  }

  //This method is used to get the loading state of BusinessHomeViewCubit
  void getRequiredData() async {
    //We emit the loading state
    emit(
      const BusinessHomeViewState(
        businessHomeViewState: BusinessViewCubitStatus.loading,
      ),
    );
    try {
      //We get the business collection
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //We get the featured businesses from firestore
      final featuredBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveDocumentsByCondition(
            businessCollection,
            "featured",
            true,
            5,
          );

      //We convert the raw data to a list of business
      final featuredBusiness =
          featuredBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //We get the normal businesses from firestore
      final normalBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveDocumentsByCondition(
            businessCollection,
            "featured",
            false,
            5,
          );

      //we convert the raw data to a list of business
      final normalBusiness =
          normalBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Then we get the business categories from firestore
      final businessCategoriesRaw = await locator
          .get<FirestoreService>()
          .readAllActiveDocuments(
            locator.get<AppConstants>().businessCategoryCollection,
          );

      //We convert the raw data to a list of business categories
      final businessCategories =
          businessCategoriesRaw
              .map((e) => BusinessCategory.fromJson(e))
              .toList();

      //We get the online businesses from firestore
      final onlineBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveDocumentsByCondition(
            businessCollection,
            "type",
            "online",
            5,
          );

      //we convert the raw data to a list of business
      final onlineBusiness =
          onlineBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Then we add the first category data to the list of business categories
      for (var business in normalBusiness) {
        business.category = businessCategories.firstWhere(
          (category) => category.id == business.categoryIds.first,
        );
      }

      for (var business in featuredBusiness) {
        business.category = businessCategories.firstWhere(
          (category) => category.id == business.categoryIds.first,
        );
      }

      for (var business in onlineBusiness) {
        business.category = businessCategories.firstWhere(
          (category) => category.id == business.categoryIds.first,
        );
      }

      // NEW: Fetch promotions for urgency badges and featured carousel
      final promotionsCollection = locator.get<AppConstants>().advertisementCollection;
      final rawPromotions = await locator<FirestoreService>()
          .readAllActiveDocuments(promotionsCollection);

      final allPromotions = rawPromotions
          .map((e) => Promotion.fromJson(e))
          .where((promo) => promo.status == PromotionStatus.active && !promo.isExpired)
          .toList();

      // Create map of businessId -> most urgent promotion (for badges)
      final Map<String, Promotion> businessPromotions = {};
      final urgentPromotions = allPromotions
          .where((promo) => promo.shouldShowUrgencyBadge)
          .toList();

      // Sort by urgency (most urgent first)
      urgentPromotions.sort((a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration));

      for (var promo in urgentPromotions) {
        if (!businessPromotions.containsKey(promo.businessId)) {
          businessPromotions[promo.businessId] = promo;
        }
      }

      // Create featured promotions list (top 10 by urgency + discount)
      final featuredPromotionsList = List<Promotion>.from(allPromotions);
      featuredPromotionsList.sort((a, b) {
        final urgencyCompare = a.daysUntilExpiration.compareTo(b.daysUntilExpiration);
        if (urgencyCompare != 0) return urgencyCompare;
        return b.percentage.compareTo(a.percentage); // Higher discount first
      });

      emit(
        state.copyWith(
          businessHomeViewState: BusinessViewCubitStatus.success,
          featuredBusinesses: featuredBusiness,
          normalBusinesses: normalBusiness,
          onlineBusinesses: onlineBusiness,
          businessCategories: businessCategories,
          businessPromotions: businessPromotions,
          featuredPromotions: featuredPromotionsList.take(10).toList(),
        ),
      );
    } catch (e) {
      log(
        'Error: $e, Function: getRequiredData, File: business_home_view_cubit.dart',
      );
      emit(
        state.copyWith(businessHomeViewState: BusinessViewCubitStatus.error),
      );
    }
  }

  //This method is used to update the user´s last location in the database for notifications based on location
  void updateUserLastLocation() async {
    final userLocation = await locator.get<AppMethods>().getUserLocation();
    if (userLocation == null) return;

    //Then we get the geoHash from the coordinates
    GeoFirePoint currentPosition = GeoFirePoint(
      GeoPoint(userLocation.latitude!, userLocation.longitude!),
    );

    //Then, we add the address and the location to the business
    final currentUserId = authService.getUserId();
    firestoreService.editDocumentById(
      locator.get<AppConstants>().usersCollection,
      currentUserId,
      "uid",
      {"geo_hash": currentPosition.data},
    );
  }
}
