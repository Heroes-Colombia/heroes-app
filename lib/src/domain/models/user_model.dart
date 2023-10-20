import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String username;
  final String firstName;
  final String secondName;
  final String lastName;
  final String permission;
  final String rank;
  final String email;

  const User({
    required this.uid,
    required this.username,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.permission,
    required this.rank,
    required this.email,
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
      ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String,
      secondName: json['second_name'] as String,
      lastName: json['last_name'] as String,
      permission: json['permission'] as String? ?? '',
      rank: json['rank'] as String,
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
      'permission': permission,
      'rank': rank,
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

  User copyWith({
    String? uid,
    String? username,
    String? firstName,
    String? secondName,
    String? lastName,
    String? permission,
    String? email,
    String? rank,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      lastName: lastName ?? this.lastName,
      permission: permission ?? this.permission,
      rank: rank ?? this.rank,
    );
  }
}
