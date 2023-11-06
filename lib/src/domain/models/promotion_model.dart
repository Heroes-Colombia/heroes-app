import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:heroes_app/assets/app_enums.dart';

class Promotion extends Equatable {
  final String businessId;
  final String description;
  final DateTime expiredAt;
  final String instructions;
  final int percentage;
  final PromotionStatus status;
  final String title;
  final String featuredImage;

  const Promotion({
    required this.businessId,
    required this.description,
    required this.expiredAt,
    required this.instructions,
    required this.percentage,
    required this.status,
    required this.title,
    required this.featuredImage,
  });

  @override
  List<Object?> get props => [
        businessId,
        description,
        expiredAt,
        instructions,
        percentage,
        status,
        title,
        featuredImage,
      ];

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      businessId: json['business_id'] as String,
      description: json['description'] as String,
      expiredAt: DateTime.fromMillisecondsSinceEpoch(
        (json['expired_at'] as Timestamp).millisecondsSinceEpoch,
      ),
      instructions: json['instructions'] as String,
      percentage: json['percentage'] as int,
      status: PromotionStatus.values.firstWhere(
        (e) => e.toString() == 'PromotionStatus.${json['status']}',
      ),
      title: json['title'] as String,
      featuredImage: json['featured_image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'description': description,
      'expired_at': expiredAt.toIso8601String(),
      'instructions': instructions,
      'percentage': percentage,
      'status': status.toString().split('.').last,
      'title': title,
      'featured_image': featuredImage,
    };
  }

  Promotion copyWith({
    String? businessId,
    String? description,
    DateTime? expiredAt,
    String? instructions,
    int? percentage,
    String? status,
    String? title,
    String? featuredImage,
  }) {
    return Promotion(
      businessId: businessId ?? this.businessId,
      description: description ?? this.description,
      expiredAt: expiredAt ?? this.expiredAt,
      instructions: instructions ?? this.instructions,
      percentage: percentage ?? this.percentage,
      status: status != null
          ? PromotionStatus.values
              .firstWhere((e) => e.toString() == 'PromotionStatus.$status')
          : this.status,
      title: title ?? this.title,
      featuredImage: featuredImage ?? this.featuredImage,
    );
  }
}
