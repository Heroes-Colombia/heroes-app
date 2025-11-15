part of 'promotion_details_cubit.dart';

final class PromotionDetailsState extends Equatable {
  final String? promotionId;
  final Promotion? promotion;
  final BusinessViewCubitStatus status;
  final bool isFavourite;
  final bool favouriteIsLoading;

  const PromotionDetailsState({
    this.promotionId,
    this.promotion,
    this.status = BusinessViewCubitStatus.initial,
    this.isFavourite = false,
    this.favouriteIsLoading = false,
  });

  PromotionDetailsState copyWith({
    String? promotionId,
    Promotion? promotion,
    BusinessViewCubitStatus? status,
    bool? isFavourite,
    bool? favouriteIsLoading,
  }) {
    return PromotionDetailsState(
      promotionId: promotionId ?? this.promotionId,
      promotion: promotion ?? this.promotion,
      status: status ?? this.status,
      isFavourite: isFavourite ?? this.isFavourite,
      favouriteIsLoading: favouriteIsLoading ?? this.favouriteIsLoading,
    );
  }

  @override
  List<Object?> get props => [
        promotionId,
        promotion,
        status,
        isFavourite,
        favouriteIsLoading,
      ];
}
