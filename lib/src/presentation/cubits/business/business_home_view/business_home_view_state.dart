part of 'business_home_view_cubit.dart';

final class BusinessHomeViewState extends Equatable {
  final BusinessViewCubitStatus businessHomeViewState;
  final List<ListableBusiness> featuredBusinesses;
  final List<ListableBusiness> normalBusinesses;
  final List<ListableBusiness> onlineBusinesses;
  final List<BusinessCategory> businessCategories;
  final Map<String, dynamic> businessPromotions; // businessId -> most urgent promotion
  final List<dynamic> featuredPromotions; // Top featured promotions for carousel

  const BusinessHomeViewState({
    this.businessHomeViewState = BusinessViewCubitStatus.initial,
    this.featuredBusinesses = const [],
    this.normalBusinesses = const [],
    this.onlineBusinesses = const [],
    this.businessCategories = const [],
    this.businessPromotions = const {}, // NEW
    this.featuredPromotions = const [], // NEW
  });

  BusinessHomeViewState copyWith({
    BusinessViewCubitStatus? businessHomeViewState,
    List<ListableBusiness>? featuredBusinesses,
    List<ListableBusiness>? normalBusinesses,
    List<ListableBusiness>? onlineBusinesses,
    List<BusinessCategory>? businessCategories,
    Map<String, dynamic>? businessPromotions,
    List<dynamic>? featuredPromotions,
  }) {
    return BusinessHomeViewState(
      businessHomeViewState:
          businessHomeViewState ?? this.businessHomeViewState,
      featuredBusinesses: featuredBusinesses ?? this.featuredBusinesses,
      normalBusinesses: normalBusinesses ?? this.normalBusinesses,
      onlineBusinesses: onlineBusinesses ?? this.onlineBusinesses,
      businessCategories: businessCategories ?? this.businessCategories,
      businessPromotions: businessPromotions ?? this.businessPromotions,
      featuredPromotions: featuredPromotions ?? this.featuredPromotions,
    );
  }

  @override
  List<dynamic> get props => [
        businessHomeViewState,
        featuredBusinesses,
        normalBusinesses,
        onlineBusinesses,
        businessCategories,
        businessPromotions,
        featuredPromotions,
      ];
}
