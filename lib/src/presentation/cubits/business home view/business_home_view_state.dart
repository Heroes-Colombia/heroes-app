part of 'business_home_view_cubit.dart';

final class BusinessHomeViewState extends Equatable {
  final BusinessViewCubitStatus businessHomeViewState;
  final List<ListableBusiness> featuredBusinesses;

  const BusinessHomeViewState({
    this.businessHomeViewState = BusinessViewCubitStatus.initial,
    this.featuredBusinesses = const [],
  });

  BusinessHomeViewState copyWith({
    BusinessViewCubitStatus? businessHomeViewState,
    List<ListableBusiness>? featuredBusinesses,
  }) {
    return BusinessHomeViewState(
      businessHomeViewState:
          businessHomeViewState ?? this.businessHomeViewState,
      featuredBusinesses: featuredBusinesses ?? this.featuredBusinesses,
    );
  }

  @override
  List<dynamic> get props => [businessHomeViewState, featuredBusinesses];
}
