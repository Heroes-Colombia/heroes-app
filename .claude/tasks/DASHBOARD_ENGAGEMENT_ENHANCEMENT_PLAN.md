# Dashboard Engagement Enhancement Plan
**Created:** January 20, 2026
**Status:** Ready for Implementation
**Objective:** Optimize user dashboard for maximum engagement, even with few businesses/promotions

---

## Executive Summary

This document outlines a phased approach to enhancing the Heroes Colombia mobile app dashboard to improve user engagement. The enhancements focus on making the app compelling even when there are few businesses or promotions available.

**Key Metrics to Improve:**
- Time spent on app (target: +40%)
- Business detail views per session (target: +60%)
- Favorite additions per week (target: +50%)
- Return rate within 7 days (target: +35%)

---

## Phase 1: Quick Wins (1-2 days)

### Enhancement 1: Promotion Urgency Badges

**Impact:** HIGH | **Effort:** LOW | **Priority:** P0

**Problem:** Users don't see expiration urgency in the home feed, reducing conversion.

**Solution:** Add color-coded urgency badges to vertical business cards showing promotion expiration.

#### Implementation Steps:

**Step 1:** Update Promotion Model with Helper Methods

**File:** `lib/src/domain/models/promotion_model.dart`

Add these helper methods to the `Promotion` class:

```dart
class Promotion extends Equatable {
  // ... existing fields ...

  /// Returns the number of days until promotion expires
  int get daysUntilExpiration {
    if (expiredAt == null) return 999; // No expiration
    final now = DateTime.now();
    final expirationDate = expiredAt!.toDate();
    return expirationDate.difference(now).inDays;
  }

  /// Returns urgency level: critical (0-2 days), urgent (3-7 days), normal (8+ days)
  String get urgencyLevel {
    final days = daysUntilExpiration;
    if (days <= 2) return 'critical';
    if (days <= 7) return 'urgent';
    return 'normal';
  }

  /// Returns human-readable urgency text
  String get urgencyText {
    final days = daysUntilExpiration;
    if (days == 0) return 'Expira hoy';
    if (days == 1) return 'Expira mañana';
    if (days <= 2) return 'Quedan $days días';
    if (days <= 7) return '$days días restantes';
    return '';
  }

  /// Returns urgency badge color
  Color urgencyColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (urgencyLevel) {
      case 'critical':
        return theme.colorScheme.error;
      case 'urgent':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Whether to show urgency badge (only show if < 8 days)
  bool get shouldShowUrgencyBadge => daysUntilExpiration < 8;
}
```

**Step 2:** Update Business Home View Cubit to Fetch Promotions

**File:** `lib/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart`

Add promotion fetching logic:

```dart
// Add to imports
import 'package:heroes_app/src/domain/models/promotion_model.dart';

class BusinessHomeViewCubit extends Cubit<BusinessHomeViewState> {
  // ... existing code ...

  Future<void> getRequiredData() async {
    try {
      emit(state.copyWith(businessHomeViewState: BusinessViewCubitStatus.loading));

      // Existing business fetching code...
      final businessCollection = locator.get<AppConstants>().businessCollection;
      final categoriesCollectionName = locator.get<AppConstants>().businessCategoryCollection;

      // ... existing business queries ...

      // NEW: Fetch promotions for urgency display
      final promotionsCollection = locator.get<AppConstants>().advertisementCollection; // TODO: Change to promotionsCollection after V2 migration
      final rawPromotions = await locator<FirestoreService>()
          .readAllActiveDocuments(promotionsCollection);

      final promotions = rawPromotions
          .map((e) => Promotion.fromJson(e))
          .where((promo) => promo.shouldShowUrgencyBadge) // Only urgent ones
          .toList();

      // Sort by urgency (most urgent first)
      promotions.sort((a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration));

      // Create a map of businessId -> most urgent promotion
      final Map<String, Promotion> businessPromotions = {};
      for (var promo in promotions) {
        if (!businessPromotions.containsKey(promo.businessId)) {
          businessPromotions[promo.businessId] = promo;
        }
      }

      emit(state.copyWith(
        // ... existing fields ...
        businessPromotions: businessPromotions, // NEW FIELD
        businessHomeViewState: BusinessViewCubitStatus.success,
      ));
    } catch (e) {
      log('Error: $e, Function: getRequiredData');
      emit(state.copyWith(businessHomeViewState: BusinessViewCubitStatus.error));
    }
  }
}
```

**Step 3:** Update Business Home View State

**File:** `lib/src/presentation/cubits/business/business_home_view/business_home_view_state.dart`

```dart
// Add to imports
import 'package:heroes_app/src/domain/models/promotion_model.dart';

final class BusinessHomeViewState extends Equatable {
  final List<ListableBusiness> featuredBusinesses;
  final List<ListableBusiness> normalBusinesses;
  final List<BusinessCategory> businessCategories;
  final BusinessViewCubitStatus businessHomeViewState;
  final Map<String, Promotion> businessPromotions; // NEW FIELD

  const BusinessHomeViewState({
    this.featuredBusinesses = const [],
    this.normalBusinesses = const [],
    this.businessCategories = const [],
    this.businessHomeViewState = BusinessViewCubitStatus.initial,
    this.businessPromotions = const {}, // NEW DEFAULT
  });

  BusinessHomeViewState copyWith({
    List<ListableBusiness>? featuredBusinesses,
    List<ListableBusiness>? normalBusinesses,
    List<BusinessCategory>? businessCategories,
    BusinessViewCubitStatus? businessHomeViewState,
    Map<String, Promotion>? businessPromotions, // NEW PARAM
  }) {
    return BusinessHomeViewState(
      featuredBusinesses: featuredBusinesses ?? this.featuredBusinesses,
      normalBusinesses: normalBusinesses ?? this.normalBusinesses,
      businessCategories: businessCategories ?? this.businessCategories,
      businessHomeViewState: businessHomeViewState ?? this.businessHomeViewState,
      businessPromotions: businessPromotions ?? this.businessPromotions, // NEW COPY
    );
  }

  @override
  List<Object> get props => [
        featuredBusinesses,
        normalBusinesses,
        businessCategories,
        businessHomeViewState,
        businessPromotions, // NEW PROP
      ];
}
```

**Step 4:** Update Vertical Card Widget with Urgency Badge

**File:** `lib/src/presentation/widgets/vertical_card_widget.dart`

Add optional promotion parameter and urgency badge:

```dart
class VerticalCard extends StatelessWidget {
  final String title;
  final String image;
  final String id;
  final BusinessCategory category;
  final Function callback;
  final Promotion? urgentPromotion; // NEW PARAM

  const VerticalCard({
    super.key,
    required this.title,
    required this.image,
    required this.id,
    required this.category,
    required this.callback,
    this.urgentPromotion, // NEW
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => callback(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Left side: Business info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.network(
                        category.imageUrl,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  // NEW: Urgency Badge
                  if (urgentPromotion != null && urgentPromotion!.shouldShowUrgencyBadge) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: urgentPromotion!.urgencyColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            urgentPromotion!.urgencyText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right side: Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 80,
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.business,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5:** Update Search View to Pass Promotions to Vertical Cards

**File:** `lib/src/presentation/pages/dashboard/pages/search/search_view.dart`

Update `verticalList` method:

```dart
SliverList verticalList(List<ListableBusiness> businesses, Map<String, Promotion> businessPromotions) {
  return SliverList.separated(
    itemBuilder: (context, index) {
      final business = businesses[index];
      final urgentPromo = businessPromotions[business.id]; // Get urgent promotion for this business

      return VerticalCard(
        image: business.featuredImage,
        title: business.name,
        id: business.id,
        category: business.category,
        urgentPromotion: urgentPromo, // NEW: Pass urgent promotion
        callback: () {
          AutoRouter.of(context).push(
            BusinessDetailsView(businessId: business.id),
          );
        },
      );
    },
    separatorBuilder: (context, index) => const Divider(height: 1),
    itemCount: businesses.length,
  );
}

// Update successView to pass businessPromotions to verticalList
CustomScrollView successView(context, texts, BusinessHomeViewState state) {
  var theme = Theme.of(context);
  return CustomScrollView(
    slivers: [
      // ... existing slivers ...
      verticalList(state.normalBusinesses, state.businessPromotions), // Pass promotions map
      const SliverToBoxAdapter(child: SizedBox(height: 16))
    ],
  );
}
```

**Testing:**
1. ✅ Launch app and scroll through home feed
2. ✅ Verify urgency badges appear on businesses with expiring promotions
3. ✅ Verify color coding: red for 0-2 days, orange for 3-7 days
4. ✅ Tap business to verify promotions exist in detail view
5. ✅ Test edge cases: no promotions, all expired, future expirations

---

### Enhancement 2: Featured Promotions Carousel

**Impact:** HIGH | **Effort:** MEDIUM | **Priority:** P0

**Problem:** Promotions are buried in business details; users don't discover top deals.

**Solution:** Add a dedicated "Ofertas Destacadas" carousel section showing top 5-10 expiring promotions.

#### Implementation Steps:

**Step 1:** Update BusinessHomeViewState to Include Featured Promotions List

```dart
final class BusinessHomeViewState extends Equatable {
  // ... existing fields ...
  final List<Promotion> featuredPromotions; // NEW

  const BusinessHomeViewState({
    // ... existing defaults ...
    this.featuredPromotions = const [],
  });

  // Update copyWith and props accordingly
}
```

**Step 2:** Update Cubit to Fetch Featured Promotions

```dart
Future<void> getRequiredData() async {
  // ... existing code ...

  // Fetch all active promotions
  final rawPromotions = await locator<FirestoreService>()
      .readAllActiveDocuments(promotionsCollection);

  final allPromotions = rawPromotions
      .map((e) => Promotion.fromJson(e))
      .where((promo) => promo.status == 'active' && !promo.isExpired)
      .toList();

  // Sort by urgency and percentage (most urgent + highest discount first)
  allPromotions.sort((a, b) {
    final urgencyCompare = a.daysUntilExpiration.compareTo(b.daysUntilExpiration);
    if (urgencyCompare != 0) return urgencyCompare;
    return b.percentage.compareTo(a.percentage); // Higher discount first
  });

  // Take top 10 featured promotions
  final featuredPromotions = allPromotions.take(10).toList();

  emit(state.copyWith(
    // ... existing fields ...
    featuredPromotions: featuredPromotions,
  ));
}
```

**Step 3:** Create Promotion Card Widget

**File:** `lib/src/presentation/widgets/promotion_card_widget.dart` (NEW FILE)

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final double width;
  final double imageHeight;

  const PromotionCard({
    super.key,
    required this.promotion,
    this.width = 160,
    this.imageHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(
          PromotionDetailsView(
            promotion: promotion,
            promotionId: promotion.documentId,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with discount badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    promotion.featuredImage,
                    width: width,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: width,
                      height: imageHeight,
                      color: theme.colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.local_offer,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Discount badge (top left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${promotion.percentage}% OFF',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Urgency badge (bottom right)
                if (promotion.shouldShowUrgencyBadge)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: promotion.urgencyColor(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            promotion.urgencyText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Promotion details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promotion.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 4:** Add Featured Promotions Section to Search View

**File:** `lib/src/presentation/pages/dashboard/pages/search/search_view.dart`

```dart
// Add new widget method
Widget featuredPromotionsList(List<Promotion> promotions) {
  if (promotions.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

  return SliverToBoxAdapter(
    child: Container(
      height: 220, // Image (120) + padding (8) + text (92)
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        padding: const EdgeInsets.all(0.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return PromotionCard(
            promotion: promotions[index],
            width: 160,
            imageHeight: 120,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: promotions.length,
      ),
    ),
  );
}

// Update successView to include featured promotions
CustomScrollView successView(context, texts, BusinessHomeViewState state) {
  var theme = Theme.of(context);
  return CustomScrollView(
    slivers: [
      SliverAppBar(...),
      logo(theme, texts),
      singleTitle(theme, texts["categories"]),
      categoriesList(state.businessCategories),

      // NEW: Featured Promotions Section
      if (state.featuredPromotions.isNotEmpty) ...[
        doubleTitle(theme, "Ofertas Destacadas", "Ver todas", () {
          // TODO: Navigate to all promotions view
        }),
        featuredPromotionsList(state.featuredPromotions),
      ],

      singleTitle(theme, texts["nearPromotions"]),
      mapPreview(theme, context),
      doubleTitle(theme, texts["featuredBusiness"], texts["seeAll"], () {
        AutoRouter.of(context).push(AllBusinessView(initialCategoryId: null));
      }),
      horizontalList(state.featuredBusinesses),
      doubleTitle(theme, texts["business"], texts["seeAll"], () {
        AutoRouter.of(context).push(AllBusinessView(initialCategoryId: null));
      }),
      verticalList(state.normalBusinesses, state.businessPromotions),
      const SliverToBoxAdapter(child: SizedBox(height: 16))
    ],
  );
}
```

**Testing:**
1. ✅ Launch app and verify "Ofertas Destacadas" section appears
2. ✅ Verify promotions are sorted by urgency + discount
3. ✅ Tap promotion card to navigate to details
4. ✅ Verify urgency and discount badges display correctly
5. ✅ Test with no promotions (section should hide)

---

### Enhancement 3: Smart Empty States with Recommendations

**Impact:** MEDIUM | **Effort:** LOW | **Priority:** P1

**Problem:** When users have no favorites, they see empty screens with no guidance.

**Solution:** Show personalized recommendations instead of empty favorites.

#### Implementation Steps:

**Step 1:** Update FavouriteBusinessesCubit to Fetch Recommendations

**File:** `lib/src/presentation/cubits/favourite_businesses/favourite_businesses_cubit.dart`

```dart
class FavouriteBusinessesCubit extends Cubit<FavouriteBusinessesState> {
  // ... existing code ...

  Future<void> getFavouriteBusinesses() async {
    try {
      final user = await locator.get<AuthService>().getUser();
      final favouriteBusinesses = user!.favouriteBusinesses;

      // If user has favorites, fetch them normally
      if (favouriteBusinesses.isNotEmpty) {
        // ... existing fetching logic ...
        return;
      }

      // NEW: If no favorites, fetch "recommended for you" businesses
      final collectionName = locator.get<AppConstants>().businessCollection;
      final categoriesCollectionName = locator.get<AppConstants>().businessCategoryCollection;

      final rawBusinessCategories = await locator<FirestoreService>()
          .readAllActiveDocuments(categoriesCollectionName);

      // Fetch featured businesses + top-rated businesses as recommendations
      final rawBusinesses = await locator<FirestoreService>()
          .readAllActiveDocuments(collectionName);

      final businesses = rawBusinesses
          .map((e) => ListableBusiness.fromJson(e))
          .where((b) => b.status == 'active' && b.featured == true)
          .take(10) // Show top 10 featured as recommendations
          .toList();

      final categories = rawBusinessCategories
          .map((e) => BusinessCategory.fromJson(e))
          .toList();

      for (var business in businesses) {
        business.category = categories.firstWhere(
          (element) => element.id == business.categoryIds.first,
        );
      }

      emit(state.copyWith(
        status: BusinessViewCubitStatus.success,
        businesses: businesses,
        categories: categories,
        isRecommendations: true, // NEW FLAG
      ));
    } catch (e) {
      emit(state.copyWith(status: BusinessViewCubitStatus.error));
      log('Error: $e, Function: getFavouriteBusinesses');
    }
  }

  // Similar logic for promotions
  Future<void> getFavouritePromotions() async {
    try {
      final user = await locator.get<AuthService>().getUser();
      final favouritePromotions = user!.favouritePromotions;

      if (favouritePromotions.isNotEmpty) {
        // ... existing logic ...
        return;
      }

      // NEW: Fetch top expiring promotions as recommendations
      final promotionsCollectionName = locator.get<AppConstants>().advertisementCollection;
      final rawPromotions = await locator<FirestoreService>()
          .readAllActiveDocuments(promotionsCollectionName);

      final promotions = rawPromotions
          .map((e) => Promotion.fromJson(e))
          .where((p) => p.status == 'active' && !p.isExpired)
          .toList();

      // Sort by urgency (expiring soon first)
      promotions.sort((a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration));

      emit(state.copyWith(
        promotionsStatus: BusinessViewCubitStatus.success,
        promotions: promotions.take(10).toList(),
        isPromotionRecommendations: true, // NEW FLAG
      ));
    } catch (e) {
      emit(state.copyWith(promotionsStatus: BusinessViewCubitStatus.error));
      log('Error: $e, Function: getFavouritePromotions');
    }
  }
}
```

**Step 2:** Update FavouriteBusinessesState with Recommendation Flags

**File:** `lib/src/presentation/cubits/favourite_businesses/favourite_businesses_state.dart`

```dart
final class FavouriteBusinessesState extends Equatable {
  final List<ListableBusiness> businesses;
  final List<dynamic> promotions;
  final List<BusinessCategory> categories;
  final BusinessViewCubitStatus status;
  final BusinessViewCubitStatus promotionsStatus;
  final bool isRecommendations; // NEW
  final bool isPromotionRecommendations; // NEW

  const FavouriteBusinessesState({
    this.businesses = const [],
    this.promotions = const [],
    this.categories = const [],
    this.status = BusinessViewCubitStatus.initial,
    this.promotionsStatus = BusinessViewCubitStatus.initial,
    this.isRecommendations = false,
    this.isPromotionRecommendations = false,
  });

  // Update copyWith and props
}
```

**Step 3:** Update Favorites View to Show Recommendations Banner

**File:** `lib/src/presentation/pages/dashboard/pages/favorites_view.dart`

```dart
Widget _buildBusinessesList(
  List<ListableBusiness> businesses,
  ThemeData theme,
  Map<String, String>? texts,
  bool isRecommendations, // NEW PARAM
) {
  if (businesses.isEmpty) {
    // Keep existing empty state
  }

  return Column(
    children: [
      // NEW: Recommendations banner
      if (isRecommendations)
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No tienes favoritos aún. Estas son nuestras recomendaciones para ti:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      // Existing ListView.separated code
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          // ... rest of existing code
        ),
      ),
    ],
  );
}

// Update _buildBusinessesTab to pass isRecommendations flag
Widget _buildBusinessesTab(...) {
  return RefreshIndicator(
    onRefresh: () => getFavouriteBusinesses(context),
    child: Builder(
      builder: (context) {
        switch (state.status) {
          case BusinessViewCubitStatus.success:
            return _buildBusinessesList(
              state.businesses,
              theme,
              texts,
              state.isRecommendations, // Pass flag
            );
          // ... other cases
        }
      },
    ),
  );
}
```

**Testing:**
1. ✅ Create new user account with no favorites
2. ✅ Navigate to Favorites tab
3. ✅ Verify recommendation banner appears
4. ✅ Verify recommended businesses display (featured ones)
5. ✅ Favorite a business and verify it replaces recommendations

---

## Phase 2: Medium Impact Enhancements (3-4 days)

### Enhancement 4: Business Star Ratings on Cards

**Impact:** HIGH | **Effort:** MEDIUM | **Priority:** P1

**Solution:** Add average rating display to horizontal and vertical business cards.

#### Database Changes Required:

**Add to Business Model:**
```dart
class ListableBusiness {
  // ... existing fields ...
  final double averageRating; // NEW (default: 0.0)
  final int reviewCount; // NEW (default: 0)
}
```

**Update Firestore:**
- Run migration to calculate `average_rating` and `review_count` for all businesses
- Add Cloud Function to update these fields when reviews are added/updated

#### Widget Updates:

**Horizontal Card:**
```dart
// Add below business name
Row(
  children: [
    Icon(Icons.star, size: 14, color: Colors.amber),
    const SizedBox(width: 2),
    Text(
      averageRating.toStringAsFixed(1),
      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
    ),
    const SizedBox(width: 4),
    Text(
      '($reviewCount)',
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
  ],
)
```

**Vertical Card:** (Same pattern)

---

### Enhancement 5: Trending Businesses Section

**Impact:** MEDIUM | **Effort:** MEDIUM | **Priority:** P2

**Solution:** Add "Trending Now" section showing most viewed businesses this week.

#### Implementation:

**Step 1:** Query Analytics Events

```dart
// In BusinessHomeViewCubit
Future<List<String>> _getTrendingBusinessIds() async {
  final now = DateTime.now();
  final oneWeekAgo = now.subtract(const Duration(days: 7));

  final analyticsCollection = 'analytics_events';
  final snapshot = await locator<FirestoreService>().firestore
      .collection(analyticsCollection)
      .where('event_type', isEqualTo: 'view')
      .where('entity_type', isEqualTo: 'business')
      .where('created_at', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
      .get();

  // Count views per business
  final Map<String, int> viewCounts = {};
  for (var doc in snapshot.docs) {
    final businessId = doc.data()['entity_id'] as String;
    viewCounts[businessId] = (viewCounts[businessId] ?? 0) + 1;
  }

  // Sort by view count and return top 10
  final sorted = viewCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(10).map((e) => e.key).toList();
}
```

**Step 2:** Fetch Trending Businesses

```dart
final trendingIds = await _getTrendingBusinessIds();
final rawTrending = await locator<FirestoreService>()
    .readActiveDocumentsByDocumentIDs(businessCollection, trendingIds);

final trendingBusinesses = rawTrending
    .map((e) => ListableBusiness.fromJson(e))
    .toList();
```

**Step 3:** Add Trending Section to Home Feed

```dart
// In search_view.dart successView
if (state.trendingBusinesses.isNotEmpty) ...[
  doubleTitle(theme, "Tendencia esta semana", "Ver todas", () {}),
  horizontalList(state.trendingBusinesses),
],
```

---

### Enhancement 6: Nearby Businesses Widget

**Impact:** MEDIUM | **Effort:** LOW | **Priority:** P2

**Solution:** Add "Cerca de ti" section using existing geolocation.

#### Implementation:

```dart
// In BusinessHomeViewCubit
Future<List<ListableBusiness>> _getNearbyBusinesses() async {
  final userLocation = await locator<AppMethods>().getUserLocation();

  if (userLocation == null) return [];

  final userGeoPoint = GeoPoint(
    userLocation.latitude!,
    userLocation.longitude!,
  );

  final businessCollection = locator.get<AppConstants>().businessCollection;
  final stream = locator.get<FirestoreService>()
      .getDocumentsNearPosition(userGeoPoint, 5.0, businessCollection); // 5km radius

  // Convert stream to list (take first emit)
  final docs = await stream.first;

  return docs
      .map((doc) => ListableBusiness.fromJson(doc.data() as Map<String, dynamic>))
      .take(10)
      .toList();
}
```

---

## Phase 3: Nice-to-Have Features (1 week)

### Enhancement 7: Business Follow/Subscribe

**Impact:** HIGH | **Effort:** HIGH | **Priority:** P3

**Solution:** Allow users to subscribe to business updates.

### Enhancement 8: Review Helpfulness Votes

**Impact:** LOW | **Effort:** MEDIUM | **Priority:** P4

**Solution:** Add thumbs up/down to reviews.

### Enhancement 9: Promotion Share/Referral

**Impact:** MEDIUM | **Effort:** MEDIUM | **Priority:** P3

**Solution:** Share promotions with friends via deep links.

---

## Analytics Integration

**Track all new features:**

```dart
// Urgency badge view
analytics.trackDashboardImpression(
  entityType: 'urgency_badge',
  entityId: promotionId,
  screen: 'home_feed',
);

// Featured promotion carousel impression
analytics.trackDashboardImpression(
  entityType: 'featured_promotion',
  entityId: promotionId,
  screen: 'featured_carousel',
);

// Recommendations shown
analytics.trackEvent(
  eventType: 'recommendations_shown',
  metadata: {
    'count': businesses.length,
    'type': 'businesses',
  },
);
```

---

## Testing Checklist

### Phase 1 Testing:
- [ ] Urgency badges appear correctly on home feed
- [ ] Featured promotions carousel loads and scrolls smoothly
- [ ] Smart recommendations show when no favorites exist
- [ ] Urgency colors match urgency levels (red/orange/primary)
- [ ] All navigation links work correctly
- [ ] Analytics events fire for all interactions

### Phase 2 Testing:
- [ ] Star ratings display correctly on all card types
- [ ] Trending section shows most viewed businesses
- [ ] Nearby businesses section shows location-relevant results
- [ ] Empty states handled gracefully

### Phase 3 Testing:
- [ ] Follow/subscribe notifications work
- [ ] Review votes persist correctly
- [ ] Share links generate and work correctly

---

## Performance Considerations

1. **Caching:** Cache featured promotions for 5 minutes to reduce Firestore reads
2. **Lazy Loading:** Only load recommendations when favorites tab is active
3. **Image Optimization:** Use cached network images for promotion cards
4. **Analytics Batching:** Batch impression events every 30 seconds

---

## Migration Notes

**Post-V2 Migration:**
- Change `advertisementCollection` to `promotionsCollection` throughout
- Update promotion queries to use `promotions` collection
- Verify `location_ids` field is handled correctly

---

## Success Metrics

**Week 1 Post-Launch:**
- Time on app: +20%
- Business views per session: +30%
- Favorite additions: +25%

**Month 1 Post-Launch:**
- Time on app: +40%
- Business views per session: +60%
- Favorite additions: +50%
- Return rate within 7 days: +35%

---

**Next Steps:**
1. Review and approve this plan
2. Implement Phase 1 enhancements (Priority P0)
3. Test thoroughly with real data
4. Monitor analytics after deployment
5. Iterate to Phase 2 based on user feedback

**Questions?** Refer to the exploration report for detailed file locations and current implementation details.
