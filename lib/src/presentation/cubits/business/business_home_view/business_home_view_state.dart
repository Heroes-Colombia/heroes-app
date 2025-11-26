part of 'business_home_view_cubit.dart';

final class BusinessHomeViewState extends Equatable {
  final BusinessViewCubitStatus businessHomeViewState;
  final List<ListableBusiness> featuredBusinesses;
  final List<ListableBusiness> normalBusinesses;
  final List<ListableBusiness> onlineBusinesses;
  final List<BusinessCategory> businessCategories;
  final Map<String, dynamic> businessPromotions; // businessId -> most urgent promotion
  final List<dynamic> featuredPromotions; // Promotions for carousel with pagination

  // Pagination fields for infinite scroll (normal businesses)
  final DocumentSnapshot? lastNormalBusinessDoc; // Cursor for next page
  final bool hasMoreNormalBusinesses; // Are there more businesses to load?
  final bool isLoadingMore; // Loading indicator for pagination

  // Pagination fields for promotions carousel
  final DocumentSnapshot? lastPromotionDoc; // Cursor for next promotion page
  final bool hasMorePromotions; // Are there more promotions to load?
  final bool isLoadingMorePromotions; // Loading indicator for promotions pagination

  const BusinessHomeViewState({
    this.businessHomeViewState = BusinessViewCubitStatus.initial,
    this.featuredBusinesses = const [],
    this.normalBusinesses = const [],
    this.onlineBusinesses = const [],
    this.businessCategories = const [],
    this.businessPromotions = const {}, // NEW
    this.featuredPromotions = const [], // NEW
    // Pagination defaults (normal businesses)
    this.lastNormalBusinessDoc,
    this.hasMoreNormalBusinesses = true,
    this.isLoadingMore = false,
    // Pagination defaults (promotions)
    this.lastPromotionDoc,
    this.hasMorePromotions = true,
    this.isLoadingMorePromotions = false,
  });

  BusinessHomeViewState copyWith({
    BusinessViewCubitStatus? businessHomeViewState,
    List<ListableBusiness>? featuredBusinesses,
    List<ListableBusiness>? normalBusinesses,
    List<ListableBusiness>? onlineBusinesses,
    List<BusinessCategory>? businessCategories,
    Map<String, dynamic>? businessPromotions,
    List<dynamic>? featuredPromotions,
    // Pagination fields (normal businesses)
    DocumentSnapshot? lastNormalBusinessDoc,
    bool? hasMoreNormalBusinesses,
    bool? isLoadingMore,
    // Pagination fields (promotions)
    DocumentSnapshot? lastPromotionDoc,
    bool? hasMorePromotions,
    bool? isLoadingMorePromotions,
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
      // Pagination (normal businesses)
      lastNormalBusinessDoc: lastNormalBusinessDoc ?? this.lastNormalBusinessDoc,
      hasMoreNormalBusinesses: hasMoreNormalBusinesses ?? this.hasMoreNormalBusinesses,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      // Pagination (promotions)
      lastPromotionDoc: lastPromotionDoc ?? this.lastPromotionDoc,
      hasMorePromotions: hasMorePromotions ?? this.hasMorePromotions,
      isLoadingMorePromotions: isLoadingMorePromotions ?? this.isLoadingMorePromotions,
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
        // Pagination (normal businesses)
        lastNormalBusinessDoc,
        hasMoreNormalBusinesses,
        isLoadingMore,
        // Pagination (promotions)
        lastPromotionDoc,
        hasMorePromotions,
        isLoadingMorePromotions,
      ];
}
