part of 'map_cubit.dart';

final class MapState extends Equatable {
  final List<Marker> allMarkers;
  final bool isMapLoading;
  final BusinessViewCubitStatus status;
  final LocationData? userLocation;

  const MapState({
    this.allMarkers = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.isMapLoading = false,
    this.userLocation,
  });

  MapState copyWith({
    List<Marker>? allMarkers,
    bool? isMapLoading,
    BusinessViewCubitStatus? status,
    LocationData? userLocation,
  }) {
    return MapState(
      allMarkers: allMarkers ?? this.allMarkers,
      isMapLoading: isMapLoading ?? this.isMapLoading,
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  @override
  List<Object?> get props => [
        allMarkers,
        isMapLoading,
        status,
        userLocation,
      ];
}
