part of 'map_cubit.dart';

final class MapState extends Equatable {
  final List<Marker> allMarkers;
  final List<Marker> filtredMarkers;
  final List<Marker> searchedMarkers;
  final List<BusinessMarker> allBusinessMarkers;
  final bool isMapLoading;
  final BusinessViewCubitStatus status;
  final LocationData? userLocation;

  const MapState({
    this.allMarkers = const [],
    this.filtredMarkers = const [],
    this.searchedMarkers = const [],
    this.allBusinessMarkers = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.isMapLoading = false,
    this.userLocation,
  });

  MapState copyWith({
    List<Marker>? allMarkers,
    List<Marker>? filtredMarkers,
    List<Marker>? searchedMarkers,
    List<BusinessMarker>? allBusinessMarkers,
    bool? isMapLoading,
    BusinessViewCubitStatus? status,
    LocationData? userLocation,
  }) {
    return MapState(
      allMarkers: allMarkers ?? this.allMarkers,
      filtredMarkers: filtredMarkers ?? this.filtredMarkers,
      searchedMarkers: searchedMarkers ?? this.searchedMarkers,
      allBusinessMarkers: allBusinessMarkers ?? this.allBusinessMarkers,
      isMapLoading: isMapLoading ?? this.isMapLoading,
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [
        allMarkers,
        filtredMarkers,
        searchedMarkers,
        allBusinessMarkers,
        isMapLoading,
        status,
        userLocation,
      ];
}
