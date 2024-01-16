part of 'promotion_details_cubit.dart';

final class PromotionDetailsState extends Equatable {
  final String? promotionId;
  final Promotion? promotion;
  final BusinessViewCubitStatus status;

  const PromotionDetailsState({
    this.promotionId,
    this.promotion,
    this.status = BusinessViewCubitStatus.initial,
  });

  PromotionDetailsState copyWith({
    String? promotionId,
    Promotion? promotion,
    BusinessViewCubitStatus? status,
  }) {
    return PromotionDetailsState(
      promotionId: promotionId ?? this.promotionId,
      promotion: promotion ?? this.promotion,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        promotionId,
        promotion,
        status,
      ];
}
