import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';

class User extends Equatable {
  final String uid;
  final String username;
  final String firstName;
  final String secondName;
  final String lastName;
  final UserPermissions permission;
  final String rank;
  final String email;
  final UserStatus status;

  const User({
    required this.uid,
    required this.username,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.permission,
    required this.rank,
    required this.email,
    required this.status,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        username,
        firstName,
        secondName,
        lastName,
        permission,
        rank,
        status,
      ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      secondName: json['second_name'] as String,
      lastName: json['last_name'] as String,
      rank: json['rank'] as String,
      permission: UserPermissions.values.firstWhere((element) =>
          element.toString().split('.').last == json['permission']),
      status: UserStatus.values.firstWhere(
          (element) => element.toString().split('.').last == json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'first_name': firstName,
      'second_name': secondName,
      'last_name': lastName,
      'rank': rank,
      'permission': permission.toString().split('.').last,
      'status': status.toString().split('.').last,
    };
  }

  Map<String, dynamic> toJsonRequest() {
    return {
      'email': email,
      'username': username,
      'first_name': firstName,
      'second_name': secondName,
      'last_name': lastName,
      'rank': rank,
    };
  }

  static Map<String, dynamic> toInitialFirebaseJson(
      Map<String, dynamic> json, UserPermissions? permission) {
    return {
      'email': json['email'],
      'username': json['username'],
      'first_name': json['first_name'],
      'second_name': json['second_name'],
      'last_name': json['last_name'],
      'verified': false,
      'rank': json['rank'],
      "permission": permission != null
          ? permission.toString().split(".").last
          : UserPermissions.user.toString().split(".").last,
      "status": UserStatus.pending.toString().split('.').last,
      "favourite_businesses": [],
      "password": json['password'],
    };
  }

  User copyWith({
    String? uid,
    String? username,
    String? firstName,
    String? secondName,
    String? lastName,
    UserPermissions? permission,
    String? email,
    String? rank,
    UserStatus? status,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      lastName: lastName ?? this.lastName,
      permission: permission ?? this.permission,
      status: status ?? this.status,
      rank: rank ?? this.rank,
    );
  }
}
