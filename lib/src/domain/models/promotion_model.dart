import 'package:equatable/equatable.dart';

class Advertisement extends Equatable {
  final String businessId;
  final String description;
  final DateTime expiredAt;
  final String instructions;
  final int percentage;
  final String status;
  final String title;

  const Advertisement({
    required this.businessId,
    required this.description,
    required this.expiredAt,
    required this.instructions,
    required this.percentage,
    required this.status,
    required this.title,
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
      ];

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      businessId: json['business_id'] as String,
      description: json['description'] as String,
      expiredAt: DateTime.parse(json['expired_at'] as String),
      instructions: json['instructions'] as String,
      percentage: json['percentage'] as int,
      status: json['status'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'description': description,
      'expired_at': expiredAt.toIso8601String(),
      'instructions': instructions,
      'percentage': percentage,
      'status': status,
      'title': title,
    };
  }

  Advertisement copyWith({
    String? businessId,
    String? description,
    DateTime? expiredAt,
    String? instructions,
    int? percentage,
    String? status,
    String? title,
  }) {
    return Advertisement(
      businessId: businessId ?? this.businessId,
      description: description ?? this.description,
      expiredAt: expiredAt ?? this.expiredAt,
      instructions: instructions ?? this.instructions,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      title: title ?? this.title,
    );
  }
}
