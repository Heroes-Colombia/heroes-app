import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/business_marker.dart';
import 'package:heroes_app/src/domain/models/business_location.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:location/location.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final locator = GetIt.instance;
  MapCubit() : super(const MapState());

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  Future<void> getMapInitialInformation(
    BuildContext context,
    LocationData? initialCameraPosition,
  ) async {
    try {
      emit(state.copyWith(isMapLoading: true));
      //First we get the business collection from Firestore
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //Then we get the user location
      final userCurrentLocation = await locator<AppMethods>().getUserLocation();
      final userGeoPoint = GeoPoint(
        userCurrentLocation!.latitude!,
        userCurrentLocation.longitude!,
      );

      //Then we emit the state with the user location
      emit(
        state.copyWith(
          userLocation: userCurrentLocation,
          status: BusinessViewCubitStatus.success,
          isMapLoading: true,
        ),
      );
      //Then we get the business info from the firestore collection

      final businessRawInfoStream = locator
          .get<FirestoreService>()
          .getDocumentsNearPosition(
            initialCameraPosition != null
                ? GeoPoint(
                  initialCameraPosition.latitude!,
                  initialCameraPosition.longitude!,
                )
                : userGeoPoint,
            1.2,
            businessCollection,
          );

      businessRawInfoStream.listen((event) async {
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
        final businessIds = businessesRawInfo.map((b) => b['id'] as String).toList();
        final locationsMap = await locator<FirestoreService>()
            .getMultipleBusinessLocations(businessIds);

        // Create markers for all locations (not just primary business location)
        final List<Marker> allMarkers = [];

        for (var business in businessMarkers) {
          final businessLocations = locationsMap[business.businessId];

          if (businessLocations != null && businessLocations.isNotEmpty) {
            // Create a marker for each physical location
            for (var locationData in businessLocations) {
              final location = BusinessLocation.fromJson(locationData, locationData['id']);

              // Only create markers for physical locations with coordinates
              if (location.isPhysical && location.location != null && location.isActive) {
                final markerId = MarkerId('${business.businessId}_${location.id}');
                final marker = Marker(
                  markerId: markerId,
                  position: LatLng(
                    location.location!.latitude,
                    location.location!.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: business.name,
                    snippet: location.isPrimary
                        ? '${location.displayAddress} (Principal)'
                        : location.displayAddress,
                  ),
                  icon: location.isPrimary
                      ? BitmapDescriptor.defaultMarkerWithHue(84.62) // Green for primary
                      : BitmapDescriptor.defaultMarkerWithHue(200), // Blue for secondary
                  onTap: () {
                    AutoRouter.of(context).push(
                      BusinessDetailsView(businessId: business.businessId),
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
                AutoRouter.of(context).push(
                  BusinessDetailsView(businessId: business.businessId),
                );
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
      //We serach the business by name and see if it matches the query
      //We get the collection name from the app constants and we capitalize the query
      var searchQuery = locator<AppMethods>().capitalize(query);
      final businessCollection = locator<AppConstants>().businessCollection;

      //We get the businesses from the firestore service
      var rawSearchResults = await locator
          .get<FirestoreService>()
          .readActiveDocumentsBySearchQuery(
            businessCollection,
            "name",
            searchQuery,
          );

      //We convert the raw businesses to a list of ListableBusiness
      final filteredBusinesses =
          rawSearchResults
              .map((business) => BusinessMarker.fromJson(business))
              .toList();

      //Then we create a list of markers from the business markers
      final markers =
          filteredBusinesses
              .map(
                (business) => Marker(
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
                    emit(
                      state.copyWith(filtredMarkers: [...state.filtredMarkers]),
                    );
                    AutoRouter.of(context).push(
                      BusinessDetailsView(businessId: business.businessId),
                    );
                  },
                ),
              )
              .toList();

      //Then we set the state with the new info
      emit(state.copyWith(searchedMarkers: markers));
    } catch (e) {
      log('Error: $e, Function: onSearchSubmitted, File: map_cubit.dart');
    }
  }

  Future<void> addBusinessesInCurrentPosition(
    GeoPoint currentScreenLocation,
    BuildContext context,
  ) async {
    try {
      //First we set the loading state
      emit(state.copyWith(isMapLoading: true));

      //We get the business collection from Firestore
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //Then we get the business info from the firestore collection
      final businessRawInfoStream = locator
          .get<FirestoreService>()
          .getDocumentsNearPosition(
            currentScreenLocation,
            1.2,
            businessCollection,
          );

      businessRawInfoStream.listen((event) async {
        log('Event: $event');
        List<Map<String, dynamic>> businessesRawInfo = [];

        for (var docs in event) {
          if (docs.exists) {
            var data = docs.data() as Map<String, dynamic>;
            data['id'] = docs.id;
            log('Data: $data');
            businessesRawInfo.add(data);
          }
        }

        //Then we create the business markers from the raw info
        final businessMarkers =
            businessesRawInfo
                .map((business) => BusinessMarker.fromJson(business))
                .toSet();

        //Then we verify if the state contains the new markers if not we add them
        var currentBusinessMarkers = state.allBusinessMarkers.toSet();
        currentBusinessMarkers.addAll(businessMarkers);

        // NEW: Fetch all locations for all businesses
        final businessIds = businessesRawInfo.map((b) => b['id'] as String).toList();
        final locationsMap = await locator<FirestoreService>()
            .getMultipleBusinessLocations(businessIds);

        // Create markers for all locations
        final Set<Marker> newMarkers = {};

        for (var business in currentBusinessMarkers) {
          final businessLocations = locationsMap[business.businessId];

          if (businessLocations != null && businessLocations.isNotEmpty) {
            // Create a marker for each physical location
            for (var locationData in businessLocations) {
              final location = BusinessLocation.fromJson(locationData, locationData['id']);

              // Only create markers for physical locations with coordinates
              if (location.isPhysical && location.location != null && location.isActive) {
                final markerId = MarkerId('${business.businessId}_${location.id}');
                final marker = Marker(
                  markerId: markerId,
                  position: LatLng(
                    location.location!.latitude,
                    location.location!.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: business.name,
                    snippet: location.isPrimary
                        ? '${location.displayAddress} (Principal)'
                        : location.displayAddress,
                  ),
                  icon: location.isPrimary
                      ? BitmapDescriptor.defaultMarkerWithHue(84.62) // Green for primary
                      : BitmapDescriptor.defaultMarkerWithHue(200), // Blue for secondary
                  onTap: () {
                    AutoRouter.of(context).push(
                      BusinessDetailsView(businessId: business.businessId),
                    );
                  },
                );
                newMarkers.add(marker);
              }
            }
          } else {
            // Fallback to primary business location
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
                AutoRouter.of(context).push(
                  BusinessDetailsView(businessId: business.businessId),
                );
              },
            );
            newMarkers.add(marker);
          }
        }

        //Then we set the state with the new info
        emit(
          state.copyWith(
            allMarkers: newMarkers.toList(),
            filtredMarkers: newMarkers.toList(),
            allBusinessMarkers: currentBusinessMarkers.toList(),
            isMapLoading: false,
          ),
        );
      });
    } catch (e) {
      log(
        'Error: $e, Function: addBusinessesInCurrentPosition, File: map_cubit.dart',
      );
    }
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
}
