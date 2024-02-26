import 'package:equatable/equatable.dart';

class BusinessCategory extends Equatable {
  final String id;
  final String name;
  final String imageUrl;

  const BusinessCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
      ];

  BusinessCategory copyWith({
    String? id,
    String? name,
    String? imageUrl,
  }) {
    return BusinessCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': id,
      'name': name,
      'image': imageUrl,
    };
  }

  factory BusinessCategory.fromJson(Map<String, dynamic> map) {
    return BusinessCategory(
      id: map['category_id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['image'] ?? '',
    );
  }
}
