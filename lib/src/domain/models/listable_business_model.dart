import 'package:equatable/equatable.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';

// ignore: must_be_immutable
class ListableBusiness extends Equatable {
  final String name;
  final String id;
  final String featuredImage;
  final List<String> categoryIds;
  BusinessCategory? category;

  ListableBusiness({
    required this.name,
    required this.id,
    required this.featuredImage,
    required this.categoryIds,
    required this.category,
  });

  factory ListableBusiness.fromJson(Map<String, dynamic> json) {
    return ListableBusiness(
      name: json['name'] as String,
      id: json['id'] as String,
      featuredImage: json["featured_image"] != null
          ? json['featured_image'] as String
          : "",
      categoryIds: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      category: null,
    );
  }

  @override
  List<Object?> get props => [name, id, featuredImage, categoryIds, category];
}
