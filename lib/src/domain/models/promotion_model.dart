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
  final String? documentId;

  // V2 Schema Fields
  final List<String> locationIds; // Empty array = applies to all locations
  final int? viewsCount; // Analytics tracking
  final int? savesCount; // Favorites tracking

  const Promotion({
    required this.businessId,
    required this.description,
    required this.expiredAt,
    required this.instructions,
    required this.percentage,
    required this.status,
    required this.title,
    required this.featuredImage,
    required this.documentId,
    this.locationIds = const [], // Default to empty (applies to all locations)
    this.viewsCount,
    this.savesCount,
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
        documentId,
        locationIds,
        viewsCount,
        savesCount,
      ];

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      businessId: json['business_id'] as String,
      description: json['description'] as String,
      expiredAt: (json['expired_at'] as Timestamp).toDate(),
      instructions: json['instructions'] as String,
      percentage: json['percentage'] as int,
      status: PromotionStatus.values.firstWhere(
        (e) => e.toString() == 'PromotionStatus.${json['status']}',
      ),
      title: json['title'] as String,
      featuredImage: json['featured_image'] as String,
      documentId: json['id'] as String?,
      // V2 fields with backward compatibility
      locationIds: json['location_ids'] != null
          ? List<String>.from(json['location_ids'])
          : [],
      viewsCount: json['views_count'] as int?,
      savesCount: json['saves_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'description': description,
      'expired_at': Timestamp.fromDate(expiredAt),
      'instructions': instructions,
      'percentage': percentage,
      'status': status.toString().split('.').last,
      'title': title,
      'featured_image': featuredImage,
      // V2 fields
      'location_ids': locationIds,
      'views_count': viewsCount,
      'saves_count': savesCount,
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
    String? documentId,
    List<String>? locationIds,
    int? viewsCount,
    int? savesCount,
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
      documentId: documentId ?? this.documentId,
      locationIds: locationIds ?? this.locationIds,
      viewsCount: viewsCount ?? this.viewsCount,
      savesCount: savesCount ?? this.savesCount,
    );
  }

  /// Helper method: Check if promotion applies to a specific location
  bool appliesToLocation(String locationId) {
    return locationIds.isEmpty || locationIds.contains(locationId);
  }

  /// Helper method: Check if promotion applies to all locations
  bool get appliesToAllLocations => locationIds.isEmpty;

  /// Returns the number of days until promotion expires
  int get daysUntilExpiration {
    final now = DateTime.now();
    return expiredAt.difference(now).inDays;
  }

  /// Returns urgency level: critical (0-2 days), urgent (3-7 days), normal (8+ days)
  String get urgencyLevel {
    final days = daysUntilExpiration;
    if (days <= 2) return 'critical';
    if (days <= 7) return 'urgent';
    return 'normal';
  }

  /// Returns human-readable urgency text
  String get urgencyText {
    final days = daysUntilExpiration;
    if (days < 0) return 'Expirada';
    if (days == 0) return 'Expira hoy';
    if (days == 1) return 'Expira mañana';
    if (days <= 2) return 'Quedan $days días';
    if (days <= 7) return '$days días restantes';
    return '';
  }

  /// Whether to show urgency badge (only show if < 8 days)
  bool get shouldShowUrgencyBadge => daysUntilExpiration >= 0 && daysUntilExpiration < 8;

  /// Check if promotion is expired
  bool get isExpired => DateTime.now().isAfter(expiredAt);
}
