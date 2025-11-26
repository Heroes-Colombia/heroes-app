part of 'all_business_cubit.dart';

final class AllBusinessState extends Equatable {
  final List<ListableBusiness> businesses;
  final BusinessViewCubitStatus status;
  final String selectedCategoryId;
  final List<BusinessCategory> categories;
  final BusinessFilter filter;

  const AllBusinessState({
    this.businesses = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.selectedCategoryId = '',
    this.categories = const [],
    this.filter = const BusinessFilter(),
  });

  AllBusinessState copyWith({
    List<ListableBusiness>? businesses,
    BusinessViewCubitStatus? status,
    String? selectedCategoryId,
    List<BusinessCategory>? categories,
    BusinessFilter? filter,
  }) {
    return AllBusinessState(
      status: status ?? this.status,
      businesses: businesses ?? this.businesses,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [
        businesses,
        status,
        selectedCategoryId,
        categories,
        filter,
      ];
}
