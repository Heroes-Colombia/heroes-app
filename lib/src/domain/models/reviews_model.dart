import 'package:equatable/equatable.dart';

class UserReviews extends Equatable {
  final String userId;
  final String comment;
  final int rate;
  final String businessId;

  const UserReviews({
    required this.userId,
    required this.comment,
    required this.rate,
    required this.businessId,
  });

  @override
  List<Object?> get props => [
        userId,
        comment,
        rate,
        businessId,
      ];

  factory UserReviews.fromJson(Map<String, dynamic> json) {
    return UserReviews(
      userId: json['user_id'] as String,
      comment: json['comment'] as String,
      rate: json['rate'] as int,
      businessId: json['business_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'comment': comment,
      'rate': rate,
      'business_id': businessId,
    };
  }

  UserReviews copyWith({
    String? userId,
    String? comment,
    int? rate,
    String? businessId,
  }) {
    return UserReviews(
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      rate: rate ?? this.rate,
      businessId: businessId ?? this.businessId,
    );
  }
}
