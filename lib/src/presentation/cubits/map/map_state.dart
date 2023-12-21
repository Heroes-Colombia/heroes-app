part of 'map_cubit.dart';

final class MapState extends Equatable {
  final List<Marker> allMarkers;
  final List<Marker> filtredMarkers;
  final bool isMapLoading;
  final BusinessViewCubitStatus status;
  final LocationData? userLocation;

  const MapState({
    this.allMarkers = const [],
    this.filtredMarkers = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.isMapLoading = false,
    this.userLocation,
  });

  MapState copyWith({
    List<Marker>? allMarkers,
    List<Marker>? filtredMarkers,
    bool? isMapLoading,
    BusinessViewCubitStatus? status,
    LocationData? userLocation,
  }) {
    return MapState(
      allMarkers: allMarkers ?? this.allMarkers,
      filtredMarkers: filtredMarkers ?? this.filtredMarkers,
      isMapLoading: isMapLoading ?? this.isMapLoading,
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [
        allMarkers,
        filtredMarkers,
        isMapLoading,
        status,
        userLocation,
      ];
}
