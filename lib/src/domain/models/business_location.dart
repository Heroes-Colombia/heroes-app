import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a business location (physical or online) from the locations subcollection
/// Schema V2: businesses/{businessId}/locations/{locationId}
// ignore: must_be_immutable
class BusinessLocation extends Equatable {
  final String id;
  final String name;
  final bool isPrimary;
  final String type; // "physical" | "online"
  final String status; // "active" | "inactive"

  // Contact information (all locations)
  final String? phone;
  final String? email;

  // Physical location fields (only if type = "physical")
  final String? address;
  final GeoPoint? location;
  final Map<String, dynamic>? geoHash;
  final Map<String, dynamic>? businessHours;

  // Online location fields (only if type = "online")
  final List<String>? deliveryZones;
  final String? deliveryType; // "national" | "regional" | "local"
  final String? whatsapp;

  // Metadata
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  // Mutable field for distance calculation
  double? distanceKm;

  BusinessLocation({
    required this.id,
    required this.name,
    required this.isPrimary,
    required this.type,
    required this.status,
    this.phone,
    this.email,
    this.address,
    this.location,
    this.geoHash,
    this.businessHours,
    this.deliveryZones,
    this.deliveryType,
    this.whatsapp,
    this.createdAt,
    this.updatedAt,
    this.distanceKm,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        isPrimary,
        type,
        status,
        phone,
        email,
        address,
        location,
        geoHash,
        businessHours,
        deliveryZones,
        deliveryType,
        whatsapp,
        createdAt,
        updatedAt,
        distanceKm,
      ];

  /// Check if this is a physical location (has address and coordinates)
  bool get isPhysical => type == 'physical';

  /// Check if this is an online location
  bool get isOnline => type == 'online';

  /// Check if this location is active
  bool get isActive => status == 'active';

  /// Get formatted address (for physical locations)
  String get displayAddress => address ?? 'Dirección no disponible';

  /// Get display name with type indicator
  String get displayName {
    if (isPrimary) {
      return '$name (Principal)';
    }
    return name;
  }

  factory BusinessLocation.fromJson(Map<String, dynamic> json, String documentId) {
    // Handle GeoPoint conversion - it could be a GeoPoint or a Map
    GeoPoint? geoPoint;
    if (json['location'] != null) {
      if (json['location'] is GeoPoint) {
        geoPoint = json['location'] as GeoPoint;
      } else if (json['location'] is Map) {
        final locMap = json['location'] as Map<String, dynamic>;
        if (locMap['latitude'] != null && locMap['longitude'] != null) {
          geoPoint = GeoPoint(
            (locMap['latitude'] as num).toDouble(),
            (locMap['longitude'] as num).toDouble(),
          );
        }
      }
    }

    return BusinessLocation(
      id: documentId,
      name: json['name'] as String? ?? 'Sin nombre',
      isPrimary: json['is_primary'] as bool? ?? false,
      type: json['type'] as String? ?? 'physical',
      status: json['status'] as String? ?? 'active',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      location: geoPoint,
      geoHash: json['geo_hash'] as Map<String, dynamic>?,
      businessHours: json['business_hours'] as Map<String, dynamic>?,
      deliveryZones: json['delivery_zones'] != null
          ? List<String>.from(json['delivery_zones'] as List)
          : null,
      deliveryType: json['delivery_type'] as String?,
      whatsapp: json['whatsapp'] as String?,
      createdAt: json['created_at'] as Timestamp?,
      updatedAt: json['updated_at'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_primary': isPrimary,
      'type': type,
      'status': status,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (location != null) 'location': location,
      if (geoHash != null) 'geo_hash': geoHash,
      if (businessHours != null) 'business_hours': businessHours,
      if (deliveryZones != null) 'delivery_zones': deliveryZones,
      if (deliveryType != null) 'delivery_type': deliveryType,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  BusinessLocation copyWith({
    String? id,
    String? name,
    bool? isPrimary,
    String? type,
    String? status,
    String? phone,
    String? email,
    String? address,
    GeoPoint? location,
    Map<String, dynamic>? geoHash,
    Map<String, dynamic>? businessHours,
    List<String>? deliveryZones,
    String? deliveryType,
    String? whatsapp,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return BusinessLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      isPrimary: isPrimary ?? this.isPrimary,
      type: type ?? this.type,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      location: location ?? this.location,
      geoHash: geoHash ?? this.geoHash,
      businessHours: businessHours ?? this.businessHours,
      deliveryZones: deliveryZones ?? this.deliveryZones,
      deliveryType: deliveryType ?? this.deliveryType,
      whatsapp: whatsapp ?? this.whatsapp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
}
