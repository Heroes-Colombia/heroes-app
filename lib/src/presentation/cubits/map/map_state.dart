part of 'map_cubit.dart';

final class MapState extends Equatable {
  final List<Marker> allMarkers;
  final List<Marker> filtredMarkers;
  final List<Marker> searchedMarkers;
  final List<BusinessMarker> allBusinessMarkers;
  final List<BusinessCategory> businessCategories;
  final String? selectedCategoryId;
  final String? selectedBusinessIdForPreview;
  final String? selectedLocationIdForPreview;
  final bool isMapLoading;
  final BusinessViewCubitStatus status;
  final LocationData? userLocation;
  final LatLng? initialMapCenter;

  // Cached data for search (loaded once, reused for all searches)
  final List<Map<String, dynamic>>? cachedAllBusinessLocations;

  const MapState({
    this.allMarkers = const [],
    this.filtredMarkers = const [],
    this.searchedMarkers = const [],
    this.allBusinessMarkers = const [],
    this.businessCategories = const [],
    this.selectedCategoryId,
    this.selectedBusinessIdForPreview,
    this.selectedLocationIdForPreview,
    this.status = BusinessViewCubitStatus.initial,
    this.isMapLoading = false,
    this.userLocation,
    this.initialMapCenter,
    this.cachedAllBusinessLocations,
  });

  /// Creates a copy of this state with the given fields replaced with new values.
  ///
  /// To explicitly set a nullable field to null, use the corresponding helper method:
  /// - [clearSelectedCategory] to set selectedCategoryId to null
  /// - [clearSelectedBusiness] to set selectedBusinessIdForPreview to null
  MapState copyWith({
    List<Marker>? allMarkers,
    List<Marker>? filtredMarkers,
    List<Marker>? searchedMarkers,
    List<BusinessMarker>? allBusinessMarkers,
    List<BusinessCategory>? businessCategories,
    String? selectedCategoryId,
    String? selectedBusinessIdForPreview,
    String? selectedLocationIdForPreview,
    bool? isMapLoading,
    BusinessViewCubitStatus? status,
    LocationData? userLocation,
    LatLng? initialMapCenter,
    List<Map<String, dynamic>>? cachedAllBusinessLocations,
  }) {
    return MapState(
      allMarkers: allMarkers ?? this.allMarkers,
      filtredMarkers: filtredMarkers ?? this.filtredMarkers,
      searchedMarkers: searchedMarkers ?? this.searchedMarkers,
      allBusinessMarkers: allBusinessMarkers ?? this.allBusinessMarkers,
      businessCategories: businessCategories ?? this.businessCategories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedBusinessIdForPreview:
          selectedBusinessIdForPreview ?? this.selectedBusinessIdForPreview,
      selectedLocationIdForPreview:
          selectedLocationIdForPreview ?? this.selectedLocationIdForPreview,
      isMapLoading: isMapLoading ?? this.isMapLoading,
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
      initialMapCenter: initialMapCenter ?? this.initialMapCenter,
      cachedAllBusinessLocations:
          cachedAllBusinessLocations ?? this.cachedAllBusinessLocations,
    );
  }

  /// Returns a copy with selectedCategoryId set to null
  MapState clearSelectedCategory() {
    return MapState(
      allMarkers: allMarkers,
      filtredMarkers: filtredMarkers,
      searchedMarkers: searchedMarkers,
      allBusinessMarkers: allBusinessMarkers,
      businessCategories: businessCategories,
      selectedCategoryId: null,
      selectedBusinessIdForPreview: selectedBusinessIdForPreview,
      selectedLocationIdForPreview: selectedLocationIdForPreview,
      isMapLoading: isMapLoading,
      status: status,
      userLocation: userLocation,
      initialMapCenter: initialMapCenter,
      cachedAllBusinessLocations: cachedAllBusinessLocations,
    );
  }

  /// Returns a copy with selectedBusinessIdForPreview and selectedLocationIdForPreview set to null
  MapState clearSelectedBusiness() {
    return MapState(
      allMarkers: allMarkers,
      filtredMarkers: filtredMarkers,
      searchedMarkers: searchedMarkers,
      allBusinessMarkers: allBusinessMarkers,
      businessCategories: businessCategories,
      selectedCategoryId: selectedCategoryId,
      selectedBusinessIdForPreview: null,
      selectedLocationIdForPreview: null,
      isMapLoading: isMapLoading,
      status: status,
      userLocation: userLocation,
      initialMapCenter: initialMapCenter,
      cachedAllBusinessLocations: cachedAllBusinessLocations,
    );
  }

  @override
  List<Object?> get props => [
    allMarkers,
    filtredMarkers,
    searchedMarkers,
    allBusinessMarkers,
    businessCategories,
    selectedCategoryId,
    selectedBusinessIdForPreview,
    selectedLocationIdForPreview,
    isMapLoading,
    status,
    userLocation,
    initialMapCenter,
    cachedAllBusinessLocations,
  ];
}
