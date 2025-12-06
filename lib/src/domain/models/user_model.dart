import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';

class User extends Equatable {
  final String uid;
  final String? license;
  final String? identificationCard;
  final String firstName;
  final String? secondName;
  final String firstLastName;
  final String? secondLastName;
  final UserPermissions
  permission; // V1 field - kept for backward compatibility
  final String rank;
  final String email;
  final bool verified;
  final UserStatus? status;
  final List<String> favouriteBusinesses;
  final List<String> favouritePromotions;
  final String? deviceNotificationToken;

  // V2 Schema Fields (consumer-only)
  final String? userType; // "admin" | "consumer" | "business_team"
  final String? city; // User's current city (auto-detected from GPS)

  // V3 Schema Fields - Demographics & Preferences
  final DateTime? dateOfBirth; // User's date of birth for age calculation
  final String? sex; // "male" | "female"
  final List<String>?
  preferredCategories; // User's preferred business categories
  final List<String>?
  familyInvitations; // Legacy field - kept for backward compatibility

  // V4 Schema Fields - Family Invitation System
  /// Permanent invite code for this military user (e.g., "HEROES-ABC123")
  /// Generated once, reusable for unlimited family member invitations
  /// Only military personnel (permission: user) have invite codes
  /// Beneficiaries (permission: beneficiary, userType: consumer) do NOT have codes
  final String? inviteCode;

  const User({
    required this.uid,
    this.license,
    this.identificationCard,
    required this.firstName,
    this.secondName,
    required this.firstLastName,
    this.secondLastName,
    required this.permission,
    required this.rank,
    required this.email,
    required this.verified,
    this.status,
    required this.favouriteBusinesses,
    required this.favouritePromotions,
    this.deviceNotificationToken,
    this.userType, // V2 field
    this.city, // V2 field - auto-detected from GPS
    this.dateOfBirth, // V3 field
    this.sex, // V3 field
    this.preferredCategories, // V3 field
    this.familyInvitations, // V3 field
    this.inviteCode, // V4 field
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
    city,
    dateOfBirth,
    sex,
    preferredCategories,
    familyInvitations,
    inviteCode,
  ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      license: json['license'] as String?,
      identificationCard: json['identification_card'] as String?,
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
      // V2 fields with backward compatibility
      userType: json['user_type'] as String?,
      city: json['city'] as String?,
      // V3 fields with backward compatibility
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'] as String)
              : null,
      sex: json['sex'] as String?,
      preferredCategories:
          json['preferred_categories'] != null
              ? List<String>.from(json['preferred_categories'])
              : null,
      familyInvitations:
          json['family_invitations'] != null
              ? List<String>.from(json['family_invitations'])
              : null,
      // V4 fields with backward compatibility
      inviteCode: json['invite_code'] as String?,
    );
  }

  static Map<String, dynamic> toInitialFirebaseJson(
    Map<String, dynamic> json,
    UserPermissions? permission,
  ) {
    return {
      'email': json['email']?.toString().toLowerCase().trim() ?? '',
      'license': json['license'] ?? "",
      'first_name': json['first_name'],
      'second_name': json['second_name'] ?? "",
      'first_last_name': json['first_last_name'],
      'second_last_name': json['second_last_name'] ?? "",
      'verified': true,
      'rank': json['rank'],
      "permission":
          permission != null
              ? permission.toString().split(".").last
              : UserPermissions.user.toString().split(".").last,
      "status": UserStatus.active.toString().split('.').last,
      "favourite_businesses": [],
      "favourite_promotions": [],
      "password": json['password'],
      "identification_card": json['identification_card'] ?? "",
      // V3 fields
      if (json['date_of_birth'] != null)
        'date_of_birth': (json['date_of_birth'] as DateTime).toIso8601String(),
      if (json['sex'] != null) 'sex': json['sex'],
      if (json['preferred_categories'] != null)
        'preferred_categories': json['preferred_categories'],
      if (json['family_invitations'] != null)
        'family_invitations': json['family_invitations'],
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
    String? city,
    DateTime? dateOfBirth,
    String? sex,
    List<String>? preferredCategories,
    List<String>? familyInvitations,
    String? inviteCode,
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
      city: city ?? this.city,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      familyInvitations: familyInvitations ?? this.familyInvitations,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  /// Helper: Check if user is a business team member
  bool get isBusinessUser {
    // Check both V1 and V2 schemas
    return permission == UserPermissions.business ||
        userType == 'business_team';
  }

  /// Helper: Check if user is a consumer (military personnel or beneficiary)
  bool get isConsumer {
    return userType == 'consumer' ||
        permission == UserPermissions.user ||
        permission == UserPermissions.beneficiary;
  }

  /// Helper: Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Helper: Get age range for analytics
  /// Returns ranges: "18-25", "26-35", "36-45", "46-55", "56-65", "66+"
  String? get ageRange {
    final userAge = age;
    if (userAge == null) return null;

    if (userAge < 18) return "under-18";
    if (userAge <= 25) return "18-25";
    if (userAge <= 35) return "26-35";
    if (userAge <= 45) return "36-45";
    if (userAge <= 55) return "46-55";
    if (userAge <= 65) return "56-65";
    return "66+";
  }

  /// Helper: Check if user is a beneficiary (family member)
  /// Beneficiaries have:
  /// - permission: UserPermissions.beneficiary
  /// - userType: "consumer"
  /// - No invite code (cannot invite others)
  bool get isBeneficiary {
    return permission == UserPermissions.beneficiary;
  }

  /// Helper: Check if user is active military personnel (can invite family)
  /// Active military have:
  /// - permission: UserPermissions.user
  /// - userType: "consumer"
  /// - Can generate invite codes
  bool get isMilitaryPersonnel {
    return permission == UserPermissions.user &&
        (userType == 'consumer' || userType == null);
  }

  /// Helper: Check if user can invite family members
  /// Only active military personnel can invite family
  bool get canInviteFamily {
    return isMilitaryPersonnel;
  }
}
