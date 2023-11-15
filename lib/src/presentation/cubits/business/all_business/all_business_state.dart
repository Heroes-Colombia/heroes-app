part of 'all_business_cubit.dart';

final class AllBusinessState extends Equatable {
  final List<ListableBusiness> businesses;
  final BusinessViewCubitStatus status;

  const AllBusinessState(
      {this.businesses = const [],
      this.status = BusinessViewCubitStatus.initial});

  AllBusinessState copyWith({
    List<ListableBusiness>? businesses,
    BusinessViewCubitStatus? status,
  }) {
    return AllBusinessState(
      status: status ?? this.status,
      businesses: businesses ?? this.businesses,
    );
  }

  @override
  List<Object> get props => [businesses, status];
}
