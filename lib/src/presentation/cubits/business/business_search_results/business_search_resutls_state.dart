part of 'business_search_resutls_cubit.dart';

final class BusinessSearchResutlsState extends Equatable {
  final List<ListableBusiness> businesses;
  final bool isSearching;

  const BusinessSearchResutlsState(
      {this.businesses = const [], this.isSearching = false});

  BusinessSearchResutlsState copyWith({
    List<ListableBusiness>? businesses,
    bool? isSearching,
  }) {
    return BusinessSearchResutlsState(
      businesses: businesses ?? this.businesses,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [businesses, isSearching];
}
