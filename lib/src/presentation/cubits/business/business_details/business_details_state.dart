part of 'business_details_cubit.dart';

final class BusinessDetailsState extends Equatable {
  final String? businessId;
  final Business? business;
  final BusinessViewCubitStatus status;
  final List<Promotion> promotions;
  final List<UserReview> reviews;
  final List<UserReview> allUserReviews;
  final bool isFavourite;
  final bool favouriteIsLoading;
  final bool isReviewLoading;

  const BusinessDetailsState({
    this.businessId,
    this.business,
    this.promotions = const [],
    this.reviews = const [],
    this.allUserReviews = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.isFavourite = false,
    this.favouriteIsLoading = false,
    this.isReviewLoading = false,
  });

  BusinessDetailsState copyWith({
    String? businessId,
    Business? business,
    BusinessViewCubitStatus? status,
    List<Promotion>? promotions,
    List<UserReview>? reviews,
    List<UserReview>? allUserReviews,
    bool? isFavourite,
    bool favouriteIsLoading = false,
    bool isReviewLoading = false,
  }) {
    return BusinessDetailsState(
      businessId: businessId ?? this.businessId,
      business: business ?? this.business,
      reviews: reviews ?? this.reviews,
      allUserReviews: allUserReviews ?? this.allUserReviews,
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      isFavourite: isFavourite ?? this.isFavourite,
      favouriteIsLoading: favouriteIsLoading,
      isReviewLoading: isReviewLoading,
    );
  }

  @override
  List<Object?> get props => [
        businessId,
        business,
        status,
        promotions,
        reviews,
        allUserReviews,
        isFavourite,
        favouriteIsLoading,
        isReviewLoading,
      ];
}
