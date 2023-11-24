part of 'owned_businesses_cubit.dart';

final class OwnedBusinessesState extends Equatable {
  final List<ListableBusiness> businesses;
  final BusinessViewCubitStatus status;

  const OwnedBusinessesState(
      {this.businesses = const [],
      this.status = BusinessViewCubitStatus.initial});

  OwnedBusinessesState copyWith({
    List<ListableBusiness>? businesses,
    BusinessViewCubitStatus? status,
  }) {
    return OwnedBusinessesState(
      status: status ?? this.status,
      businesses: businesses ?? this.businesses,
    );
  }

  @override
  List<Object> get props => [businesses, status];
}
