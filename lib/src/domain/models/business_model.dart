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

  const Business({
    required this.status,
    required this.subscriptionStatus,
    required this.latestTransactionDocumentId,
    required this.phoneNumber,
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
      ];

  /// Check if this is a physical business
  bool get isPhysical => type == 'physical' || type == 'hybrid';

  /// Check if this is an online business
  bool get isOnline => type == 'online' || type == 'hybrid';

  /// Check if this is a hybrid business (both physical and online)
  bool get isHybrid => type == 'hybrid';

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      status: BusinessStatus.values.firstWhere(
          (element) => element.toString().split('.').last == json['status']),
      phoneNumber: json['phone_number'] as String,
      ownerName: json['owner_name'] as String,
      name: json['name'] as String,
      location: json["location"] != null
          ? json['location'] as GeoPoint
          : const GeoPoint(0, 0),
      identification: json['identification'] as String,
      email: json['email'] as String,
      categories: json["categories"] != null ? json['categories'] : [],
      address: json['address'] as String,
      paymentMethods: json["payment_methods"] != null
          ? json['payment_methods']
              .map((e) => PaymentMethod.fromJson(e))
              .toList()
          : [],
      reviews: json["revies"] != null
          ? json['reviews'].map((e) => UserReview.fromJson(e)).toList()
          : [],
      featuredImage: json["featured_image"] != null
          ? json['featured_image'] as String
          : "",
      ownerUid: json["owner_uid"] != null ? json['owner_uid'] as String : "",
      subscriptionStatus: BusinessSubscriptionStatus.values.firstWhere(
        (element) =>
            element.toString().split('.').last == json['subscription_status'],
        orElse: () => BusinessSubscriptionStatus.inactive,
      ),
      latestTransactionDocumentId: json["latest_transaction"] != null
          ? json['latest_transaction'] as String
          : "",
      type: json['type'] as String? ?? 'physical', // Default to physical for backward compatibility
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'phone_number': phoneNumber,
      'owner_name': ownerName,
      'name': name,
      'location': location,
      'identification': identification,
      'email': email,
      'categories': categories,
      'address': address,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'type': type,
    };
  }

  static Map<String, dynamic> toInitialFirebaseJson(Map<String, dynamic> json) {
    return {
      'status': BusinessStatus.pending.toString().split('.').last,
      'phone_number': json['phone_number'],
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
  }) {
    return Business(
      status: status ?? this.status,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      latestTransactionDocumentId:
          latestTransactionDocumentId ?? this.latestTransactionDocumentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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
    );
  }
}
