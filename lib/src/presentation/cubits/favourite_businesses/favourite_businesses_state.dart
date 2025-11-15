part of 'favourite_businesses_cubit.dart';

final class FavouriteBusinessesState extends Equatable {
  final List<ListableBusiness> businesses;
  final List<dynamic> promotions; // List of Promotion models
  final List<BusinessCategory> categories;
  final BusinessViewCubitStatus status;
  final BusinessViewCubitStatus promotionsStatus;

  const FavouriteBusinessesState({
    this.businesses = const [],
    this.promotions = const [],
    this.categories = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.promotionsStatus = BusinessViewCubitStatus.initial,
  });

  FavouriteBusinessesState copyWith({
    List<ListableBusiness>? businesses,
    List<dynamic>? promotions,
    BusinessViewCubitStatus? status,
    BusinessViewCubitStatus? promotionsStatus,
    List<BusinessCategory>? categories,
  }) {
    return FavouriteBusinessesState(
      status: status ?? this.status,
      promotionsStatus: promotionsStatus ?? this.promotionsStatus,
      businesses: businesses ?? this.businesses,
      promotions: promotions ?? this.promotions,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object> get props => [
        businesses,
        promotions,
        status,
        promotionsStatus,
        categories,
      ];
}
