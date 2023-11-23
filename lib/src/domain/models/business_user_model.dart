import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';

class BusinessUser extends Equatable {
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
  final List<String> ownedBusinesses;

  const BusinessUser({
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
    required this.ownedBusinesses,
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
        ownedBusinesses
      ];

  factory BusinessUser.fromJson(Map<String, dynamic> json) {
    return BusinessUser(
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
      ownedBusinesses: json['owned_businesses'] != null
          ? List<String>.from(json['owned_businesses'])
          : [],
    );
  }

  BusinessUser copyWith({
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
    List<String>? ownedBusinesses,
  }) {
    return BusinessUser(
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
      ownedBusinesses: ownedBusinesses ?? this.ownedBusinesses,
    );
  }
}
