part of 'all_promotions_cubit.dart';

enum PromotionViewCubitStatus { initial, loading, success, error }

final class AllPromotionsState extends Equatable {
  final List<Promotion> promotions;
  final List<Promotion> activePromotions;
  final List<Promotion> expiredPromotions;
  final PromotionViewCubitStatus status;
  final String selectedCategoryId;
  final List<BusinessCategory> categories;
  final PromotionFilter filter;

  const AllPromotionsState({
    this.promotions = const [],
    this.activePromotions = const [],
    this.expiredPromotions = const [],
    this.status = PromotionViewCubitStatus.initial,
    this.selectedCategoryId = '',
    this.categories = const [],
    this.filter = const PromotionFilter(),
  });

  AllPromotionsState copyWith({
    List<Promotion>? promotions,
    List<Promotion>? activePromotions,
    List<Promotion>? expiredPromotions,
    PromotionViewCubitStatus? status,
    String? selectedCategoryId,
    List<BusinessCategory>? categories,
    PromotionFilter? filter,
  }) {
    return AllPromotionsState(
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      activePromotions: activePromotions ?? this.activePromotions,
      expiredPromotions: expiredPromotions ?? this.expiredPromotions,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [
        promotions,
        activePromotions,
        expiredPromotions,
        status,
        selectedCategoryId,
        categories,
        filter,
      ];
}
