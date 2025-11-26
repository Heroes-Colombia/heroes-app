import 'package:equatable/equatable.dart';

class PromotionFilter extends Equatable {
  final String? categoryId;
  final bool? featuredOnly;

  const PromotionFilter({
    this.categoryId,
    this.featuredOnly,
  });

  const PromotionFilter.all() : this();

  const PromotionFilter.featured() : this(featuredOnly: true);

  const PromotionFilter.category(String categoryId)
      : this(categoryId: categoryId);

  bool get hasActiveFilters => categoryId != null || featuredOnly != null;

  PromotionFilter copyWith({
    String? categoryId,
    bool? featuredOnly,
  }) {
    return PromotionFilter(
      categoryId: categoryId ?? this.categoryId,
      featuredOnly: featuredOnly ?? this.featuredOnly,
    );
  }

  @override
  List<Object?> get props => [categoryId, featuredOnly];
}
