import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/business_marker.dart';
import 'package:heroes_app/src/domain/models/business_location.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/services/cache_service.dart';
import 'package:location/location.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final locator = GetIt.instance;
  StreamSubscription? _businessStreamSubscription;

  MapCubit() : super(const MapState());

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  /// Cancel all active stream subscriptions
  void cancelSubscriptions() {
    _businessStreamSubscription?.cancel();
    _businessStreamSubscription = null;
  }

  @override
  Future<void> close() {
    cancelSubscriptions();
    return super.close();
  }

  Future<void> getMapInitialInformation(
    BuildContext context,
    LocationData? initialCameraPosition,
  ) async {
    try {
      emit(state.copyWith(isMapLoading: true));
      //First we get the business collection from Firestore
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //Then we get the user location (for displaying user's blue dot on map)
      final userCurrentLocation = await locator<AppMethods>().getUserLocation();

      // Colombia center (Bogotá) - default location for business discovery
      final colombiaCenter = GeoPoint(4.658056, -74.093889);
      const colombiaCenterLatLng = LatLng(4.658056, -74.093889);

      // Determine search center with smart logic
      GeoPoint searchCenter;

      // Determine the position to check (either provided camera position or user location)
      LatLng positionToCheck;
      if (initialCameraPosition != null) {
        positionToCheck = LatLng(
          initialCameraPosition.latitude!,
          initialCameraPosition.longitude!,
        );
      } else {
        positionToCheck = LatLng(
          userCurrentLocation!.latitude!,
          userCurrentLocation.longitude!,
        );
      }

      // Calculate distance from the position to Colombia center
      final distanceToColombiaKm = await getDistanceBetweenPointsInKm(
        positionToCheck,
        colombiaCenterLatLng,
      );

      // If user is far from Colombia (>2000km), default to Colombia center
      // Otherwise use the position we determined above
      if (distanceToColombiaKm > 2000) {
        searchCenter = colombiaCenter;
      } else {
        searchCenter = GeoPoint(
          positionToCheck.latitude,
          positionToCheck.longitude,
        );
      }

      //Then we emit the state with the user location (for UI blue dot)
      emit(
        state.copyWith(
          userLocation: userCurrentLocation,
          status: BusinessViewCubitStatus.success,
          isMapLoading: true,
          initialMapCenter: LatLng(
            searchCenter.latitude,
            searchCenter.longitude,
          ),
        ),
      );

      // Load ALL businesses across Colombia (no distance restriction)
      // This ensures the map is not empty even with few businesses
      final businessRawInfoStream = locator
          .get<FirestoreService>()
          .getAllActivePhysicalBusinesses(businessCollection);

      // Cancel any existing subscription before creating a new one
      _businessStreamSubscription?.cancel();
      _businessStreamSubscription = businessRawInfoStream.listen((event) async {
        List<Map<String, dynamic>> businessesRawInfo = [];

        for (var docs in event) {
          if (docs.exists) {
            var data = docs.data() as Map<String, dynamic>;
            data['id'] = docs.id;
            businessesRawInfo.add(data);
          }
        }

        //Then we create the business markers from the raw info
        final businessMarkers =
            businessesRawInfo
                .map((business) => BusinessMarker.fromJson(business))
                .toList();

        // NEW: Fetch all locations for all businesses
        final businessIds =
            businessesRawInfo.map((b) => b['id'] as String).toList();
        final locationsMap = await locator<FirestoreService>()
            .getMultipleBusinessLocations(businessIds);

        // Create markers for all locations (not just primary business location)
        final List<Marker> allMarkers = [];

        for (var business in businessMarkers) {
          final businessLocations = locationsMap[business.businessId];

          if (businessLocations != null && businessLocations.isNotEmpty) {
            // Create a marker for each physical location
            for (var locationData in businessLocations) {
              final location = BusinessLocation.fromJson(
                locationData,
                locationData['id'],
              );

              // Only create markers for physical locations
              // If location.location is null, we'll fallback to business.location
              if (location.isPhysical && location.isActive) {
                final markerId = MarkerId(
                  '${business.businessId}_${location.id}',
                );

                // Use location coordinates if available, otherwise fallback to business primary location
                final double latitude =
                    location.location?.latitude ?? business.location.latitude;
                final double longitude =
                    location.location?.longitude ?? business.location.longitude;

                final marker = Marker(
                  markerId: markerId,
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: business.name,
                    snippet:
                        location.isPrimary
                            ? '${location.displayAddress} (Principal)'
                            : location.displayAddress,
                  ),
                  icon:
                      location.isPrimary
                          ? BitmapDescriptor.defaultMarkerWithHue(
                            84.62,
                          ) // Green for primary
                          : BitmapDescriptor.defaultMarkerWithHue(
                            200,
                          ), // Blue for secondary
                  onTap: () {
                    selectBusinessForPreview(
                      business.businessId,
                      locationId: location.id,
                    );
                  },
                );
                allMarkers.add(marker);
              }
            }
          } else {
            // Fallback to primary business location if no locations subcollection exists
            final marker = Marker(
              markerId: MarkerId(business.businessId),
              position: LatLng(
                business.location.latitude,
                business.location.longitude,
              ),
              infoWindow: InfoWindow(
                title: business.name,
                snippet: business.address,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(84.62),
              onTap: () {
                selectBusinessForPreview(business.businessId);
              },
            );
            allMarkers.add(marker);
          }
        }

        //Then we set the state with the new info
        emit(
          state.copyWith(
            allMarkers: allMarkers,
            userLocation: userCurrentLocation,
            allBusinessMarkers: businessMarkers,
            filtredMarkers: allMarkers,
            isMapLoading: false,
          ),
        );
      });
    } catch (e) {
      log(
        'Error: $e, Function: getMapInitialInformation, File: map_cubit.dart',
      );
    }
  }

  void searchBusiness(String query) {
    try {
      //We serach the business by name and see if it matches the query
      final searchedBusiness =
          state.allMarkers
              .where((element) => element.infoWindow.title!.contains(query))
              .toList();

      //Then we set the state with the new info
      emit(state.copyWith(filtredMarkers: searchedBusiness));
    } catch (e) {
      log('Error: $e, Function: searchBusiness, File: map_cubit.dart');
    }
  }

  void onSearchSubmitted(String query, BuildContext context) async {
    try {
      // Normalize search query (lowercase for case-insensitive search)
      final searchQuery = query.toLowerCase().trim();
      if (searchQuery.isEmpty) {
        emit(state.copyWith(searchedMarkers: []));
        return;
      }

      final businessCollection = locator<AppConstants>().businessCollection;

      // Use cached data if available, otherwise fetch and cache it
      List<Map<String, dynamic>> allBusinessLocations;

      if (state.cachedAllBusinessLocations != null) {
        // Reuse cached data (no network call!)
        allBusinessLocations = state.cachedAllBusinessLocations!;
      } else {
        // First search: fetch and cache the data
        allBusinessLocations = await locator
            .get<FirestoreService>()
            .getAllBusinessesWithPhysicalLocations(businessCollection);

        // Cache the data for future searches
        emit(state.copyWith(cachedAllBusinessLocations: allBusinessLocations));
      }

      // Client-side filtering: search by business name OR category name
      final filteredResults =
          allBusinessLocations.where((result) {
            final businessName =
                (result['businessName'] as String).toLowerCase();
            final categories = result['businessCategories'] as List;

            // Check if business name contains the search query (partial match)
            if (businessName.contains(searchQuery)) {
              return true;
            }

            // Check if any category name contains the search query
            if (categories.isNotEmpty && state.businessCategories.isNotEmpty) {
              for (final categoryId in categories) {
                final category = state.businessCategories.firstWhere(
                  (c) => c.id == categoryId,
                  orElse:
                      () => BusinessCategory(id: '', name: '', imageUrl: ''),
                );
                if (category.name.toLowerCase().contains(searchQuery)) {
                  return true;
                }
              }
            }

            return false;
          }).toList();

      // Create markers and business data from filtered results
      final List<BusinessMarker> newBusinessMarkers = [];
      final markers =
          filteredResults.map((result) {
            final locationData = result['locationData'] as Map<String, dynamic>;
            final location = BusinessLocation.fromJson(
              locationData,
              result['locationId'] as String,
            );

            final businessId = result['businessId'] as String;

            // Create a BusinessMarker for this business if we haven't already
            if (!state.allBusinessMarkers.any(
              (b) => b.businessId == businessId,
            )) {
              final businessMarker = BusinessMarker(
                businessId: businessId,
                name: result['businessName'] as String,
                address: result['businessAddress'] as String,
                location: result['businessLocation'] as GeoPoint,
                phoneNumber: result['businessPhoneNumber'] as String?,
                categories: List<String>.from(
                  result['businessCategories'] as List,
                ),
              );
              newBusinessMarkers.add(businessMarker);
            }

            // Use location coordinates if available, fallback to business location
            final double latitude =
                location.location?.latitude ??
                (result['businessLocation'] as GeoPoint).latitude;
            final double longitude =
                location.location?.longitude ??
                (result['businessLocation'] as GeoPoint).longitude;

            final markerId = MarkerId(
              '${result['businessId']}_${result['locationId']}',
            );

            return Marker(
              markerId: markerId,
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: result['businessName'] as String,
                snippet:
                    location.isPrimary
                        ? '${location.displayAddress} (Principal)'
                        : location.displayAddress,
              ),
              icon:
                  location.isPrimary
                      ? BitmapDescriptor.defaultMarkerWithHue(84.62) // Green
                      : BitmapDescriptor.defaultMarkerWithHue(200), // Blue
              onTap: () {
                selectBusinessForPreview(
                  result['businessId'] as String,
                  locationId: result['locationId'] as String,
                );
              },
            );
          }).toList();

      // Add new business markers to the state
      final updatedBusinessMarkers = [
        ...state.allBusinessMarkers,
        ...newBusinessMarkers,
      ];

      // Set the state with filtered search results
      emit(
        state.copyWith(
          searchedMarkers: markers,
          allBusinessMarkers: updatedBusinessMarkers,
        ),
      );
    } catch (e) {
      log('Error: $e, Function: onSearchSubmitted, File: map_cubit.dart');
    }
  }

  Future<void> addBusinessesInCurrentPosition(
    GeoPoint currentScreenLocation,
    BuildContext context,
  ) async {
    // Since all businesses are already loaded at initialization,
    // we don't need to load more businesses when the camera moves.
    // Just turn off the loading indicator.
    emit(state.copyWith(isMapLoading: false));
  }

  Future<double> getDistanceBetweenPointsInKm(
    LatLng firstPoint,
    LatLng secondPoint,
  ) async {
    final distance = Geolocator.distanceBetween(
      firstPoint.latitude,
      firstPoint.longitude,
      secondPoint.latitude,
      secondPoint.longitude,
    );

    return distance / 1000;
  }

  /// Load business categories from Firestore (with caching)
  /// Reuses the same caching mechanism as business_home_view
  Future<void> loadCategories() async {
    try {
      final cacheService = locator.get<CacheService>();
      List<BusinessCategory> categories;

      // Check cache first (5 min TTL)
      final cached = cacheService.get<List<BusinessCategory>>(
        CacheKeys.businessCategories,
      );

      if (cached != null) {
        categories = cached;
      } else {
        // Fetch from Firestore if not cached
        final businessCategoryCollection =
            locator.get<AppConstants>().businessCategoryCollection;

        final rawCategories = await locator
            .get<FirestoreService>()
            .readAllActiveDocuments(businessCategoryCollection);

        categories =
            rawCategories.map((e) => BusinessCategory.fromJson(e)).toList();

        // Cache for future use
        cacheService.set(CacheKeys.businessCategories, categories);
      }

      emit(state.copyWith(businessCategories: categories));
    } catch (e) {
      log(
        'Error loading categories: $e, Function: loadCategories, File: map_cubit.dart',
      );
    }
  }

  /// Filter markers by selected category
  /// If categoryId is null, show all markers
  void filterByCategory(String? categoryId) {
    try {
      if (categoryId == null) {
        // Show all markers (reset filter)
        emit(
          state.clearSelectedCategory().copyWith(
            filtredMarkers: state.allMarkers,
          ),
        );
        return;
      }

      // Filter markers by category
      // Get all business IDs that belong to this category
      final businessIdsInCategory =
          state.allBusinessMarkers
              .where((business) => business.categories.contains(categoryId))
              .map((business) => business.businessId)
              .toSet();

      // Filter markers: keep markers whose businessId is in the category
      final filteredMarkers =
          state.allMarkers.where((marker) {
            // Extract businessId from markerId (format: "businessId_locationId" or "businessId")
            final businessId = marker.markerId.value.split('_')[0];
            return businessIdsInCategory.contains(businessId);
          }).toList();

      emit(
        state.copyWith(
          selectedCategoryId: categoryId,
          filtredMarkers: filteredMarkers,
        ),
      );
    } catch (e) {
      log(
        'Error filtering by category: $e, Function: filterByCategory, File: map_cubit.dart',
      );
    }
  }

  /// Select a business to show in the preview bottom sheet
  /// Pass both businessId and optional locationId for location-specific data
  void selectBusinessForPreview(String businessId, {String? locationId}) {
    emit(
      state.copyWith(
        selectedBusinessIdForPreview: businessId,
        selectedLocationIdForPreview: locationId,
      ),
    );
  }

  /// Clear the selected business (close preview)
  void clearSelectedBusiness() {
    emit(state.clearSelectedBusiness());
  }
}
