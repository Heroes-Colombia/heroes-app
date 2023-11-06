part of 'business_details_cubit.dart';

final class BusinessDetailsState extends Equatable {
  final String? businessId;
  final Business? business;
  final BusinessViewCubitStatus status;
  final List<Promotion> promotions;

  const BusinessDetailsState({
    this.businessId,
    this.business,
    this.promotions = const [],
    this.status = BusinessViewCubitStatus.initial,
  });

  BusinessDetailsState copyWith({
    String? businessId,
    Business? business,
    BusinessViewCubitStatus? status,
    List<Promotion>? promotions,
  }) {
    return BusinessDetailsState(
      businessId: businessId ?? this.businessId,
      business: business ?? this.business,
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
    );
  }

  @override
  List<Object?> get props => [businessId, business, status, promotions];
}
