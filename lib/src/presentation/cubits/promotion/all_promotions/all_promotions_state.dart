part of 'all_promotions_cubit.dart';

enum PromotionViewCubitStatus { initial, loading, success, error }

final class AllPromotionsState extends Equatable {
  final List<Promotion> promotions;
  final PromotionViewCubitStatus status;
  final String selectedCategoryId;
  final List<BusinessCategory> categories;
  final PromotionFilter filter;

  const AllPromotionsState({
    this.promotions = const [],
    this.status = PromotionViewCubitStatus.initial,
    this.selectedCategoryId = '',
    this.categories = const [],
    this.filter = const PromotionFilter(),
  });

  AllPromotionsState copyWith({
    List<Promotion>? promotions,
    PromotionViewCubitStatus? status,
    String? selectedCategoryId,
    List<BusinessCategory>? categories,
    PromotionFilter? filter,
  }) {
    return AllPromotionsState(
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [
        promotions,
        status,
        selectedCategoryId,
        categories,
        filter,
      ];
}
