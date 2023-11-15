part of 'business_details_cubit.dart';

final class BusinessDetailsState extends Equatable {
  final String? businessId;
  final Business? business;
  final BusinessViewCubitStatus status;
  final List<Promotion> promotions;
  final bool isFavourite;
  final bool favouriteIsLoading;

  const BusinessDetailsState({
    this.businessId,
    this.business,
    this.promotions = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.isFavourite = false,
    this.favouriteIsLoading = false,
  });

  BusinessDetailsState copyWith({
    String? businessId,
    Business? business,
    BusinessViewCubitStatus? status,
    List<Promotion>? promotions,
    bool isFavourite = false,
    bool favouriteIsLoading = false,
  }) {
    return BusinessDetailsState(
      businessId: businessId ?? this.businessId,
      business: business ?? this.business,
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      isFavourite: isFavourite,
      favouriteIsLoading: favouriteIsLoading,
    );
  }

  @override
  List<Object?> get props => [
        businessId,
        business,
        status,
        promotions,
        isFavourite,
        favouriteIsLoading,
      ];
}
