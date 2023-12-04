import 'package:equatable/equatable.dart';

class ListableUserModel extends Equatable {
  final String firstName;
  final String secondName;
  final String firstLastName;
  final String secondLastName;
  final String email;
  final String uid;

  const ListableUserModel({
    required this.firstName,
    required this.secondName,
    required this.firstLastName,
    required this.secondLastName,
    required this.email,
    required this.uid,
  });

  @override
  List<Object?> get props => [
        firstName,
        secondName,
        firstLastName,
        secondLastName,
        email,
        uid,
      ];

  factory ListableUserModel.fromJson(Map<String, dynamic> json) {
    return ListableUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      secondName: json['second_name'] as String,
      firstLastName: json['first_last_name'] as String,
      secondLastName: json['second_last_name'] as String,
    );
  }
}
