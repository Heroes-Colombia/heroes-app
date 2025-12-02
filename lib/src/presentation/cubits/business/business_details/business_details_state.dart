part of 'business_details_cubit.dart';

final class BusinessDetailsState extends Equatable {
  final String? businessId;
  final Business? business;
  final BusinessViewCubitStatus status;
  final List<Promotion> promotions;
  final List<UserReview> reviews;
  final List<UserReview> allUserReviews;
  final List<BusinessLocation> locations;
  final bool isFavourite;
  final bool favouriteIsLoading;
  final bool isReviewLoading;

  const BusinessDetailsState({
    this.businessId,
    this.business,
    this.promotions = const [],
    this.reviews = const [],
    this.allUserReviews = const [],
    this.locations = const [],
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
    List<BusinessLocation>? locations,
    bool? isFavourite,
    bool? favouriteIsLoading,
    bool? isReviewLoading,
  }) {
    return BusinessDetailsState(
      businessId: businessId ?? this.businessId,
      business: business ?? this.business,
      reviews: reviews ?? this.reviews,
      allUserReviews: allUserReviews ?? this.allUserReviews,
      locations: locations ?? this.locations,
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      isFavourite: isFavourite ?? this.isFavourite,
      favouriteIsLoading: favouriteIsLoading ?? this.favouriteIsLoading,
      isReviewLoading: isReviewLoading ?? this.isReviewLoading,
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
        locations,
        isFavourite,
        favouriteIsLoading,
        isReviewLoading,
      ];
}
