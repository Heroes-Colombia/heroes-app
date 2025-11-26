import 'dart:math';
import 'package:location/location.dart';

/// Service for managing user location with intelligent caching
///
/// This service reduces GPS calls by caching location for 30 minutes
/// and provides movement detection to update when user moves significantly.
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LocationData? _cachedLocation;
  DateTime? _lastFetchTime;

  // Cache validity: 30 minutes
  static const _cacheValidityMinutes = 30;

  // Distance threshold to consider location "changed" (in meters)
  static const _significantMovementMeters = 500; // 500m = 0.5km

  /// Get user location with smart caching
  ///
  /// [forceRefresh] - Bypass cache and fetch fresh location (e.g., pull to refresh)
  /// [checkMovement] - Check if user moved significantly before using cache (e.g., for maps)
  ///
  /// Returns cached location if:
  /// - Cache is valid (< 30 minutes old)
  /// - forceRefresh is false
  /// - User hasn't moved significantly (if checkMovement is true)
  Future<LocationData?> getUserLocation({
    bool forceRefresh = false,
    bool checkMovement = false,
  }) async {
    // SCENARIO 1: Force refresh (e.g., user manually refreshes)
    if (forceRefresh) {
      return await _fetchFreshLocation();
    }

    // SCENARIO 2: No cache exists (first app launch or after cache clear)
    if (_cachedLocation == null || _lastFetchTime == null) {
      return await _fetchFreshLocation();
    }

    // SCENARIO 3: Cache expired (30 minutes passed)
    final age = DateTime.now().difference(_lastFetchTime!);
    if (age.inMinutes >= _cacheValidityMinutes) {
      return await _fetchFreshLocation();
    }

    // SCENARIO 4: Check if user moved significantly
    if (checkMovement) {
      final currentLocation = await _fetchFreshLocation(updateCache: false);
      if (currentLocation != null && _hasMovedSignificantly(currentLocation)) {
        // User moved, update cache and return new location
        _cachedLocation = currentLocation;
        _lastFetchTime = DateTime.now();
        return currentLocation;
      }
    }

    // SCENARIO 5: Cache is valid and user hasn't moved much - return cached
    return _cachedLocation;
  }

  /// Fetch fresh location from GPS
  ///
  /// [updateCache] - Whether to update the cached location (default: true)
  Future<LocationData?> _fetchFreshLocation({bool updateCache = true}) async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return null;
    }

    final freshLocation = await location.getLocation();

    if (updateCache) {
      _cachedLocation = freshLocation;
      _lastFetchTime = DateTime.now();
    }

    return freshLocation;
  }

  /// Check if user moved significantly from cached location
  ///
  /// Returns true if distance > 500 meters
  bool _hasMovedSignificantly(LocationData newLocation) {
    if (_cachedLocation == null) return true;

    final distance = _calculateDistance(
      _cachedLocation!.latitude!,
      _cachedLocation!.longitude!,
      newLocation.latitude!,
      newLocation.longitude!,
    );

    return distance >= _significantMovementMeters;
  }

  /// Calculate distance between two coordinates in meters using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  /// Clear cached location (useful for testing or logout)
  void invalidateCache() {
    _cachedLocation = null;
    _lastFetchTime = null;
  }

  /// Get cached location without fetching (for quick access)
  ///
  /// Returns null if no cache exists
  LocationData? getCachedLocation() => _cachedLocation;

  /// Check if cache is still valid
  ///
  /// Returns true if cache exists and is less than 30 minutes old
  bool isCacheValid() {
    if (_cachedLocation == null || _lastFetchTime == null) return false;
    final age = DateTime.now().difference(_lastFetchTime!);
    return age.inMinutes < _cacheValidityMinutes;
  }

  /// Get cache age in minutes
  ///
  /// Returns null if no cache exists
  int? getCacheAgeMinutes() {
    if (_lastFetchTime == null) return null;
    return DateTime.now().difference(_lastFetchTime!).inMinutes;
  }
}
