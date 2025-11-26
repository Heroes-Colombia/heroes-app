import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';

// ignore: must_be_immutable
class ListableBusiness extends Equatable {
  final String name;
  final String id;
  final String featuredImage;
  final List<String> categoryIds;
  final String type; // "physical" | "online" | "hybrid"
  final bool featured; // Enterprise plan feature - priority placement in feeds
  final GeoPoint? location; // Business location for distance calculation
  final int? physicalLocationsCount; // Count of active physical locations (from backend)
  final int? totalLocationsCount; // Count of all active locations (from backend)
  BusinessCategory? category;
  double? distanceKm; // Calculated distance from user (mutable for performance)

  ListableBusiness({
    required this.name,
    required this.id,
    required this.featuredImage,
    required this.categoryIds,
    this.type = 'physical', // Default to physical for backward compatibility
    this.featured = false, // Default to false for backward compatibility
    this.location,
    this.physicalLocationsCount,
    this.totalLocationsCount,
    this.category,
    this.distanceKm,
  });

  factory ListableBusiness.fromJson(Map<String, dynamic> json) {
    // Parse location from geo_hash.geopoint or direct location field
    GeoPoint? location;

    try {
      if (json['geo_hash'] != null && json['geo_hash']['geopoint'] != null) {
        final geopoint = json['geo_hash']['geopoint'];
        // Handle both GeoPoint object and Map representation
        if (geopoint is GeoPoint) {
          location = geopoint;
        } else if (geopoint is Map) {
          location = GeoPoint(
            (geopoint['latitude'] ?? geopoint['_latitude']) as double,
            (geopoint['longitude'] ?? geopoint['_longitude']) as double,
          );
        }
      } else if (json['location'] != null) {
        final loc = json['location'];
        if (loc is GeoPoint) {
          location = loc;
        } else if (loc is Map) {
          location = GeoPoint(
            (loc['latitude'] ?? loc['_latitude']) as double,
            (loc['longitude'] ?? loc['_longitude']) as double,
          );
        }
      }
    } catch (e) {
      // If location parsing fails, just set to null
      location = null;
    }

    return ListableBusiness(
      name: json['name'] as String,
      id: json['id'] as String,
      featuredImage:
          json["featured_image"] != null
              ? json['featured_image'] as String
              : "",
      categoryIds:
          json['categories'] != null
              ? List<String>.from(json['categories'])
              : [],
      type: json['type'] as String? ?? 'physical',
      featured: json['featured'] as bool? ?? false,
      location: location,
      physicalLocationsCount: json['physical_locations_count'] as int?,
      totalLocationsCount: json['total_locations_count'] as int?,
      category: null,
    );
  }

  /// Calculate distance from user's location using Haversine formula
  void calculateDistance(double userLat, double userLng) {
    if (location == null) {
      distanceKm = null;
      return;
    }

    const double earthRadius = 6371; // km
    final double dLat = _toRadians(location!.latitude - userLat);
    final double dLng = _toRadians(location!.longitude - userLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) *
            cos(_toRadians(location!.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    distanceKm = earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  /// Get formatted distance string (e.g., "1.2 km" or "500 m")
  String? get formattedDistance {
    if (distanceKm == null) return null;
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  /// Check if this is a physical business
  bool get isPhysical => type == 'physical' || type == 'hybrid';

  /// Check if this is an online business
  bool get isOnline => type == 'online' || type == 'hybrid';

  /// Check if this is a hybrid business (both physical and online)
  bool get isHybrid => type == 'hybrid';

  /// Check if this business has multiple physical locations
  bool get hasMultiplePhysicalLocations => (physicalLocationsCount ?? 0) > 1;

  @override
  List<Object?> get props => [name, id, featuredImage, categoryIds, type, featured, location, physicalLocationsCount, totalLocationsCount, category, distanceKm];
}
