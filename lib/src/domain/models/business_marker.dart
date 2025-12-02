import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BusinessMarker extends Equatable {
  final String name;
  final GeoPoint location;
  final String address;
  final String businessId;
  final List<dynamic> categories;
  final String? phoneNumber;

  const BusinessMarker({
    required this.name,
    required this.location,
    required this.address,
    required this.businessId,
    this.categories = const [],
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
    name,
    location,
    address,
    businessId,
    categories,
    phoneNumber,
  ];

  factory BusinessMarker.fromJson(Map<String, dynamic> json) {
    // Parse location - handle both GeoPoint and Map formats
    GeoPoint location;
    if (json["location"] != null) {
      if (json['location'] is GeoPoint) {
        location = json['location'] as GeoPoint;
      } else if (json['location'] is Map<String, dynamic>) {
        final locMap = json['location'] as Map<String, dynamic>;
        location = GeoPoint(
          locMap['latitude'] as double,
          locMap['longitude'] as double,
        );
      } else {
        location = const GeoPoint(0, 0);
      }
    } else if (json['geo_hash'] != null) {
      // Fallback to geo_hash if location is missing
      try {
        final geoHash = json['geo_hash'] as Map<String, dynamic>;
        if (geoHash['geopoint'] is GeoPoint) {
          location = geoHash['geopoint'] as GeoPoint;
        } else if (geoHash['geopoint'] is Map<String, dynamic>) {
          final locMap = geoHash['geopoint'] as Map<String, dynamic>;
          location = GeoPoint(
            locMap['latitude'] as double,
            locMap['longitude'] as double,
          );
        } else {
          location = const GeoPoint(0, 0);
        }
      } catch (e) {
        location = const GeoPoint(0, 0);
      }
    } else {
      location = const GeoPoint(0, 0);
    }

    return BusinessMarker(
      name: json['name'] as String,
      location: location,
      address: json['address'] as String,
      businessId: json['id'] as String,
      categories: json['categories'] as List<dynamic>? ?? [],
      phoneNumber: json['phone_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'address': address,
      'business_id': businessId,
      'categories': categories,
      'phone': phoneNumber,
    };
  }

  BusinessMarker copyWith({
    String? name,
    GeoPoint? location,
    String? address,
    String? businessId,
    List<dynamic>? categories,
    String? phoneNumber,
  }) {
    return BusinessMarker(
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      businessId: businessId ?? this.businessId,
      categories: categories ?? this.categories,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
