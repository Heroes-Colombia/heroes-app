part of 'business_home_view_cubit.dart';

final class BusinessHomeViewState extends Equatable {
  final BusinessViewCubitStatus businessHomeViewState;
  final List<ListableBusiness> featuredBusinesses;
  final List<ListableBusiness> normalBusinesses;

  const BusinessHomeViewState({
    this.businessHomeViewState = BusinessViewCubitStatus.initial,
    this.featuredBusinesses = const [],
    this.normalBusinesses = const [],
  });

  BusinessHomeViewState copyWith({
    BusinessViewCubitStatus? businessHomeViewState,
    List<ListableBusiness>? featuredBusinesses,
    List<ListableBusiness>? normalBusinesses,
  }) {
    return BusinessHomeViewState(
      businessHomeViewState:
          businessHomeViewState ?? this.businessHomeViewState,
      featuredBusinesses: featuredBusinesses ?? this.featuredBusinesses,
      normalBusinesses: normalBusinesses ?? this.normalBusinesses,
    );
  }

  @override
  List<dynamic> get props => [
        businessHomeViewState,
        featuredBusinesses,
        normalBusinesses,
      ];
}
