part of 'business_search_resutls_cubit.dart';

final class BusinessSearchResutlsState extends Equatable {
  final List<ListableBusiness> businesses;
  final List<Promotion> promotions;
  final bool isSearching;

  const BusinessSearchResutlsState({
    this.businesses = const [],
    this.promotions = const [],
    this.isSearching = false,
  });

  BusinessSearchResutlsState copyWith({
    List<ListableBusiness>? businesses,
    List<Promotion>? promotions,
    bool? isSearching,
  }) {
    return BusinessSearchResutlsState(
      businesses: businesses ?? this.businesses,
      promotions: promotions ?? this.promotions,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [businesses, promotions, isSearching];
}
