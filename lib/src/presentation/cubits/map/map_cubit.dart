import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/models/business_marker.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:location/location.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final locator = GetIt.instance;
  MapCubit() : super(const MapState());

  void getInitial() {
    emit(state.copyWith(status: BusinessViewCubitStatus.loading));
  }

  Future<void> getMapInitialInformation() async {
    try {
      //First we get the business collection from Firestore
      final businessCollection = locator.get<AppConstants>().businessCollection;
      //Then we get the business info from the firestore collection
      final businessRawInfo = await locator
          .get<FirestoreService>()
          .readAllActiveDocuments(businessCollection);

      //Then we create the business markers from the raw info
      final businessMarkers = businessRawInfo
          .map((business) => BusinessMarker.fromJson(business))
          .toList();

      //Then we create a list of markers from the business markers
      final markers = businessMarkers
          .map((business) => Marker(
                markerId: MarkerId(business.businessId),
                position: LatLng(
                    business.location.latitude, business.location.longitude),
                infoWindow: InfoWindow(
                  title: business.name,
                  snippet: business.address,
                ),
                onTap: () {
                  //TODO: Add onTap functionality
                },
              ))
          .toList();

      //Then we get the user location
      final userCurrentLocation = await locator<AppMethods>().getUserLocation();

      //Then we set the state with the new info
      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        allMarkers: markers,
        userLocation: userCurrentLocation,
      ));
    } catch (e) {
      log('Error: $e, Function: getMapInitialInformation, File: map_cubit.dart');
    }
  }
}
