import 'package:equatable/equatable.dart';

/// Filter criteria for querying businesses
/// Supports combining multiple filter types (category, type, featured status)
class BusinessFilter extends Equatable {
  /// Filter by specific category ID
  final String? categoryId;

  /// If true, show only featured businesses
  final bool? featuredOnly;

  /// Filter by business types: ["online", "physical", "hybrid"]
  /// Can specify multiple types to show businesses matching any of them
  final List<String>? businessTypes;

  const BusinessFilter({
    this.categoryId,
    this.featuredOnly,
    this.businessTypes,
  });

  /// Create a filter with no criteria (shows all businesses)
  const BusinessFilter.all() : this();

  /// Create a filter for featured businesses only
  const BusinessFilter.featured() : this(featuredOnly: true);

  /// Create a filter for online businesses only
  const BusinessFilter.online() : this(businessTypes: const ["online"]);

  /// Create a filter for physical businesses only
  const BusinessFilter.physical() : this(businessTypes: const ["physical"]);

  /// Create a filter for a specific category
  const BusinessFilter.category(String categoryId) : this(categoryId: categoryId);

  /// Check if this filter has any active criteria
  bool get hasActiveFilters => categoryId != null || featuredOnly != null || businessTypes != null;

  /// Check if this filter includes a specific business type
  bool includesType(String type) {
    if (businessTypes == null) return true; // No type filter = include all types
    return businessTypes!.contains(type);
  }

  BusinessFilter copyWith({
    String? categoryId,
    bool? featuredOnly,
    List<String>? businessTypes,
  }) {
    return BusinessFilter(
      categoryId: categoryId ?? this.categoryId,
      featuredOnly: featuredOnly ?? this.featuredOnly,
      businessTypes: businessTypes ?? this.businessTypes,
    );
  }

  @override
  List<Object?> get props => [categoryId, featuredOnly, businessTypes];
}