part of 'owned_businesses_cubit.dart';

final class OwnedBusinessesState extends Equatable {
  final List<ListableBusiness> businesses;
  final BusinessViewCubitStatus status;
  final List<BusinessCategory> businessCategories;

  const OwnedBusinessesState({
    this.businesses = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.businessCategories = const [],
  });

  OwnedBusinessesState copyWith({
    List<ListableBusiness>? businesses,
    BusinessViewCubitStatus? status,
    List<BusinessCategory>? businessCategories,
  }) {
    return OwnedBusinessesState(
      status: status ?? this.status,
      businesses: businesses ?? this.businesses,
      businessCategories: businessCategories ?? this.businessCategories,
    );
  }

  @override
  List<Object> get props => [
        businesses,
        status,
        businessCategories,
      ];
}
