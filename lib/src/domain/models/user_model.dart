import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';

class User extends Equatable {
  final String uid;
  final String license;
  final String firstName;
  final String secondName;
  final String firstLastName;
  final String secondLastName;
  final UserPermissions permission;
  final String rank;
  final String email;
  final bool verified;
  final List<String> favouriteBusinesses;
  final String? deviceNotificationToken;

  const User({
    required this.uid,
    required this.license,
    required this.firstName,
    required this.secondName,
    required this.firstLastName,
    required this.secondLastName,
    required this.permission,
    required this.rank,
    required this.email,
    required this.verified,
    required this.favouriteBusinesses,
    this.deviceNotificationToken,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        license,
        firstName,
        secondName,
        firstLastName,
        secondLastName,
        permission,
        rank,
        verified,
        favouriteBusinesses,
        deviceNotificationToken
      ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      license: json['license'] as String,
      firstName: json['first_name'] as String,
      secondName: json['second_name'] as String,
      firstLastName: json['first_last_name'] as String,
      secondLastName: json['second_last_name'] as String,
      rank: json['rank'] as String,
      permission: UserPermissions.values.firstWhere((element) =>
          element.toString().split('.').last == json['permission']),
      verified: json['verified'] as bool,
      favouriteBusinesses: json['favourite_businesses'] != null
          ? List<String>.from(json['favourite_businesses'])
          : [],
      deviceNotificationToken: json['device_notification_token'] as String?,
    );
  }

  static Map<String, dynamic> toInitialFirebaseJson(
      Map<String, dynamic> json, UserPermissions? permission) {
    return {
      'email': json['email'],
      'license': json['license'] ?? "",
      'first_name': json['first_name'],
      'second_name': json['second_name'],
      'first_last_name': json['first_last_name'],
      'second_last_name': json['second_last_name'],
      'verified': false,
      'rank': json['rank'],
      "permission": permission != null
          ? permission.toString().split(".").last
          : UserPermissions.user.toString().split(".").last,
      "status": UserStatus.pending.toString().split('.').last,
      "favourite_businesses": [],
      "password": json['password'],
      "identification_card": json['identification_card'] ?? "",
    };
  }

  User copyWith({
    String? uid,
    String? license,
    String? firstName,
    String? secondName,
    String? firstLastName,
    String? secondLastName,
    UserPermissions? permission,
    String? email,
    String? rank,
    bool? verified,
    List<String>? favouriteBusinesses,
    String? deviceNotificationToken,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      license: license ?? this.license,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      firstLastName: firstLastName ?? this.firstLastName,
      secondLastName: secondLastName ?? this.secondLastName,
      permission: permission ?? this.permission,
      verified: verified ?? this.verified,
      rank: rank ?? this.rank,
      favouriteBusinesses: favouriteBusinesses ?? this.favouriteBusinesses,
      deviceNotificationToken:
          deviceNotificationToken ?? this.deviceNotificationToken,
    );
  }
}
