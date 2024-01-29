part of 'owned_business_details_cubit.dart';

final class OwnedBusinessDetailsState extends Equatable {
  final String? businessId;
  final Business? business;
  final BusinessViewCubitStatus status;
  final List<Promotion> promotions;
  final List<UserReview> allUserReviews;
  final List<ListableUserModel> allManagers;
  final List<PaymentMethod> allPaymentMethods;
  final bool isManagersLoading;
  final bool isReviewLoading;

  const OwnedBusinessDetailsState({
    this.businessId,
    this.business,
    this.promotions = const [],
    this.allUserReviews = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.isReviewLoading = false,
    this.allManagers = const [],
    this.isManagersLoading = false,
    this.allPaymentMethods = const [],
  });

  OwnedBusinessDetailsState copyWith({
    String? businessId,
    Business? business,
    BusinessViewCubitStatus? status,
    List<Promotion>? promotions,
    List<UserReview>? reviews,
    List<UserReview>? allUserReviews,
    bool isReviewLoading = false,
    List<ListableUserModel>? allManagers,
    bool isManagersLoading = false,
    List<PaymentMethod>? allPaymentMethods,
  }) {
    return OwnedBusinessDetailsState(
      businessId: businessId ?? this.businessId,
      business: business ?? this.business,
      allUserReviews: allUserReviews ?? this.allUserReviews,
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      isReviewLoading: isReviewLoading,
      allManagers: allManagers ?? this.allManagers,
      isManagersLoading: isManagersLoading,
      allPaymentMethods: allPaymentMethods ?? this.allPaymentMethods,
    );
  }

  @override
  List<Object?> get props => [
        businessId,
        business,
        status,
        promotions,
        allUserReviews,
        isReviewLoading,
        allManagers,
        isManagersLoading,
        allPaymentMethods,
      ];
}
