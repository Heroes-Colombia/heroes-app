import 'package:equatable/equatable.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';

// ignore: must_be_immutable
class ListableBusiness extends Equatable {
  final String name;
  final String id;
  final String featuredImage;
  final List<String> categoryIds;
  final String type; // "physical" | "online" | "hybrid"
  BusinessCategory? category;

  ListableBusiness({
    required this.name,
    required this.id,
    required this.featuredImage,
    required this.categoryIds,
    this.type = 'physical', // Default to physical for backward compatibility
    this.category,
  });

  factory ListableBusiness.fromJson(Map<String, dynamic> json) {
    return ListableBusiness(
      name: json['name'] as String,
      id: json['id'] as String,
      featuredImage:
          json["featured_image"] != null
              ? json['featured_image'] as String
              : "",
      categoryIds:
          json['categories'] != null
              ? List<String>.from(json['categories'])
              : [],
      type: json['type'] as String? ?? 'physical', // Default to physical for backward compatibility
      category: null, // Will be populated later by a repository or service
    );
  }

  /// Check if this is a physical business
  bool get isPhysical => type == 'physical' || type == 'hybrid';

  /// Check if this is an online business
  bool get isOnline => type == 'online' || type == 'hybrid';

  /// Check if this is a hybrid business (both physical and online)
  bool get isHybrid => type == 'hybrid';

  @override
  List<Object?> get props => [name, id, featuredImage, categoryIds, type, category];
}
