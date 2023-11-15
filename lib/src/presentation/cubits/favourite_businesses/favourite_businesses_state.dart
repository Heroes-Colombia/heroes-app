part of 'favourite_businesses_cubit.dart';

final class FavouriteBusinessesState extends Equatable {
  final List<ListableBusiness> businesses;
  final BusinessViewCubitStatus status;

  const FavouriteBusinessesState(
      {this.businesses = const [],
      this.status = BusinessViewCubitStatus.initial});

  FavouriteBusinessesState copyWith({
    List<ListableBusiness>? businesses,
    BusinessViewCubitStatus? status,
  }) {
    return FavouriteBusinessesState(
      status: status ?? this.status,
      businesses: businesses ?? this.businesses,
    );
  }

  @override
  List<Object> get props => [businesses, status];
}
