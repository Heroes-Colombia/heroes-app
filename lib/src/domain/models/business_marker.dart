import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BusinessMarker extends Equatable {
  final String name;
  final GeoPoint location;
  final String address;
  final String businessId;

  const BusinessMarker({
    required this.name,
    required this.location,
    required this.address,
    required this.businessId,
  });

  @override
  List<Object?> get props => [
        name,
        location,
        address,
        businessId,
      ];

  factory BusinessMarker.fromJson(Map<String, dynamic> json) {
    return BusinessMarker(
      name: json['name'] as String,
      location: json["location"] != null
          ? json['location'] as GeoPoint
          : const GeoPoint(0, 0),
      address: json['address'] as String,
      businessId: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'address': address,
      'business_id': businessId,
    };
  }

  BusinessMarker copyWith({
    String? name,
    GeoPoint? location,
    String? address,
    String? businessId,
  }) {
    return BusinessMarker(
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      businessId: businessId ?? this.businessId,
    );
  }
}
