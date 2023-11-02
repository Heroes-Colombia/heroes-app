import 'package:equatable/equatable.dart';

class ListableBusiness extends Equatable {
  final String name;
  final String id;
  final String featuredImage;

  const ListableBusiness({
    required this.name,
    required this.id,
    required this.featuredImage,
  });

  factory ListableBusiness.fromJson(Map<String, dynamic> json) {
    return ListableBusiness(
      name: json['name'] as String,
      id: json['id'] as String,
      featuredImage: json["featured_image"] != null
          ? json['featured_image'] as String
          : "",
    );
  }

  @override
  List<Object?> get props => [name, id, featuredImage];
}
