import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/business_location.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

part 'business_details_state.dart';

class BusinessDetailsCubit extends Cubit<BusinessDetailsState> {
  final locator = GetIt.instance;
  BusinessDetailsCubit() : super(const BusinessDetailsState());

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  //This method is used to get the business details by ID and the promotions
  //OPTIMIZED: All queries run in parallel for 4x faster loading
  Future<void> getBusinessDetails(String businessId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //OPTIMIZATION: Execute all queries in parallel using Future.wait
      final results = await Future.wait([
        firestoreService.readDocumentByDocId(businessCollection, businessId),
        getBusinessPromotions(businessId),
        getBusinessReviews(businessId),
        getBusinessLocations(businessId),
      ]);

      // Extract results
      final rawBusiness = results[0] as Map<String, dynamic>?;
      final promotions = results[1] as List<Promotion>;
      final reviews = results[2] as List<UserReview>;
      final locations = results[3] as List<BusinessLocation>;

      final business = Business.fromJson(rawBusiness!);

      //We update the state with the new business details
      emit(
        state.copyWith(
          businessId: businessId,
          business: business,
          promotions: promotions,
          locations: locations,
          status: BusinessViewCubitStatus.success,
          isFavourite: state.isFavourite,
          favouriteIsLoading: state.favouriteIsLoading,
          reviews: reviews,
        ),
      );
    } catch (e, stackTrace) {
      log(
        'Error: $e, Function: getBusinessDetails, File: business_details_cubit.dart',
        stackTrace: StackTrace.current,
      );
      print('❌ DASHBOARD ERROR: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
    }
  }

  //This method is used to get all locations for a business
  Future<List<BusinessLocation>> getBusinessLocations(String businessId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();

      //Fetch locations from subcollection
      final rawLocations = await firestoreService.getBusinessLocations(
        businessId,
      );

      final locations =
          rawLocations
              .map((e) => BusinessLocation.fromJson(e, e['id']))
              .toList();

      // Get user location for distance calculation
      // OPTIMIZED: Use LocationService with caching instead of fetching every time
      try {
        final userLocation = await LocationService().getUserLocation();
        if (userLocation != null &&
            userLocation.latitude != null &&
            userLocation.longitude != null) {
          final userLat = userLocation.latitude!;
          final userLng = userLocation.longitude!;

          // Calculate distances for physical locations
          for (var location in locations) {
            if (location.isPhysical && location.location != null) {
              location.calculateDistance(userLat, userLng);
            }
          }
        }
      } catch (e) {
        log('Could not get user location for distance calculation: $e');
        // Continue without distances if location fails
      }

      // Sort locations: primary first, then by distance (nearest first), then by status
      locations.sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;

        // Both physical - sort by distance
        if (a.isPhysical && b.isPhysical) {
          if (a.distanceKm == null) return 1;
          if (b.distanceKm == null) return -1;
          return a.distanceKm!.compareTo(b.distanceKm!);
        }

        // Physical before online
        if (a.isPhysical && !b.isPhysical) return -1;
        if (!a.isPhysical && b.isPhysical) return 1;

        // Status: active before inactive
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;

        return 0;
      });

      return locations;
    } catch (e) {
      log(
        'Error: $e, Function: getBusinessLocations, File: business_details_cubit.dart',
      );
      return [];
    }
  }

  //this method is used to get the promotions of a business
  Future<List<Promotion>> getBusinessPromotions(String businessId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final promotionsCollection =
          locator.get<AppConstants>().advertisementCollection;

      //We fetch the promotions from the database
      final rawPromotions = await firestoreService
          .readActiveDocumentsByCondition(
            promotionsCollection,
            'business_id',
            businessId,
            999,
          );

      final promotions =
          rawPromotions.map((e) => Promotion.fromJson(e)).toList();

      //Then return the promotions
      return promotions;
    } catch (e) {
      log(
        'Error: $e, Function: getBusinessPromotions, File: business_details_cubit.dart',
      );
      return [];
    }
  }

  //This method is used to verify if the business is favourite
  void businessIsMarkedAsFavorite(String businessId) async {
    //We get the user favourite businesses list
    final user = await locator.get<AuthService>().getUser();
    final userFavouriteBusinesses = user!.favouriteBusinesses;

    if (userFavouriteBusinesses.contains(businessId)) {
      emit(state.copyWith(isFavourite: true, favouriteIsLoading: false));
    } else {
      emit(state.copyWith(isFavourite: false, favouriteIsLoading: false));
    }
  }

  //This method is used to get business reviews
  Future<List<UserReview>> getBusinessReviews(String businessId) async {
    try {
      final firestoreService = locator.get<FirestoreService>();
      final reviewsCollection = locator.get<AppConstants>().reviewsCollection;

      //We fetch the reviews from the database
      final rawReviews = await firestoreService.readActiveDocumentsByCondition(
        reviewsCollection,
        'business_id',
        businessId,
        999,
      );

      final reviews = rawReviews.map((e) => UserReview.fromJson(e)).toList();

      //Then return the reviews
      return reviews;
    } catch (e) {
      log(
        'Error: $e, Function: getBusinessReviews, File: business_details_cubit.dart',
      );
      return [];
    }
  }

  //This method is used to get all business reviews
  Future<void> getAllBusinessReviews(String businessId) async {
    emit(state.copyWith(allUserReviews: []));
    try {
      final firestoreService = locator.get<FirestoreService>();
      final reviewsCollection = locator.get<AppConstants>().reviewsCollection;

      //We fetch the reviews from the database
      final rawReviews = await firestoreService.readActiveDocumentsByCondition(
        reviewsCollection,
        'business_id',
        businessId,
        999,
      );

      final reviews = rawReviews.map((e) => UserReview.fromJson(e)).toList();

      //Then return the reviews
      emit(state.copyWith(allUserReviews: reviews));
    } catch (e) {
      log(
        'Error: $e, Function: getAllBusinessReviews, File: business_details_cubit.dart',
      );
    }
  }

  //This method is used to set a review to a business
  Future<void> setReviewToBusiness(UserReview review) async {
    //We update the state
    emit(state.copyWith(isReviewLoading: true));

    try {
      final firestoreService = locator.get<FirestoreService>();
      final reviewsCollection = locator.get<AppConstants>().reviewsCollection;

      //We add the review to the database
      await firestoreService.createDocument(reviewsCollection, review.toJson());

      //We update the state
      emit(
        state.copyWith(
          reviews: [review, ...state.reviews],
          allUserReviews:
              state.allUserReviews.isNotEmpty
                  ? [review, ...state.allUserReviews]
                  : state.allUserReviews,
        ),
      );
    } catch (e) {
      log(
        'Error: $e, Function: setReviewToBusiness, File: business_details_cubit.dart',
      );
    }
  }

  //This method is used to set the business as favourite
  void setBusinessAsFavourite(String businessId) async {
    //We update the state
    emit(
      state.copyWith(favouriteIsLoading: true, isFavourite: !state.isFavourite),
    );

    try {
      //We get the user id and the user favourite businesses list
      final user = await locator.get<AuthService>().getUser();
      final userId = user!.uid;
      final userFavouriteBusinesses = user.favouriteBusinesses;

      //We create a copy of the user favourite businesses list
      final copyOfUserFavouriteBusinesses = [...userFavouriteBusinesses];

      final firestoreService = locator.get<FirestoreService>();
      final userCollection = locator.get<AppConstants>().usersCollection;

      //We check if the business is already marked as favourite
      if (copyOfUserFavouriteBusinesses.contains(businessId)) {
        //If it is, we remove it from the list
        copyOfUserFavouriteBusinesses.remove(businessId);
      } else {
        //If it is not, we add it to the list
        copyOfUserFavouriteBusinesses.add(businessId);
      }

      //We update the user favourite businesses list
      await firestoreService.editDocumentById(userCollection, userId, 'uid', {
        'favourite_businesses': copyOfUserFavouriteBusinesses,
      });

      //We update the state with favouriteIsLoading set to false
      emit(state.copyWith(isFavourite: state.isFavourite, favouriteIsLoading: false));
    } catch (e) {
      //If the update fails, we revert the state
      emit(state.copyWith(isFavourite: !state.isFavourite, favouriteIsLoading: false));
      log(
        'Error: $e, Function: setBusinessAsFavourite, File: business_details_cubit.dart',
      );
    }
  }

  //This method is used to reset the favourite state to false
  void resetReviewState() {
    emit(state.copyWith(isReviewLoading: false));
  }

  //This method is used to navigate to the business in any map application compatible with the geo intent
  void openUrl(BuildContext context, texts) async {
    // Use shared navigation utility from AppMethods
    await locator.get<AppMethods>().navigateToLocation(
      context: context,
      latitude: state.business!.location.latitude,
      longitude: state.business!.location.longitude,
      address: state.business!.address,
      texts: texts,
    );
  }

  //This method is used to open the business website
  void openWebsite(String website) async {
    // Ensure the URL has a proper scheme (http:// or https://)
    String url = website.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  //This method is used to call the business
  void callBusiness(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  //This method is used to open WhatsApp with the business phone number
  void openWhatsApp(String phoneNumber) async {
    // Remove any spaces, dashes, or special characters from phone number
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if phone number starts with a country code (starts with + or has more than 10 digits)
    // If not, add Colombia country code (+57) by default
    if (!cleanPhone.startsWith('+') && cleanPhone.length <= 10) {
      cleanPhone = '57$cleanPhone';
    } else if (cleanPhone.startsWith('+')) {
      // Remove the + for wa.me URL
      cleanPhone = cleanPhone.substring(1);
    }

    // Try WhatsApp URL first (works on both platforms)
    final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }
}
