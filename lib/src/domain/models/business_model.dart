import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_payment_method.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';

class Business extends Equatable {
  final BusinessStatus status;
  final BusinessSubscriptionStatus subscriptionStatus;
  final String? latestTransactionDocumentId;
  final String phoneNumber;
  final String? website;
  final String ownerName;
  final String name;
  final GeoPoint location;
  final String identification;
  final String email;
  final List<dynamic> categories;
  final String address;
  final List<UserReview> reviews;
  final List<PaymentMethod> paymentMethods;
  final String featuredImage;
  final String ownerUid;
  final String type; // "physical" | "online" | "hybrid"
  final bool featured; // Enterprise plan feature - priority placement in feeds
  final String? description; // Business description

  const Business({
    required this.status,
    required this.subscriptionStatus,
    required this.latestTransactionDocumentId,
    required this.phoneNumber,
    this.website,
    required this.ownerName,
    required this.name,
    required this.location,
    required this.identification,
    required this.email,
    required this.categories,
    required this.address,
    required this.reviews,
    required this.paymentMethods,
    required this.featuredImage,
    required this.ownerUid,
    this.type = 'physical', // Default to physical for backward compatibility
    this.featured = false, // Default to false for backward compatibility
    this.description, // Optional business description
  });

  @override
  List<Object?> get props => [
    status,
    subscriptionStatus,
    latestTransactionDocumentId,
    phoneNumber,
    ownerName,
    name,
    location,
    identification,
    email,
    categories,
    address,
    reviews,
    paymentMethods,
    featuredImage,
    ownerUid,
    type,
    featured,
    description,
  ];

  /// Check if this is a physical business
  bool get isPhysical => type == 'physical' || type == 'hybrid';

  /// Check if this is an online business
  bool get isOnline => type == 'online' || type == 'hybrid';

  /// Check if this is a hybrid business (both physical and online)
  bool get isHybrid => type == 'hybrid';

  factory Business.fromJson(Map<String, dynamic> json) {
    var location;
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
    return Business(
      status: BusinessStatus.values.firstWhere(
        (element) => element.toString().split('.').last == json['status'],
      ),
      phoneNumber: json['phone_number'] as String,
      website: json['website'] as String?,
      ownerName: json['owner_name'] as String,
      name: json['name'] as String,
      location: location,
      identification: json['identification'] as String,
      email: json['email'] as String,
      categories: json["categories"] != null ? json['categories'] : [],
      address: json['address'] as String,
      paymentMethods:
          json["payment_methods"] != null
              ? json['payment_methods']
                  .map((e) => PaymentMethod.fromJson(e))
                  .toList()
              : [],
      reviews:
          json["revies"] != null
              ? json['reviews'].map((e) => UserReview.fromJson(e)).toList()
              : [],
      featuredImage:
          json["featured_image"] != null
              ? json['featured_image'] as String
              : "",
      ownerUid: json["owner_uid"] != null ? json['owner_uid'] as String : "",
      subscriptionStatus: BusinessSubscriptionStatus.values.firstWhere(
        (element) =>
            element.toString().split('.').last == json['subscription_status'],
        orElse: () => BusinessSubscriptionStatus.inactive,
      ),
      latestTransactionDocumentId:
          json["latest_transaction"] != null
              ? json['latest_transaction'] as String
              : "",
      type:
          json['type'] as String? ??
          'physical', // Default to physical for backward compatibility
      featured:
          json['featured'] as bool? ??
          false, // Default to false for backward compatibility
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'phone_number': phoneNumber,
      'website': website,
      'owner_name': ownerName,
      'name': name,
      'location': location,
      'identification': identification,
      'email': email,
      'categories': categories,
      'address': address,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'type': type,
      'description': description,
    };
  }

  static Map<String, dynamic> toInitialFirebaseJson(Map<String, dynamic> json) {
    return {
      'status': BusinessStatus.pending.toString().split('.').last,
      'phone_number': json['phone_number'],
      'website': json['website'],
      'owner_name': json['owner_name'],
      'name': json['name'],
      'location': json['location'],
      'identification': json['identification'],
      'email': json['email'],
      'categories': [],
      'address': json['address'],
      'reviews': [],
    };
  }

  Business copyWith({
    BusinessStatus? status,
    BusinessSubscriptionStatus? subscriptionStatus,
    String? latestTransactionDocumentId,
    String? phoneNumber,
    String? website,
    String? ownerName,
    String? name,
    GeoPoint? location,
    String? identification,
    String? email,
    List<String>? categories,
    String? address,
    List<UserReview>? reviews,
    List<PaymentMethod>? paymentMethods,
    String? featuredImage,
    String? ownerUid,
    String? type,
    bool? featured,
    String? description,
  }) {
    return Business(
      status: status ?? this.status,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      latestTransactionDocumentId:
          latestTransactionDocumentId ?? this.latestTransactionDocumentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      ownerName: ownerName ?? this.ownerName,
      name: name ?? this.name,
      location: location ?? this.location,
      identification: identification ?? this.identification,
      email: email ?? this.email,
      categories: categories ?? this.categories,
      address: address ?? this.address,
      reviews: reviews ?? this.reviews,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      featuredImage: featuredImage ?? this.featuredImage,
      ownerUid: ownerUid ?? this.ownerUid,
      type: type ?? this.type,
      featured: featured ?? this.featured,
      description: description ?? this.description,
    );
  }
}
