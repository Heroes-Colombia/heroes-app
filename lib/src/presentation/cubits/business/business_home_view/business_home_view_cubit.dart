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
import 'package:heroes_app/src/domain/services/cache_service.dart';
import 'package:heroes_app/src/domain/services/location_service.dart';

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
          .readActiveFeaturedBusiness(businessCollection, "featured", true, 15);

      //We convert the raw data to a list of business
      final featuredBusiness =
          featuredBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Randomize featured businesses to avoid showing the same ones all the time
      featuredBusiness.shuffle();

      //We get the normal businesses from firestore with pagination
      final normalBusinessResponse = await locator
          .get<FirestoreService>()
          .readActiveDocumentsWithPagination(
            businessCollection,
            orderByField: 'updated_at',
            limit: 15,
            whereField: "type",
            whereValue: "physical",
          );

      //we convert the raw data to a list of business and filter by physical type only
      final normalBusinessRaw =
          normalBusinessResponse['documents'] as List<Map<String, dynamic>>;
      final normalBusiness =
          normalBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Randomize normal businesses to avoid showing the same ones all the time
      normalBusiness.shuffle();

      // Extract pagination metadata
      final lastNormalDoc =
          normalBusinessResponse['lastDocument'] as DocumentSnapshot?;
      final hasMoreNormal = normalBusinessResponse['hasMore'] as bool;

      //Then we get the business categories (with caching - 5 min TTL)
      final cacheService = locator.get<CacheService>();
      List<BusinessCategory> businessCategories;

      final cachedCategories = cacheService.get<List<BusinessCategory>>(
        CacheKeys.businessCategories,
      );
      if (cachedCategories != null) {
        businessCategories = cachedCategories;
      } else {
        final businessCategoriesRaw = await locator
            .get<FirestoreService>()
            .readAllActiveDocuments(
              locator.get<AppConstants>().businessCategoryCollection,
            );
        businessCategories =
            businessCategoriesRaw
                .map((e) => BusinessCategory.fromJson(e))
                .toList();
        cacheService.set(CacheKeys.businessCategories, businessCategories);
      }

      //We get the online businesses from firestore
      final onlineBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveFeaturedBusiness(businessCollection, "type", "online", 15);

      //we convert the raw data to a list of business
      final onlineBusiness =
          onlineBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Randomize online businesses to avoid showing the same ones all the time
      onlineBusiness.shuffle();

      // Get user location for distance calculation
      // OPTIMIZED: Use LocationService with caching (fetches once on startup, caches for 30 min)
      final userLocation = await LocationService().getUserLocation();
      final double? userLat = userLocation?.latitude;
      final double? userLng = userLocation?.longitude;

      //Then we add category and calculate distance for each business
      for (var business in normalBusiness) {
        if (business.categoryIds.isNotEmpty && businessCategories.isNotEmpty) {
          business.category = businessCategories.firstWhere(
            (category) => category.id == business.categoryIds.first,
            orElse: () => businessCategories.first,
          );
        }
        if (userLat != null && userLng != null) {
          business.calculateDistance(userLat, userLng);
        }
      }

      for (var business in featuredBusiness) {
        if (business.categoryIds.isNotEmpty && businessCategories.isNotEmpty) {
          business.category = businessCategories.firstWhere(
            (category) => category.id == business.categoryIds.first,
            orElse: () => businessCategories.first,
          );
        }
        if (userLat != null && userLng != null) {
          business.calculateDistance(userLat, userLng);
        }
      }

      for (var business in onlineBusiness) {
        if (business.categoryIds.isNotEmpty && businessCategories.isNotEmpty) {
          business.category = businessCategories.firstWhere(
            (category) => category.id == business.categoryIds.first,
            orElse: () => businessCategories.first,
          );
        }
        // Online businesses don't have physical distance
      }

      // NEW: Fetch promotions with pagination for carousel
      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;

      // Fetch promotions to ensure fair business distribution
      final promotionsResponse = await locator
          .get<FirestoreService>()
          .readActiveDocumentsWithPagination(
            promotionsCollection,
            orderByField: 'expired_at',
            limit: 100,
          );

      final rawPromotions =
          promotionsResponse['documents'] as List<Map<String, dynamic>>;
      final lastPromotionDoc =
          promotionsResponse['lastDocument'] as DocumentSnapshot?;
      final hasMorePromotions = promotionsResponse['hasMore'] as bool;

      final allPromotions =
          rawPromotions
              .map((e) => Promotion.fromJson(e))
              .where(
                (promo) =>
                    promo.status == PromotionStatus.active && !promo.isExpired,
              )
              .toList();

      // Filter promotions > 10% and randomize
      allPromotions.removeWhere((promotion) => promotion.percentage < 10);
      allPromotions.shuffle();

      // Apply fair distribution: Limit each business to max 1 promotion in carousel
      // This ensures all businesses get equal visibility
      final diversifiedPromotions = _diversifyPromotions(
        allPromotions,
        maxPerBusiness: 1,
      );

      // Fetch business names for all promotions (JOIN operation)
      final uniqueBusinessIds =
          diversifiedPromotions
              .map((promo) => promo.businessId)
              .toSet()
              .toList();

      final businessNamesMap = await locator<FirestoreService>()
          .readBusinessNamesByIds(businessCollection, uniqueBusinessIds);

      // Populate businessName field in each promotion
      final promotionsWithNames =
          diversifiedPromotions.map((promo) {
            return promo.copyWith(
              businessName: businessNamesMap[promo.businessId],
            );
          }).toList();

      // Create map of businessId -> most urgent promotion (for badges)
      // This uses ALL promotions for urgency badges, fetched separately
      final allRawPromotions = await locator<FirestoreService>()
          .readAllActiveDocuments(promotionsCollection);
      final allPromotionsForBadges =
          allRawPromotions
              .map((e) => Promotion.fromJson(e))
              .where(
                (promo) =>
                    promo.status == PromotionStatus.active && !promo.isExpired,
              )
              .toList();

      final Map<String, Promotion> businessPromotions = {};
      final urgentPromotions =
          allPromotionsForBadges
              .where((promo) => promo.shouldShowUrgencyBadge)
              .toList();

      // Sort by urgency (most urgent first)
      urgentPromotions.sort(
        (a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration),
      );

      for (var promo in urgentPromotions) {
        if (!businessPromotions.containsKey(promo.businessId)) {
          businessPromotions[promo.businessId] = promo;
        }
      }

      emit(
        state.copyWith(
          businessHomeViewState: BusinessViewCubitStatus.success,
          featuredBusinesses: featuredBusiness,
          normalBusinesses: normalBusiness,
          onlineBusinesses: onlineBusiness,
          businessCategories: businessCategories,
          businessPromotions: businessPromotions,
          featuredPromotions: promotionsWithNames,
          // Pagination metadata (normal businesses)
          lastNormalBusinessDoc: lastNormalDoc,
          hasMoreNormalBusinesses: hasMoreNormal,
          isLoadingMore: false,
          // Pagination metadata (promotions)
          lastPromotionDoc: lastPromotionDoc,
          hasMorePromotions: hasMorePromotions,
          isLoadingMorePromotions: false,
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

  //This method is used to load more promotions for infinite horizontal scroll
  Future<void> loadMorePromotions() async {
    // Check if we can load more
    if (!state.hasMorePromotions || state.isLoadingMorePromotions) {
      return;
    }

    try {
      // Set loading state
      emit(state.copyWith(isLoadingMorePromotions: true));

      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;
      final businessCollection = locator.get<AppConstants>().businessCollection;

      // Fetch MANY MORE promotions than needed to ensure fair business distribution
      // Larger batch size needed to get diverse businesses when some create 20+ promotions
      final promotionsResponse = await locator
          .get<FirestoreService>()
          .readActiveDocumentsWithPagination(
            promotionsCollection,
            orderByField: 'created_at',
            limit: 100,
            startAfterDocument: state.lastPromotionDoc,
          );

      // Convert to promotion models
      final rawPromotions =
          promotionsResponse['documents'] as List<Map<String, dynamic>>;
      final newPromotions =
          rawPromotions
              .map((e) => Promotion.fromJson(e))
              .where(
                (promo) =>
                    promo.status == PromotionStatus.active && !promo.isExpired,
              )
              .toList();

      newPromotions.removeWhere((promotion) => promotion.percentage < 10);
      newPromotions.shuffle();

      // Apply fair distribution considering ALREADY LOADED businesses
      // Get business IDs that are already in the carousel
      final alreadyLoadedBusinessIds =
          state.featuredPromotions
              .map((p) => p.businessId)
              .toSet()
              .cast<String>();

      // Diversify new promotions while respecting already loaded businesses
      final diversifiedNewPromotions = _diversifyPromotionsWithExisting(
        newPromotions,
        alreadyLoadedBusinessIds: alreadyLoadedBusinessIds,
        maxPerBusiness: 1,
      );

      // Fetch business names for new promotions (JOIN operation)
      final uniqueBusinessIds =
          diversifiedNewPromotions
              .map((promo) => promo.businessId)
              .toSet()
              .toList();

      final businessNamesMap = await locator<FirestoreService>()
          .readBusinessNamesByIds(businessCollection, uniqueBusinessIds);

      // Populate businessName field in each promotion
      final promotionsWithNames =
          diversifiedNewPromotions.map((promo) {
            return promo.copyWith(
              businessName: businessNamesMap[promo.businessId],
            );
          }).toList();

      // Extract pagination metadata
      final lastPromotionDoc =
          promotionsResponse['lastDocument'] as DocumentSnapshot?;
      final hasMorePromotions = promotionsResponse['hasMore'] as bool;

      // Append new promotions to existing list
      final updatedPromotions = [
        ...state.featuredPromotions,
        ...promotionsWithNames,
      ];

      emit(
        state.copyWith(
          featuredPromotions: updatedPromotions,
          lastPromotionDoc: lastPromotionDoc,
          hasMorePromotions: hasMorePromotions,
          isLoadingMorePromotions: false,
        ),
      );
    } catch (e) {
      log(
        'Error: $e, Function: loadMorePromotions, File: business_home_view_cubit.dart',
      );
      emit(state.copyWith(isLoadingMorePromotions: false));
    }
  }

  //This method is used to load more normal businesses for infinite scroll
  Future<void> loadMoreNormalBusinesses() async {
    // Check if we can load more
    if (!state.hasMoreNormalBusinesses || state.isLoadingMore) {
      return;
    }

    try {
      // Set loading state
      emit(state.copyWith(isLoadingMore: true));

      final businessCollection = locator.get<AppConstants>().businessCollection;

      // Fetch next page using cursor
      final normalBusinessResponse = await locator
          .get<FirestoreService>()
          .readActiveDocumentsWithPagination(
            businessCollection,
            orderByField: 'updated_at',
            limit: 10,
            startAfterDocument: state.lastNormalBusinessDoc,
            whereField: "type",
            whereValue: "physical",
          );

      // Convert to business models and filter by physical type only
      final normalBusinessRaw =
          normalBusinessResponse['documents'] as List<Map<String, dynamic>>;
      final newBusinesses =
          normalBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Randomize new businesses to avoid showing the same ones all the time
      newBusinesses.shuffle();

      // Get user location for distance calculation
      // OPTIMIZED: Use cached location from LocationService (instant response)
      final userLocation = await LocationService().getUserLocation();
      final double? userLat = userLocation?.latitude;
      final double? userLng = userLocation?.longitude;

      // Get categories and add to businesses, calculate distance
      final businessCategories = state.businessCategories;
      for (var business in newBusinesses) {
        if (business.categoryIds.isNotEmpty && businessCategories.isNotEmpty) {
          business.category = businessCategories.firstWhere(
            (category) => category.id == business.categoryIds.first,
            orElse: () => businessCategories.first,
          );
        }
        if (userLat != null && userLng != null) {
          business.calculateDistance(userLat, userLng);
        }
      }

      // Extract pagination metadata
      final lastNormalDoc =
          normalBusinessResponse['lastDocument'] as DocumentSnapshot?;
      final hasMoreNormal = normalBusinessResponse['hasMore'] as bool;

      // Append new businesses to existing list
      final updatedBusinesses = [...state.normalBusinesses, ...newBusinesses];

      emit(
        state.copyWith(
          normalBusinesses: updatedBusinesses,
          lastNormalBusinessDoc: lastNormalDoc,
          hasMoreNormalBusinesses: hasMoreNormal,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      log(
        'Error: $e, Function: loadMoreNormalBusinesses, File: business_home_view_cubit.dart',
      );
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  //This method is used to update the user´s last location in the database for notifications based on location
  //V2: Also captures and saves the user's city for analytics demographics
  void updateUserLastLocation() async {
    // OPTIMIZED: Use LocationService - will use cached location if available
    final userLocation = await LocationService().getUserLocation();
    if (userLocation == null) return;

    //Then we get the geoHash from the coordinates
    GeoFirePoint currentPosition = GeoFirePoint(
      GeoPoint(userLocation.latitude!, userLocation.longitude!),
    );

    // V2: Get city name from coordinates using reverse geocoding
    final city = await locator.get<AppMethods>().getCityFromLocation(
      userLocation.latitude,
      userLocation.longitude,
    );

    //Then, we add the geo_hash and city to the user document
    final currentUserId = authService.getUserId();
    firestoreService.editDocumentById(
      locator.get<AppConstants>().usersCollection,
      currentUserId,
      "uid",
      {
        "geo_hash": currentPosition.data, // For location-based notifications
        "city": city, // For analytics demographics
      },
    );
  }

  /// Helper method: Diversify promotions to ensure fair business representation
  /// Limits each business to a maximum number of promotions in the carousel
  List<Promotion> _diversifyPromotions(
    List<Promotion> promotions, {
    required int maxPerBusiness,
  }) {
    final Map<String, int> businessCount = {};
    final List<Promotion> diversified = [];

    // Iterate through promotions (already sorted by expired_at desc)
    for (final promo in promotions) {
      final currentCount = businessCount[promo.businessId] ?? 0;

      if (currentCount < maxPerBusiness) {
        diversified.add(promo);
        businessCount[promo.businessId] = currentCount + 1;
      }

      // Stop once we have enough promotions (10 for carousel)
      if (diversified.length >= 10) break;
    }

    return diversified;
  }

  /// Helper method: Diversify promotions considering already loaded businesses
  /// Used for pagination to ensure fair distribution across pages
  /// Skips businesses that already have their quota in the existing carousel
  List<Promotion> _diversifyPromotionsWithExisting(
    List<Promotion> newPromotions, {
    required Set<String> alreadyLoadedBusinessIds,
    required int maxPerBusiness,
  }) {
    final List<Promotion> diversified = [];

    // Iterate through new promotions (already sorted by expired_at desc)
    for (final promo in newPromotions) {
      // If maxPerBusiness is 1 and business already loaded, skip
      if (maxPerBusiness == 1 &&
          alreadyLoadedBusinessIds.contains(promo.businessId)) {
        continue;
      }

      diversified.add(promo);

      // Stop once we have enough promotions (10 for each page)
      if (diversified.length >= 10) break;
    }

    return diversified;
  }
}
