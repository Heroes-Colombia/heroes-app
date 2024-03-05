part of 'favourite_businesses_cubit.dart';

final class FavouriteBusinessesState extends Equatable {
  final List<ListableBusiness> businesses;
  final List<BusinessCategory> categories;
  final BusinessViewCubitStatus status;

  const FavouriteBusinessesState({
    this.businesses = const [],
    this.categories = const [],
    this.status = BusinessViewCubitStatus.initial,
  });

  FavouriteBusinessesState copyWith({
    List<ListableBusiness>? businesses,
    BusinessViewCubitStatus? status,
    List<BusinessCategory>? categories,
  }) {
    return FavouriteBusinessesState(
      status: status ?? this.status,
      businesses: businesses ?? this.businesses,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object> get props => [
        businesses,
        status,
        categories,
      ];
}
