part of 'business_home_view_cubit.dart';

final class BusinessHomeViewState extends Equatable {
  final BusinessViewCubitStatus businessHomeViewState;
  final List<ListableBusiness> featuredBusinesses;
  final List<ListableBusiness> normalBusinesses;
  final List<BusinessCategory> businessCategories;

  const BusinessHomeViewState({
    this.businessHomeViewState = BusinessViewCubitStatus.initial,
    this.featuredBusinesses = const [],
    this.normalBusinesses = const [],
    this.businessCategories = const [],
  });

  BusinessHomeViewState copyWith({
    BusinessViewCubitStatus? businessHomeViewState,
    List<ListableBusiness>? featuredBusinesses,
    List<ListableBusiness>? normalBusinesses,
    List<BusinessCategory>? businessCategories,
  }) {
    return BusinessHomeViewState(
      businessHomeViewState:
          businessHomeViewState ?? this.businessHomeViewState,
      featuredBusinesses: featuredBusinesses ?? this.featuredBusinesses,
      normalBusinesses: normalBusinesses ?? this.normalBusinesses,
      businessCategories: businessCategories ?? this.businessCategories,
    );
  }

  @override
  List<dynamic> get props => [
        businessHomeViewState,
        featuredBusinesses,
        normalBusinesses,
        businessCategories,
      ];
}
