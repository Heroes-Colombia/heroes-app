# Phase 1: Foundation - Implementation Guide
## Performance Optimization & Visual Polish

**Timeline**: Weeks 1-4 (February 2025)
**Status**: 🚀 In Progress
**Developer**: Solo
**Estimated Effort**: 9.5 days total

---

## Overview

Phase 1 focuses on two critical areas:
1. **Performance & Scalability** (Week 1-2) - Fix issues that prevent scaling to 100+ businesses
2. **Visual Polish** (Week 3-4) - Match Rappi's UI quality

**Why This First?**
- Current app doesn't scale (loads ALL businesses at once)
- Firestore costs will explode with growth
- Visual polish creates immediate user delight
- Foundation for all future features

---

## Week 1-2: Performance & Data Optimization

### Task 1: Implement Pagination (2 days)

**Problem**: Current implementation loads ALL businesses at once:
```dart
// Current: business_home_view_cubit.dart:63-69
final normalBusinessRaw = await firestoreService
    .readActiveDocumentsByCondition(
      businessCollection,
      "featured",
      false,
      5,  // ❌ Hardcoded limit, no pagination
    );
```

**Solution**: Infinite scroll with cursor-based pagination

---

#### Step 1.1: Update Business Home View State (30 min)

**File**: `lib/src/presentation/cubits/business/business_home_view/business_home_view_state.dart`

Add pagination fields:

```dart
part of 'business_home_view_cubit.dart';

class BusinessHomeViewState extends Equatable {
  final BusinessViewCubitStatus businessHomeViewState;
  final List<ListableBusiness> featuredBusinesses;
  final List<ListableBusiness> normalBusinesses;
  final List<ListableBusiness> onlineBusinesses;
  final List<BusinessCategory> businessCategories;
  final Map<String, Promotion> businessPromotions;
  final List<Promotion> featuredPromotions;

  // ===== NEW: Pagination fields =====
  final DocumentSnapshot? lastNormalBusinessDoc;      // Cursor for pagination
  final bool hasMoreNormalBusinesses;                 // Are there more to load?
  final bool isLoadingMore;                           // Loading indicator

  const BusinessHomeViewState({
    this.businessHomeViewState = BusinessViewCubitStatus.initial,
    this.featuredBusinesses = const [],
    this.normalBusinesses = const [],
    this.onlineBusinesses = const [],
    this.businessCategories = const [],
    this.businessPromotions = const {},
    this.featuredPromotions = const [],
    // NEW
    this.lastNormalBusinessDoc,
    this.hasMoreNormalBusinesses = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        businessHomeViewState,
        featuredBusinesses,
        normalBusinesses,
        onlineBusinesses,
        businessCategories,
        businessPromotions,
        featuredPromotions,
        // NEW
        lastNormalBusinessDoc,
        hasMoreNormalBusinesses,
        isLoadingMore,
      ];

  BusinessHomeViewState copyWith({
    BusinessViewCubitStatus? businessHomeViewState,
    List<ListableBusiness>? featuredBusinesses,
    List<ListableBusiness>? normalBusinesses,
    List<ListableBusiness>? onlineBusinesses,
    List<BusinessCategory>? businessCategories,
    Map<String, Promotion>? businessPromotions,
    List<Promotion>? featuredPromotions,
    // NEW
    DocumentSnapshot? lastNormalBusinessDoc,
    bool? hasMoreNormalBusinesses,
    bool? isLoadingMore,
  }) {
    return BusinessHomeViewState(
      businessHomeViewState: businessHomeViewState ?? this.businessHomeViewState,
      featuredBusinesses: featuredBusinesses ?? this.featuredBusinesses,
      normalBusinesses: normalBusinesses ?? this.normalBusinesses,
      onlineBusinesses: onlineBusinesses ?? this.onlineBusinesses,
      businessCategories: businessCategories ?? this.businessCategories,
      businessPromotions: businessPromotions ?? this.businessPromotions,
      featuredPromotions: featuredPromotions ?? this.featuredPromotions,
      // NEW
      lastNormalBusinessDoc: lastNormalBusinessDoc ?? this.lastNormalBusinessDoc,
      hasMoreNormalBusinesses: hasMoreNormalBusinesses ?? this.hasMoreNormalBusinesses,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
```

---

#### Step 1.2: Add Pagination Support to Firestore Service (45 min)

**File**: `lib/src/domain/repositories/firestore_service.dart`

Add new method for paginated queries:

```dart
// Add to FirestoreService class

/// Read active documents with pagination support
Future<Map<String, dynamic>> readActiveDocumentsWithPagination(
  String collection, {
  required String orderByField,
  required int limit,
  DocumentSnapshot? startAfterDocument,
  String? whereField,
  dynamic whereValue,
}) async {
  try {
    Query query = _firestore
        .collection(collection)
        .where('status', isEqualTo: 'active');

    // Add optional where clause
    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }

    // Order by field (required for pagination)
    query = query.orderBy(orderByField, descending: true);

    // Pagination: start after last document
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    // Limit results
    query = query.limit(limit);

    final querySnapshot = await query.get();

    // Extract documents and last document
    final documents = querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();

    final lastDoc = querySnapshot.docs.isNotEmpty
        ? querySnapshot.docs.last
        : null;

    return {
      'documents': documents,
      'lastDocument': lastDoc,
      'hasMore': querySnapshot.docs.length == limit, // If we got full limit, there might be more
    };
  } catch (e) {
    log('Error reading paginated documents: $e');
    rethrow;
  }
}
```

---

#### Step 1.3: Update Business Home View Cubit (1 hour)

**File**: `lib/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart`

Replace the current `getRequiredData()` method and add pagination:

```dart
class BusinessHomeViewCubit extends Cubit<BusinessHomeViewState> {
  BusinessHomeViewCubit() : super(const BusinessHomeViewState());

  final firestoreService = GetIt.instance.get<FirestoreService>();
  final authService = GetIt.instance.get<AuthService>();
  final locator = GetIt.instance;

  // Constants
  static const int BUSINESSES_PER_PAGE = 10;

  //This method is used to get the initial state of BusinessHomeViewCubit
  void getInitial() {
    emit(
      const BusinessHomeViewState(
        businessHomeViewState: BusinessViewCubitStatus.initial,
      ),
    );

    updateUserLastLocation();
  }

  //This method is used to get the loading state of BusinessHomeViewCubit
  void getRequiredData() async {
    //We emit the loading state
    emit(
      const BusinessHomeViewState(
        businessHomeViewState: BusinessViewCubitStatus.loading,
      ),
    );

    try {
      //We get the business collection
      final businessCollection = locator.get<AppConstants>().businessCollection;

      //We get the featured businesses from firestore (NO PAGINATION - always small set)
      final featuredBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveDocumentsByCondition(
            businessCollection,
            "featured",
            true,
            5,
          );

      //We convert the raw data to a list of business
      final featuredBusiness =
          featuredBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      // ===== NEW: Get normal businesses with pagination =====
      final normalBusinessResult = await locator
          .get<FirestoreService>()
          .readActiveDocumentsWithPagination(
            businessCollection,
            orderByField: 'created_at',
            limit: BUSINESSES_PER_PAGE,
            whereField: 'featured',
            whereValue: false,
          );

      final normalBusiness = (normalBusinessResult['documents'] as List)
          .map((e) => ListableBusiness.fromJson(e))
          .toList();

      final lastNormalDoc = normalBusinessResult['lastDocument'] as DocumentSnapshot?;
      final hasMoreNormal = normalBusinessResult['hasMore'] as bool;

      //We get the online businesses from firestore (NO PAGINATION - usually small set)
      final onlineBusinessRaw = await locator
          .get<FirestoreService>()
          .readActiveDocumentsByCondition(
            businessCollection,
            "type",
            "online",
            5,
          );

      //we convert the raw data to a list of business
      final onlineBusiness =
          onlineBusinessRaw.map((e) => ListableBusiness.fromJson(e)).toList();

      //Then we get the business categories from firestore
      final businessCategoriesRaw = await locator
          .get<FirestoreService>()
          .readAllActiveDocuments(
            locator.get<AppConstants>().businessCategoryCollection,
          );

      //We convert the raw data to a list of business categories
      final businessCategories =
          businessCategoriesRaw
              .map((e) => BusinessCategory.fromJson(e))
              .toList();

      //Then we add the first category data to the list of business categories
      for (var business in normalBusiness) {
        business.category = businessCategories.firstWhere(
          (category) => category.id == business.categoryIds.first,
        );
      }

      for (var business in featuredBusiness) {
        business.category = businessCategories.firstWhere(
          (category) => category.id == business.categoryIds.first,
        );
      }

      for (var business in onlineBusiness) {
        business.category = businessCategories.firstWhere(
          (category) => category.id == business.categoryIds.first,
        );
      }

      // Fetch promotions for urgency badges and featured carousel
      final promotionsCollection = locator.get<AppConstants>().advertisementCollection;
      final rawPromotions = await locator<FirestoreService>()
          .readAllActiveDocuments(promotionsCollection);

      final allPromotions = rawPromotions
          .map((e) => Promotion.fromJson(e))
          .where((promo) => promo.status == PromotionStatus.active && !promo.isExpired)
          .toList();

      // Create map of businessId -> most urgent promotion (for badges)
      final Map<String, Promotion> businessPromotions = {};
      final urgentPromotions = allPromotions
          .where((promo) => promo.shouldShowUrgencyBadge)
          .toList();

      // Sort by urgency (most urgent first)
      urgentPromotions.sort((a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration));

      for (var promo in urgentPromotions) {
        if (!businessPromotions.containsKey(promo.businessId)) {
          businessPromotions[promo.businessId] = promo;
        }
      }

      // Create featured promotions list (top 10 by urgency + discount)
      final featuredPromotionsList = List<Promotion>.from(allPromotions);
      featuredPromotionsList.sort((a, b) {
        final urgencyCompare = a.daysUntilExpiration.compareTo(b.daysUntilExpiration);
        if (urgencyCompare != 0) return urgencyCompare;
        return b.percentage.compareTo(a.percentage); // Higher discount first
      });

      emit(
        state.copyWith(
          businessHomeViewState: BusinessViewCubitStatus.success,
          featuredBusinesses: featuredBusiness,
          normalBusinesses: normalBusiness,
          onlineBusinesses: onlineBusiness,
          businessCategories: businessCategories,
          businessPromotions: businessPromotions,
          featuredPromotions: featuredPromotionsList.take(10).toList(),
          // NEW: Pagination state
          lastNormalBusinessDoc: lastNormalDoc,
          hasMoreNormalBusinesses: hasMoreNormal,
        ),
      );
    } catch (e) {
      log(
        'Error: $e, Function: getRequiredData, File: business_home_view_cubit.dart',
      );
      emit(
        state.copyWith(businessHomeViewState: BusinessViewCubitStatus.error),
      );
    }
  }

  // ===== NEW: Load more businesses (infinite scroll) =====
  void loadMoreBusinesses() async {
    // Don't load if already loading or no more data
    if (state.isLoadingMore || !state.hasMoreNormalBusinesses) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final businessCollection = locator.get<AppConstants>().businessCollection;

      final result = await locator
          .get<FirestoreService>()
          .readActiveDocumentsWithPagination(
            businessCollection,
            orderByField: 'created_at',
            limit: BUSINESSES_PER_PAGE,
            whereField: 'featured',
            whereValue: false,
            startAfterDocument: state.lastNormalBusinessDoc,
          );

      final newBusinesses = (result['documents'] as List)
          .map((e) => ListableBusiness.fromJson(e))
          .toList();

      final lastDoc = result['lastDocument'] as DocumentSnapshot?;
      final hasMore = result['hasMore'] as bool;

      // Add categories to new businesses
      for (var business in newBusinesses) {
        business.category = state.businessCategories.firstWhere(
          (category) => category.id == business.categoryIds.first,
        );
      }

      // Append to existing list
      final updatedBusinesses = [...state.normalBusinesses, ...newBusinesses];

      emit(
        state.copyWith(
          normalBusinesses: updatedBusinesses,
          lastNormalBusinessDoc: lastDoc,
          hasMoreNormalBusinesses: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      log('Error loading more businesses: $e');
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  //This method is used to update the user´s last location in the database for notifications based on location
  void updateUserLastLocation() async {
    final userLocation = await locator.get<AppMethods>().getUserLocation();
    if (userLocation == null) return;

    //Then we get the geoHash from the coordinates
    GeoFirePoint currentPosition = GeoFirePoint(
      GeoPoint(userLocation.latitude!, userLocation.longitude!),
    );

    //Then, we add the address and the location to the business
    final currentUserId = authService.getUserId();
    firestoreService.editDocumentById(
      locator.get<AppConstants>().usersCollection,
      currentUserId,
      "uid",
      {"geo_hash": currentPosition.data},
    );
  }
}
```

---

#### Step 1.4: Update Search View UI with Infinite Scroll (45 min)

**File**: `lib/src/presentation/pages/dashboard/pages/search/search_view.dart`

Replace the `verticalList` method to support infinite scroll:

```dart
// Replace existing verticalList method with this:

SliverList verticalList(
  List<ListableBusiness> businesses,
  Map<String, dynamic> businessPromotions,
  BuildContext context,
) {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        // Show loading indicator at the end if loading more
        if (index == businesses.length) {
          return BlocBuilder<BusinessHomeViewCubit, BusinessHomeViewState>(
            builder: (context, state) {
              if (state.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (!state.hasMoreNormalBusinesses) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No hay más negocios',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        }

        // Trigger load more when reaching the last few items
        if (index == businesses.length - 3) {
          // Load more 3 items before the end
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<BusinessHomeViewCubit>().loadMoreBusinesses();
          });
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: VerticalCard(
            image: businesses[index].featuredImage,
            title: businesses[index].name,
            id: businesses[index].id,
            category: businesses[index].category,
            businessType: businesses[index].type,
            urgentPromotion: businessPromotions[businesses[index].id],
            callback: () {
              AutoRouter.of(context).push(
                BusinessDetailsView(businessId: businesses[index].id),
              );
            },
          ),
        );
      },
      childCount: businesses.length + 1, // +1 for loading indicator
    ),
  );
}
```

Update the `successView` to pass context:

```dart
// In successView method, update this line:
verticalList(state.normalBusinesses, state.businessPromotions),

// To this:
verticalList(state.normalBusinesses, state.businessPromotions, context),
```

---

#### Step 1.5: Add Firestore Composite Index (5 min)

**File**: `firestore.indexes.json` (create if doesn't exist)

```json
{
  "indexes": [
    {
      "collectionGroup": "businesses",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "featured",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "created_at",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

**Deploy index**:
```bash
firebase deploy --only firestore:indexes
```

---

### Task 2: Implement Response Caching (1 day)

**Problem**: Every screen load hits Firestore multiple times = expensive + slow

**Solution**: Cache responses for 5 minutes using Hive

---

#### Step 2.1: Add Dependencies (5 min)

**File**: `pubspec.yaml`

```yaml
dependencies:
  # ... existing dependencies

  # Caching
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  # ... existing dev_dependencies

  # Hive code generation
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

Run:
```bash
flutter pub get
```

---

#### Step 2.2: Create Cache Service (1 hour)

**File**: `lib/src/domain/services/cache_service.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _boxName = 'heroesCache';
  static const Duration _defaultTTL = Duration(minutes: 5);

  late Box _box;

  /// Initialize Hive and open cache box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Get cached data if not expired
  T? get<T>(String key, {Duration? ttl}) {
    if (!_box.containsKey(key)) {
      return null;
    }

    final cacheEntry = _box.get(key) as Map?;
    if (cacheEntry == null) return null;

    final timestamp = cacheEntry['timestamp'] as int;
    final expiryDuration = ttl ?? _defaultTTL;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(timestamp).add(expiryDuration);

    // Check if expired
    if (DateTime.now().isAfter(expiresAt)) {
      _box.delete(key);
      return null;
    }

    return cacheEntry['data'] as T;
  }

  /// Set cache data with timestamp
  Future<void> set(String key, dynamic data) async {
    await _box.put(key, {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Clear specific cache key
  Future<void> clear(String key) async {
    await _box.delete(key);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Clear expired entries
  Future<void> clearExpired({Duration? ttl}) async {
    final expiryDuration = ttl ?? _defaultTTL;
    final now = DateTime.now();

    final keysToDelete = <String>[];

    for (var key in _box.keys) {
      final cacheEntry = _box.get(key) as Map?;
      if (cacheEntry == null) continue;

      final timestamp = cacheEntry['timestamp'] as int;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(timestamp).add(expiryDuration);

      if (now.isAfter(expiresAt)) {
        keysToDelete.add(key.toString());
      }
    }

    for (var key in keysToDelete) {
      await _box.delete(key);
    }
  }
}
```

---

#### Step 2.3: Register Cache Service in Locator (10 min)

**File**: `lib/src/locator.dart`

```dart
import 'package:heroes_app/src/domain/services/cache_service.dart';

Future<void> initLocator() async {
  // ... existing services

  // Cache Service
  final cacheService = CacheService();
  await cacheService.init();
  locator.registerSingleton<CacheService>(cacheService);

  // ... rest of services
}
```

---

#### Step 2.4: Update Business Home View Cubit to Use Cache (30 min)

**File**: `lib/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart`

Add caching to `getRequiredData()`:

```dart
class BusinessHomeViewCubit extends Cubit<BusinessHomeViewState> {
  BusinessHomeViewCubit() : super(const BusinessHomeViewState());

  final firestoreService = GetIt.instance.get<FirestoreService>();
  final authService = GetIt.instance.get<AuthService>();
  final cacheService = GetIt.instance.get<CacheService>(); // NEW
  final locator = GetIt.instance;

  static const int BUSINESSES_PER_PAGE = 10;

  // Cache keys
  static const String CACHE_KEY_HOME_FEED = 'home_feed_data';
  static const String CACHE_KEY_CATEGORIES = 'business_categories';

  void getRequiredData() async {
    emit(
      const BusinessHomeViewState(
        businessHomeViewState: BusinessViewCubitStatus.loading,
      ),
    );

    try {
      // ===== NEW: Try cache first =====
      final cachedData = cacheService.get<Map<String, dynamic>>(
        CACHE_KEY_HOME_FEED,
        ttl: const Duration(minutes: 5),
      );

      if (cachedData != null) {
        // Load from cache
        emit(
          state.copyWith(
            businessHomeViewState: BusinessViewCubitStatus.success,
            featuredBusinesses: (cachedData['featured'] as List)
                .map((e) => ListableBusiness.fromJson(e))
                .toList(),
            normalBusinesses: (cachedData['normal'] as List)
                .map((e) => ListableBusiness.fromJson(e))
                .toList(),
            onlineBusinesses: (cachedData['online'] as List)
                .map((e) => ListableBusiness.fromJson(e))
                .toList(),
            businessCategories: (cachedData['categories'] as List)
                .map((e) => BusinessCategory.fromJson(e))
                .toList(),
            businessPromotions: Map<String, Promotion>.from(
              (cachedData['promotions'] as Map).map(
                (key, value) => MapEntry(key, Promotion.fromJson(value)),
              ),
            ),
            featuredPromotions: (cachedData['featured_promotions'] as List)
                .map((e) => Promotion.fromJson(e))
                .toList(),
            lastNormalBusinessDoc: null, // Can't cache DocumentSnapshot
            hasMoreNormalBusinesses: cachedData['has_more'] ?? true,
          ),
        );
        return; // Exit early with cached data
      }

      // ===== If no cache, fetch from Firestore =====
      final businessCollection = locator.get<AppConstants>().businessCollection;

      // ... (existing Firestore queries - keep all the code from Step 1.3)

      // ===== NEW: Cache the results =====
      await cacheService.set(CACHE_KEY_HOME_FEED, {
        'featured': featuredBusiness.map((b) => b.toJson()).toList(),
        'normal': normalBusiness.map((b) => b.toJson()).toList(),
        'online': onlineBusiness.map((b) => b.toJson()).toList(),
        'categories': businessCategories.map((c) => c.toJson()).toList(),
        'promotions': businessPromotions.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'featured_promotions': featuredPromotionsList.take(10).map((p) => p.toJson()).toList(),
        'has_more': hasMoreNormal,
      });

      emit(
        state.copyWith(
          businessHomeViewState: BusinessViewCubitStatus.success,
          featuredBusinesses: featuredBusiness,
          normalBusinesses: normalBusiness,
          onlineBusinesses: onlineBusiness,
          businessCategories: businessCategories,
          businessPromotions: businessPromotions,
          featuredPromotions: featuredPromotionsList.take(10).toList(),
          lastNormalBusinessDoc: lastNormalDoc,
          hasMoreNormalBusinesses: hasMoreNormal,
        ),
      );
    } catch (e) {
      log('Error: $e, Function: getRequiredData, File: business_home_view_cubit.dart');
      emit(
        state.copyWith(businessHomeViewState: BusinessViewCubitStatus.error),
      );
    }
  }

  // Add method to refresh (bypass cache)
  void refreshFeed() async {
    await cacheService.clear(CACHE_KEY_HOME_FEED);
    getRequiredData();
  }

  // ... rest of methods
}
```

---

#### Step 2.5: Add Pull-to-Refresh (15 min)

**File**: `lib/src/presentation/pages/dashboard/pages/search/search_view.dart`

Wrap `CustomScrollView` with `RefreshIndicator`:

```dart
@override
Widget build(BuildContext context) {
  var texts = locator<AppConstants>().dashBoardTexts["searchView"];
  return Scaffold(
    body: BlocBuilder<BusinessHomeViewCubit, BusinessHomeViewState>(
      builder: (context, state) {
        switch (state.businessHomeViewState) {
          case BusinessViewCubitStatus.initial:
            context.read<BusinessHomeViewCubit>().getRequiredData();
            return loadingView(texts, Theme.of(context));
          case BusinessViewCubitStatus.loading:
            return loadingView(texts, Theme.of(context));
          case BusinessViewCubitStatus.success:
            // NEW: Wrap with RefreshIndicator
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BusinessHomeViewCubit>().refreshFeed();
                // Wait for refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: successView(context, texts, state),
            );
          default:
            return errorView(texts);
        }
      },
    ),
  );
}
```

---

### Task 3: Implement Image Lazy Loading (1 day)

**Problem**: Current implementation loads all images at once, even off-screen

**Solution**: Use `cached_network_image` package

---

#### Step 3.1: Add Dependency (5 min)

**File**: `pubspec.yaml`

```yaml
dependencies:
  # ... existing dependencies

  # Better image loading
  cached_network_image: ^3.3.1
```

Run:
```bash
flutter pub get
```

---

#### Step 3.2: Update Promotion Card Widget (30 min)

**File**: `lib/src/presentation/widgets/promotion_card_widget.dart`

Replace `Image.network` with `CachedNetworkImage`:

```dart
import 'package:cached_network_image.dart'; // ADD THIS

// Replace the existing Image.network (lines 48-87) with:

child: promotion.featuredImage.isNotEmpty
    ? CachedNetworkImage(
        imageUrl: promotion.featuredImage,
        width: double.infinity,
        fit: BoxFit.cover,
        // Cached dimensions for performance
        memCacheWidth: 560, // 2x resolution
        memCacheHeight: 280,
        // Loading placeholder
        placeholder: (context, url) => Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        // Error widget
        errorWidget: (context, url, error) => Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      )
    : Container(
        // ... existing fallback gradient
      ),
```

---

#### Step 3.3: Update Horizontal Card Widget (30 min)

**File**: `lib/src/presentation/widgets/horizontal_card_widget.dart`

Find the image loading section and replace with `CachedNetworkImage`:

```dart
import 'package:cached_network_image/cached_network_image.dart'; // ADD THIS

// Find Image.network and replace with:

CachedNetworkImage(
  imageUrl: image,
  fit: BoxFit.cover,
  memCacheWidth: 400,
  memCacheHeight: 440,
  placeholder: (context, url) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
  errorWidget: (context, url, error) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.image_not_supported,
      size: 48,
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
    ),
  ),
)
```

---

#### Step 3.4: Update Vertical Card Widget (30 min)

**File**: `lib/src/presentation/widgets/vertical_card_widget.dart`

Same replacement as horizontal card:

```dart
import 'package:cached_network_image/cached_network_image.dart'; // ADD THIS

// Replace Image.network with CachedNetworkImage
CachedNetworkImage(
  imageUrl: image,
  fit: BoxFit.cover,
  memCacheWidth: 240,
  memCacheHeight: 200,
  placeholder: (context, url) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: const Center(
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
  errorWidget: (context, url, error) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.image_not_supported,
      size: 40,
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
    ),
  ),
)
```

---

## Week 3-4: Visual Polish

### Task 4: Add Distance Indicators (1 day)

**Goal**: Show "1.2 km" on business cards (like Rappi)

---

#### Step 4.1: Update Business Models to Include Distance (30 min)

**File**: `lib/src/domain/models/listable_business_model.dart`

Add calculated distance field:

```dart
class ListableBusiness {
  // ... existing fields

  // NEW: Calculated distance from user (in kilometers)
  double? distanceFromUser;

  ListableBusiness({
    // ... existing params
    this.distanceFromUser,
  });

  // Helper method to format distance
  String get formattedDistance {
    if (distanceFromUser == null) return '';

    if (distanceFromUser! < 1.0) {
      // Less than 1km - show in meters
      return '${(distanceFromUser! * 1000).round()} m';
    } else {
      // 1km or more
      return '${distanceFromUser!.toStringAsFixed(1)} km';
    }
  }
}
```

---

#### Step 4.2: Create Distance Calculation Utility (45 min)

**File**: `lib/src/domain/services/location_service.dart` (create new file)

```dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  /// Calculate distance between two GeoPoints in kilometers
  /// Uses Haversine formula
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const earthRadius = 6371.0; // Earth's radius in kilometers

    final lat1 = _toRadians(point1.latitude);
    final lon1 = _toRadians(point1.longitude);
    final lat2 = _toRadians(point2.latitude);
    final lon2 = _toRadians(point2.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Sort businesses by distance from a point
  static List<T> sortByDistance<T>(
    List<T> items,
    GeoPoint userLocation,
    GeoPoint Function(T) getLocation,
  ) {
    final itemsWithDistance = items.map((item) {
      final distance = calculateDistance(userLocation, getLocation(item));
      return {'item': item, 'distance': distance};
    }).toList();

    itemsWithDistance.sort((a, b) =>
      (a['distance'] as double).compareTo(b['distance'] as double)
    );

    return itemsWithDistance.map((e) => e['item'] as T).toList();
  }
}
```

---

#### Step 4.3: Calculate Distances in Cubit (30 min)

**File**: `lib/src/presentation/cubits/business/business_home_view/business_home_view_cubit.dart`

Add distance calculation after fetching businesses:

```dart
void getRequiredData() async {
  // ... existing code to fetch businesses

  try {
    // ... fetch businesses (existing code)

    // ===== NEW: Calculate distances =====
    final userLocation = await locator.get<AppMethods>().getUserLocation();

    if (userLocation != null) {
      final userGeoPoint = GeoPoint(
        userLocation.latitude!,
        userLocation.longitude!,
      );

      // Calculate distance for normal businesses
      for (var business in normalBusiness) {
        business.distanceFromUser = LocationService.calculateDistance(
          userGeoPoint,
          business.location,
        );
      }

      // Calculate distance for featured businesses
      for (var business in featuredBusiness) {
        business.distanceFromUser = LocationService.calculateDistance(
          userGeoPoint,
          business.location,
        );
      }

      // Calculate distance for online businesses (if they have physical location)
      for (var business in onlineBusiness) {
        if (business.type == 'hybrid') {
          business.distanceFromUser = LocationService.calculateDistance(
            userGeoPoint,
            business.location,
          );
        }
      }
    }

    // ... rest of existing code
  } catch (e) {
    // ... error handling
  }
}
```

---

#### Step 4.4: Update Horizontal Card to Show Distance (20 min)

**File**: `lib/src/presentation/widgets/horizontal_card_widget.dart`

Add distance badge:

```dart
// Add this import at top
import 'package:heroes_app/src/domain/models/listable_business_model.dart';

// Update widget parameters to accept full business object
class HorizontalCard extends StatelessWidget {
  final String image;
  final String title;
  final String id;
  final BusinessCategory? category;
  final String businessType;
  final bool isOnGrid;
  final VoidCallback callback;
  final ListableBusiness? business; // NEW: Optional business object for distance

  const HorizontalCard({
    super.key,
    required this.image,
    required this.title,
    required this.id,
    this.category,
    required this.businessType,
    this.isOnGrid = false,
    required this.callback,
    this.business, // NEW
  });

  // ... existing code

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // ... existing container code

      child: Column(
        children: [
          // ... existing image and title

          // NEW: Add distance indicator
          if (business?.distanceFromUser != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  business!.formattedDistance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
```

---

#### Step 4.5: Update Vertical Card to Show Distance (20 min)

**File**: `lib/src/presentation/widgets/vertical_card_widget.dart`

Similar update as horizontal card - add distance badge after business name.

---

### Task 5: Add Premium Badge for Enterprise Businesses (0.5 days)

**Goal**: Show gold ⭐ "Premium" badge for Enterprise tier

---

#### Step 5.1: Add Plan Field to Business Model (15 min)

**File**: `lib/src/domain/models/listable_business_model.dart`

```dart
class ListableBusiness {
  // ... existing fields

  final String? plan; // NEW: "gratis" | "basico" | "pro" | "enterprise"

  ListableBusiness({
    // ... existing params
    this.plan,
  });

  // Helper: Check if business is premium
  bool get isPremium => plan == 'enterprise';

  factory ListableBusiness.fromJson(Map<String, dynamic> json) {
    return ListableBusiness(
      // ... existing fields
      plan: json['plan'] as String?,
    );
  }
}
```

---

#### Step 5.2: Create Premium Badge Widget (30 min)

**File**: `lib/src/presentation/widgets/premium_badge.dart` (create new)

```dart
import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  final double size;

  const PremiumBadge({
    this.size = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.25,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700), // Gold
            Color(0xFFFFA500), // Orange gold
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: size,
            color: Colors.white,
          ),
          SizedBox(width: size * 0.25),
          Text(
            'Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.75,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

#### Step 5.3: Add Badge to Business Cards (15 min each)

Update both horizontal and vertical cards:

```dart
// In HorizontalCard and VerticalCard widgets

// Add after business name/title
if (business?.isPremium ?? false) ...[
  const SizedBox(height: 4),
  const PremiumBadge(size: 16),
],
```

---

### Task 6: Enhanced Promotion Cards (1 day)

**Goal**: Add value indicators and context to promotion cards (without pricing)

**Why**: Your promotion model is percentage-based (e.g., "30% OFF"), not product-pricing based. We'll enhance cards with savings messaging, category context, and location info.

---

#### Step 6.1: Add Business Category to Promotion Card Widget (30 min)

**File**: `lib/src/presentation/widgets/promotion_card_widget.dart`

Update widget to accept business info:

```dart
class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    required this.callback,
    this.businessName,        // NEW: Optional business name
    this.categoryName,        // NEW: Optional category
    this.categoryIcon,        // NEW: Optional category icon
    this.locationCount,       // NEW: Number of locations promotion applies to
  });

  final Promotion promotion;
  final VoidCallback callback;
  final String? businessName;
  final String? categoryName;
  final String? categoryIcon;
  final int? locationCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      height: 240, // Increased height slightly for new content
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: callback,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with discount badge overlay (existing code)
              Stack(
                children: [
                  // ... existing image code ...

                  // Discount badge (existing)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${promotion.percentage}% OFF',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Promotion details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // NEW: Category badge (if provided)
                      if (categoryName != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (categoryIcon != null) ...[
                              SvgPicture.network(
                                categoryIcon!,
                                width: 14,
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              categoryName!,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Title
                      Flexible(
                        child: Text(
                          promotion.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: theme.textTheme.titleMedium!.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // NEW: Savings message for high discounts
                      if (promotion.percentage >= 30) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.savings,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '¡Ahorra hasta ${promotion.percentage}%!',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // NEW: Location count (if multiple locations)
                      if (locationCount != null && locationCount! > 1) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Válido en $locationCount ubicaciones',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Existing urgency badge
                      if (promotion.shouldShowUrgencyBadge) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getUrgencyColor(theme, promotion.urgencyLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                promotion.urgencyText,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(ThemeData theme, String urgencyLevel) {
    switch (urgencyLevel) {
      case 'critical':
        return theme.colorScheme.error;
      case 'urgent':
        return Colors.orange;
      case 'normal':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.primary;
    }
  }
}
```

Add import at top:
```dart
import 'package:flutter_svg/flutter_svg.dart';
```

---

#### Step 6.2: Update Search View to Pass Business Info (30 min)

**File**: `lib/src/presentation/pages/dashboard/pages/search/search_view.dart`

Update the `featuredPromotionsCarousel` method to pass business data:

```dart
Widget featuredPromotionsCarousel(
  List<dynamic> promotions,
  BuildContext context,
  List<ListableBusiness> allBusinesses, // NEW: Pass business list
  List<BusinessCategory> categories,    // NEW: Pass categories
) {
  return SliverToBoxAdapter(
    child: Container(
      height: 240, // Increased height
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        padding: const EdgeInsets.all(0.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final promotion = promotions[index] as Promotion;

          // Find the business for this promotion
          final business = allBusinesses.firstWhere(
            (b) => b.id == promotion.businessId,
            orElse: () => allBusinesses.first,
          );

          // Find category
          final category = business.category;

          return PromotionCard(
            promotion: promotion,
            businessName: business.name,
            categoryName: category?.name,
            categoryIcon: category?.imageUrl,
            locationCount: promotion.locationIds.isEmpty
              ? null // Applies to all locations
              : promotion.locationIds.length,
            callback: () {
              AutoRouter.of(context).push(
                PromotionDetailsView(
                  promotionId: promotion.documentId ?? '',
                  promotion: promotion,
                ),
              );
            },
          );
        },
        itemCount: promotions.length,
      ),
    ),
  );
}
```

Update the call in `successView`:

```dart
// Change from:
featuredPromotionsCarousel(state.featuredPromotions, context),

// To:
featuredPromotionsCarousel(
  state.featuredPromotions,
  context,
  [...state.featuredBusinesses, ...state.normalBusinesses], // All businesses
  state.businessCategories,
),
```

---

#### Step 6.3: Add Savings Helper to Promotion Model (15 min)

**File**: `lib/src/domain/models/promotion_model.dart`

Add helper method for savings messaging:

```dart
class Promotion extends Equatable {
  // ... existing fields and methods

  /// Get savings tier: 'high' (30%+), 'medium' (20-29%), 'standard' (<20%)
  String get savingsTier {
    if (percentage >= 30) return 'high';
    if (percentage >= 20) return 'medium';
    return 'standard';
  }

  /// Get savings message based on percentage
  String get savingsMessage {
    if (percentage >= 50) return '¡Ahorro increíble!';
    if (percentage >= 30) return '¡Gran ahorro!';
    if (percentage >= 20) return '¡Buen descuento!';
    return '';
  }

  /// Whether to show savings badge
  bool get shouldShowSavingsBadge => percentage >= 30;

  // ... rest of existing code
}
```

---

## Testing Checklist

### Week 1-2 Testing
- [ ] **Pagination**:
  - [ ] Home feed loads 10 businesses initially
  - [ ] Scrolling to bottom loads more businesses
  - [ ] Loading indicator appears while fetching
  - [ ] "No hay más negocios" appears when all loaded
  - [ ] Works correctly after pull-to-refresh

- [ ] **Caching**:
  - [ ] First load fetches from Firestore (check console logs)
  - [ ] Second load within 5 minutes uses cache (faster, no Firestore reads)
  - [ ] Pull-to-refresh clears cache and fetches fresh data
  - [ ] Cache expires after 5 minutes (force wait and reload)

- [ ] **Image Loading**:
  - [ ] Images show loading placeholder while downloading
  - [ ] Images cache properly (scroll down, scroll up - should be instant)
  - [ ] Error state shows for broken image URLs
  - [ ] No memory leaks (use Flutter DevTools)

### Week 3-4 Testing
- [ ] **Distance Indicators**:
  - [ ] Distance shows correctly on business cards
  - [ ] Distance updates when user location changes
  - [ ] Distance formats correctly (< 1km shows meters, >= 1km shows km)
  - [ ] Works for all card types (horizontal, vertical)

- [ ] **Premium Badge**:
  - [ ] Badge shows ONLY for Enterprise businesses
  - [ ] Badge styling matches design (gold gradient, star icon)
  - [ ] Badge doesn't show for other tiers

- [ ] **Enhanced Promotion Cards**:
  - [ ] Category badge shows with icon and name
  - [ ] Savings message shows ONLY for promotions >= 30%
  - [ ] Location count shows when promotion applies to multiple locations
  - [ ] Location count doesn't show when promotion applies to ALL locations (locationIds.isEmpty)
  - [ ] All elements align properly (no overflow)
  - [ ] Card height accommodates new content (240px)

---

## Performance Metrics

Track these before/after Phase 1:

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| **Initial load time** | ? | ? | < 2 sec |
| **Firestore reads (initial load)** | ~20 | ~10 | < 15 |
| **Firestore reads (cached load)** | ~20 | 0 | 0 |
| **Businesses loaded** | All (~50) | 10 | 10 |
| **Memory usage** | ? | ? | < 100MB |
| **Image cache hit rate** | 0% | 80%+ | > 75% |

**How to measure**:
- Use Firebase Console → Firestore → Usage tab
- Use Flutter DevTools → Performance tab
- Use Flutter DevTools → Memory tab

---

## Troubleshooting

### Common Issues

**Issue**: "Missing index" error in Firestore
**Solution**: Run `firebase deploy --only firestore:indexes`

**Issue**: Hive initialization error
**Solution**: Ensure `await Hive.initFlutter()` runs in `main()` before `runApp()`

**Issue**: Images not caching
**Solution**: Check internet connection, verify image URLs are valid

**Issue**: Pagination not triggering
**Solution**: Check `hasMoreNormalBusinesses` is true, ensure scroll listener is working

**Issue**: Distance showing null
**Solution**: Verify location permissions granted, check user's location is available

---

## Next Steps

After completing Phase 1:
1. **Deploy to TestFlight/Internal Testing** - Get feedback from 5-10 users
2. **Monitor metrics** - Check Firestore usage, app performance
3. **Move to Phase 2** - Start implementing discovery features (trending, personalization)

---

## Questions?

Need help with:
- Specific code implementation?
- Debugging pagination issues?
- Testing strategies?
- Cloud Functions setup (for caching)?

**Let me know and I'll provide detailed guidance! 🚀**