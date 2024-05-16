part of 'owned_business_details_cubit.dart';

final class OwnedBusinessDetailsState extends Equatable {
  final String? businessId;
  final Business? business;
  final BusinessViewCubitStatus status;
  final List<Promotion> promotions;
  final List<UserReview> allUserReviews;
  final List<ListableUserModel> allManagers;
  final List<PaymentMethod> allPaymentMethods;
  final String selectedPaymentMethod;
  final bool isManagersLoading;
  final bool isReviewLoading;
  final bool userAcceptedTerms;
  final Map<String, dynamic> acceptanceData;
  final BusinessTransaction? latestTransaction;
  final List<BusinessCategory> allCategories;

  const OwnedBusinessDetailsState({
    this.businessId,
    this.business,
    this.promotions = const [],
    this.allUserReviews = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.isReviewLoading = false,
    this.allManagers = const [],
    this.selectedPaymentMethod = '',
    this.isManagersLoading = false,
    this.allPaymentMethods = const [],
    this.userAcceptedTerms = false,
    this.acceptanceData = const {},
    this.latestTransaction,
    this.allCategories = const [],
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
    String selectedPaymentMethod = '',
    bool isManagersLoading = false,
    List<PaymentMethod>? allPaymentMethods,
    bool userAcceptedTerms = false,
    Map<String, dynamic>? acceptanceData,
    BusinessTransaction? latestTransaction,
    List<BusinessCategory>? allCategories,
  }) {
    return OwnedBusinessDetailsState(
      businessId: businessId ?? this.businessId,
      business: business ?? this.business,
      allUserReviews: allUserReviews ?? this.allUserReviews,
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      isReviewLoading: isReviewLoading,
      allManagers: allManagers ?? this.allManagers,
      selectedPaymentMethod: selectedPaymentMethod,
      isManagersLoading: isManagersLoading,
      allPaymentMethods: allPaymentMethods ?? this.allPaymentMethods,
      userAcceptedTerms: userAcceptedTerms,
      acceptanceData: acceptanceData ?? this.acceptanceData,
      latestTransaction: latestTransaction ?? this.latestTransaction,
      allCategories: allCategories ?? this.allCategories,
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
        selectedPaymentMethod,
        isManagersLoading,
        allPaymentMethods,
        userAcceptedTerms,
        acceptanceData,
        latestTransaction,
        allCategories,
      ];
}
