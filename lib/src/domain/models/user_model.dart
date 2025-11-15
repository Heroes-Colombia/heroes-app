import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';

class User extends Equatable {
  final String uid;
  final String license;
  final String identificationCard;
  final String firstName;
  final String secondName;
  final String firstLastName;
  final String secondLastName;
  final UserPermissions permission; // V1 field - kept for backward compatibility
  final String rank;
  final String email;
  final bool verified;
  final UserStatus? status;
  final List<String> favouriteBusinesses;
  final List<String> favouritePromotions;
  final String? deviceNotificationToken;

  // V2 Schema Fields (consumer-only)
  final String? userType; // "admin" | "consumer" | "business_team"

  const User({
    required this.uid,
    required this.license,
    required this.identificationCard,
    required this.firstName,
    required this.secondName,
    required this.firstLastName,
    required this.secondLastName,
    required this.permission,
    required this.rank,
    required this.email,
    required this.verified,
    this.status,
    required this.favouriteBusinesses,
    required this.favouritePromotions,
    this.deviceNotificationToken,
    this.userType, // V2 field
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    license,
    identificationCard,
    firstName,
    secondName,
    firstLastName,
    secondLastName,
    permission,
    rank,
    verified,
    status,
    favouriteBusinesses,
    favouritePromotions,
    deviceNotificationToken,
    userType,
  ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      license: json['license'] as String,
      identificationCard: json['identification_card'] as String,
      firstName: json['first_name'] as String,
      secondName: json['second_name'] ?? "",
      firstLastName: json['first_last_name'] as String,
      secondLastName: json['second_last_name'] ?? "",
      rank: json['rank'] as String,
      permission: UserPermissions.values.firstWhere(
        (element) => element.toString().split('.').last == json['permission'],
      ),
      verified: json['verified'] as bool,
      status: UserStatus.values.firstWhere(
        (element) => element.toString().split('.').last == json['status'],
        orElse: () => UserStatus.pending,
      ),
      favouriteBusinesses:
          json['favourite_businesses'] != null
              ? List<String>.from(json['favourite_businesses'])
              : [],
      favouritePromotions:
          json['favourite_promotions'] != null
              ? List<String>.from(json['favourite_promotions'])
              : [],
      deviceNotificationToken: json['device_notification_token'] as String?,
      // V2 field with backward compatibility
      userType: json['user_type'] as String?,
    );
  }

  static Map<String, dynamic> toInitialFirebaseJson(
    Map<String, dynamic> json,
    UserPermissions? permission,
  ) {
    return {
      'email': json['email'],
      'license': json['license'] ?? "",
      'first_name': json['first_name'],
      'second_name': json['second_name'],
      'first_last_name': json['first_last_name'],
      'second_last_name': json['second_last_name'],
      'verified': false,
      'rank': json['rank'],
      "permission":
          permission != null
              ? permission.toString().split(".").last
              : UserPermissions.user.toString().split(".").last,
      "status": UserStatus.pending.toString().split('.').last,
      "favourite_businesses": [],
      "favourite_promotions": [],
      "password": json['password'],
      "identification_card": json['identification_card'] ?? "",
    };
  }

  User copyWith({
    String? uid,
    String? license,
    String? identificationCard,
    String? firstName,
    String? secondName,
    String? firstLastName,
    String? secondLastName,
    UserPermissions? permission,
    String? email,
    String? rank,
    bool? verified,
    UserStatus? status,
    List<String>? favouriteBusinesses,
    List<String>? favouritePromotions,
    String? deviceNotificationToken,
    String? userType,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      license: license ?? this.license,
      identificationCard: identificationCard ?? this.identificationCard,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      firstLastName: firstLastName ?? this.firstLastName,
      secondLastName: secondLastName ?? this.secondLastName,
      permission: permission ?? this.permission,
      verified: verified ?? this.verified,
      status: status ?? this.status,
      rank: rank ?? this.rank,
      favouriteBusinesses: favouriteBusinesses ?? this.favouriteBusinesses,
      favouritePromotions: favouritePromotions ?? this.favouritePromotions,
      deviceNotificationToken:
          deviceNotificationToken ?? this.deviceNotificationToken,
      userType: userType ?? this.userType,
    );
  }

  /// Helper: Check if user is a business team member
  bool get isBusinessUser {
    // Check both V1 and V2 schemas
    return permission == UserPermissions.business || userType == 'business_team';
  }

  /// Helper: Check if user is a consumer (military personnel or beneficiary)
  bool get isConsumer {
    return userType == 'consumer' ||
           permission == UserPermissions.user ||
           permission == UserPermissions.beneficiary;
  }
}
