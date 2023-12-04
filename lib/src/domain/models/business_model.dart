import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';

class Business extends Equatable {
  final BusinessStatus status;
  final String phoneNumber;
  final String ownerName;
  final String name;
  final List<String> location;
  final String identification;
  final String email;
  final List<dynamic> categories;
  final String address;
  final List<UserReview> reviews;
  final String featuredImage;
  final String ownerUid;

  const Business(
      {required this.status,
      required this.phoneNumber,
      required this.ownerName,
      required this.name,
      required this.location,
      required this.identification,
      required this.email,
      required this.categories,
      required this.address,
      required this.reviews,
      required this.featuredImage,
      required this.ownerUid});

  @override
  List<Object?> get props => [
        status,
        phoneNumber,
        ownerName,
        name,
        location,
        identification,
        email,
        categories,
        address,
        reviews,
        featuredImage,
        ownerUid
      ];

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      status: BusinessStatus.values.firstWhere(
          (element) => element.toString().split('.').last == json['status']),
      phoneNumber: json['phone_number'] as String,
      ownerName: json['owner_name'] as String,
      name: json['name'] as String,
      location:
          json["location"] != null ? json['location'] as List<String> : [],
      identification: json['identification'] as String,
      email: json['email'] as String,
      categories: json["categories"] != null ? json['categories'] : [],
      address: json['address'] as String,
      reviews: json["revies"] != null
          ? json['reviews'].map((e) => UserReview.fromJson(e)).toList()
          : [],
      featuredImage: json["featured_image"] != null
          ? json['featured_image'] as String
          : "",
      ownerUid: json["owner_uid"] != null ? json['owner_uid'] as String : "",
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
    String? phoneNumber,
    String? ownerName,
    String? name,
    List<String>? location,
    String? identification,
    String? email,
    List<String>? categories,
    String? address,
    List<UserReview>? reviews,
    String? featuredImage,
    String? ownerUid,
  }) {
    return Business(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      ownerName: ownerName ?? this.ownerName,
      name: name ?? this.name,
      location: location ?? this.location,
      identification: identification ?? this.identification,
      email: email ?? this.email,
      categories: categories ?? this.categories,
      address: address ?? this.address,
      reviews: reviews ?? this.reviews,
      featuredImage: featuredImage ?? this.featuredImage,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }
}
