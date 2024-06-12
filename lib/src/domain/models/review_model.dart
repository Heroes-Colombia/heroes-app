import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserReview extends Equatable {
  final String userId;
  final String comment;
  final double rate;
  final String businessId;
  final DateTime createdAt;

  const UserReview(
      {required this.userId,
      required this.comment,
      required this.rate,
      required this.businessId,
      required this.createdAt});

  @override
  List<Object?> get props => [
        userId,
        comment,
        rate,
        businessId,
        createdAt,
      ];

  factory UserReview.fromJson(Map<String, dynamic> json) {
    var createdAt = json['created_at'] as Timestamp;

    return UserReview(
      userId: json['user_id'] as String,
      comment: json['comment'] as String,
      rate: json['rate'] != null ? double.parse(json['rate'].toString()) : 0.0,
      businessId: json['business_id'] as String,
      createdAt: createdAt.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'comment': comment,
      'rate': rate,
      'business_id': businessId,
      'created_at': createdAt,
      'status': 'pending',
    };
  }

  UserReview copyWith({
    String? userId,
    String? comment,
    double? rate,
    String? businessId,
    DateTime? createdAt,
  }) {
    return UserReview(
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      rate: rate ?? this.rate,
      businessId: businessId ?? this.businessId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
