📋 HEROES COLOMBIA MAP ENHANCEMENT - IMPLEMENTATION PLAN
🎯 EXECUTIVE SUMMARY
Problem: Users in Australia (or outside Colombia) cannot see Colombian businesses on the map due to GPS-based initial loading and small search radius. Solution: Implement intelligent defaults, performance optimizations, category filtering, and Google Maps-style UX improvements. Timeline: 3 phases over 2-3 days
Priority: High (blocking feature for international users)
📊 PHASE 1: CRITICAL FIXES ⚡ (Priority: URGENT - 2-3 hours)
1.1 Fix Geolocation Discovery
File: heroesapp/lib/src/presentation/cubits/map/map_cubit.dart
Lines: 29-67 (map_cubit.dart:29-67) Current Issue:
// ❌ PROBLEM: Uses user GPS location (Australia)
final userCurrentLocation = await locator<AppMethods>().getUserLocation();
final userGeoPoint = GeoPoint(
  userCurrentLocation!.latitude!,
  userCurrentLocation.longitude!,
);

// Searches businesses near Australia, not Colombia!
final businessRawInfoStream = locator
    .get<FirestoreService>()
    .getDocumentsNearPosition(
      initialCameraPosition != null
          ? GeoPoint(...)
          : userGeoPoint,  // ❌ Wrong location!
      1.2,  // ❌ Only 1.2km radius
      businessCollection,
    );
Solution:
// ✅ SOLUTION: Always default to Colombia center
Future<void> getMapInitialInformation(
  BuildContext context,
  LocationData? initialCameraPosition,
) async {
  emit(state.copyWith(isMapLoading: true));
  
  // Colombia center (Bogotá)
  const colombiaCenter = GeoPoint(4.5709, -74.2973);
  
  // Get user location for UI purposes (show user's blue dot)
  final userCurrentLocation = await locator<AppMethods>().getUserLocation();
  
  // Determine search center: use provided camera position, else Colombia
  final searchCenter = initialCameraPosition != null
      ? GeoPoint(
          initialCameraPosition.latitude!,
          initialCameraPosition.longitude!,
        )
      : colombiaCenter;  // ✅ Default to Colombia!
  
  // Emit user location (for blue dot on map)
  emit(state.copyWith(
    userLocation: userCurrentLocation,
    status: BusinessViewCubitStatus.success,
    isMapLoading: true,
  ));
  
  // Fetch businesses near Colombia (or camera position)
  final businessRawInfoStream = locator
      .get<FirestoreService>()
      .getDocumentsNearPosition(
        searchCenter,  // ✅ Colombia center
        5.0,  // ✅ Increased radius to 5km
        businessCollection,
      );
  
  // ... rest of implementation
}
Impact:
✅ Users see Colombian businesses from anywhere in the world
✅ Camera centers on Bogotá by default
✅ User's blue dot still shows their actual location
1.2 Increase Search Radius
File: heroesapp/lib/src/presentation/cubits/map/map_cubit.dart
Lines: 57-66, 252-258 Changes:
// Change line 64 and 256
.getDocumentsNearPosition(
  searchCenter,
  5.0,  // ✅ Changed from 1.2km to 5km
  businessCollection,
);
Rationale:
1.2km radius = very small area (good for walking, bad for exploration)
5km radius = covers entire city zones (better discovery)
Still performant (GeoFirestore indexed queries)
1.3 Optimize Parallel Location Fetching
File: heroesapp/lib/src/domain/repositories/firestore_service.dart
Lines: 601-619 (firestore_service.dart:601-619) Current Implementation (SLOW):
Future<Map<String, List<Map<String, dynamic>>>> getMultipleBusinessLocations(
  List<String> businessIds,
) async {
  final Map<String, List<Map<String, dynamic>>> businessLocationsMap = {};
  
  // ❌ SEQUENTIAL: One at a time (slow!)
  for (String businessId in businessIds) {
    final locations = await getBusinessLocations(businessId);
    if (locations.isNotEmpty) {
      businessLocationsMap[businessId] = locations;
    }
  }
  
  return businessLocationsMap;
}
Performance:
20 businesses × 150ms each = 3000ms (3 seconds)
Optimized Implementation (FAST):
Future<Map<String, List<Map<String, dynamic>>>> getMultipleBusinessLocations(
  List<String> businessIds,
) async {
  try {
    // ✅ PARALLEL: All at once!
    final locationFutures = businessIds.map((businessId) async {
      final locations = await getBusinessLocations(businessId);
      return MapEntry(businessId, locations);
    });
    
    // Wait for all to complete in parallel
    final results = await Future.wait(locationFutures);
    
    // Filter out empty results and convert to map
    return Map.fromEntries(
      results.where((entry) => entry.value.isNotEmpty)
    );
  } catch (e) {
    log('Error fetching multiple business locations: $e');
    return {};
  }
}
Performance Gain:
Before: 3000ms (sequential)
After: 150-300ms (parallel)
Speedup: 10-20x faster ⚡
📊 PHASE 2: UX ENHANCEMENTS 🎨 (Priority: HIGH - 4-6 hours)
2.1 Category Carousel Filter
File: Create new file heroesapp/lib/src/presentation/widgets/map_category_filter.dart Design:
┌─────────────────────────────────────────────────┐
│ [Search Bar - existing FloatingSearchBar]      │
├─────────────────────────────────────────────────┤
│ [🍽️ Restaurants] [☕ Coffee] [🛒 Groceries]     │ ← NEW
│              ← Horizontal Scroll →              │
└─────────────────────────────────────────────────┘
Implementation:
class MapCategoryFilter extends StatelessWidget {
  final List<BusinessCategory> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 80), // Below search bar
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" chip
            return _buildCategoryChip(
              context,
              label: 'All',
              icon: Icons.apps,
              isSelected: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            );
          }
          
          final category = categories[index - 1];
          return _buildCategoryChip(
            context,
            label: category.name,
            imageUrl: category.imageUrl,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 18),
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: 18,
                height: 18,
                placeholder: (_, __) => Icon(Icons.category, size: 18),
              ),
            SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primaryContainer,
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }
}
Integration in map_view.dart:
// In MapViewState
String? _selectedCategoryId;

// Add to Stack in succesView()
Stack(
  children: [
    mapWidget(appTheme, state),
    FloatingSearchBar(...), // Existing
    
    // ✅ NEW: Category filter
    if (state.businessCategories.isNotEmpty)
      MapCategoryFilter(
        categories: state.businessCategories,
        selectedCategoryId: _selectedCategoryId,
        onCategorySelected: (categoryId) {
          setState(() => _selectedCategoryId = categoryId);
          context.read<MapCubit>().filterByCategory(categoryId);
        },
      ),
  ],
)
MapCubit changes:
// In map_cubit.dart
void filterByCategory(String? categoryId) {
  if (categoryId == null) {
    // Show all markers
    emit(state.copyWith(filtredMarkers: state.allMarkers));
    return;
  }
  
  // Filter markers by category
  final filtered = state.allMarkers.where((marker) {
    final business = state.allBusinessMarkers.firstWhere(
      (b) => b.businessId == marker.markerId.value,
      orElse: () => null,
    );
    return business?.categoryId == categoryId;
  }).toList();
  
  emit(state.copyWith(filtredMarkers: filtered));
}

// Fetch categories (reuse from business_home_view)
Future<void> loadCategories() async {
  final cacheService = locator.get<CacheService>();
  List<BusinessCategory> categories;
  
  final cached = cacheService.get<List<BusinessCategory>>(
    CacheKeys.businessCategories,
  );
  
  if (cached != null) {
    categories = cached;
  } else {
    final raw = await locator
        .get<FirestoreService>()
        .readAllActiveDocuments(
          locator.get<AppConstants>().businessCategoryCollection,
        );
    categories = raw.map((e) => BusinessCategory.fromJson(e)).toList();
    cacheService.set(CacheKeys.businessCategories, categories);
  }
  
  emit(state.copyWith(businessCategories: categories));
}
2.2 Bottom Sheet Preview Widget
File: Create new file heroesapp/lib/src/presentation/widgets/business_map_preview_sheet.dart Full Implementation:
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/src/domain/models/business_model.dart';
import 'package:heroes_app/src/domain/models/promotion_model.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessMapPreviewSheet extends StatefulWidget {
  final String businessId;
  final String businessName;
  final String? categoryName;
  final String address;
  final String? phoneNumber;
  final GeoPoint location;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const BusinessMapPreviewSheet({
    super.key,
    required this.businessId,
    required this.businessName,
    this.categoryName,
    required this.address,
    this.phoneNumber,
    required this.location,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<BusinessMapPreviewSheet> createState() => _BusinessMapPreviewSheetState();
}

class _BusinessMapPreviewSheetState extends State<BusinessMapPreviewSheet> {
  final locator = GetIt.instance;
  List<Promotion>? _promotions;
  bool _isLoadingPromotions = true;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('businesses')
          .doc(widget.businessId)
          .collection('promotions')
          .where('status', isEqualTo: 'active')
          .where('valid_until', isGreaterThan: Timestamp.now())
          .limit(5)
          .get();

      final promotions = snapshot.docs
          .map((doc) => Promotion.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      setState(() {
        _promotions = promotions;
        _isLoadingPromotions = false;
      });
    } catch (e) {
      setState(() {
        _promotions = [];
        _isLoadingPromotions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.35,
      maxChildSize: 0.55,
      snap: true,
      snapSizes: [0.35, 0.55],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              _buildDragHandle(),
              _buildTopSection(theme),
              _buildActionButtons(theme),
              _buildPromotionsSection(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTopSection(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Name + Action Icons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.businessName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              _buildActionIcons(theme),
            ],
          ),
          
          SizedBox(height: 8),
          
          // Category (if available)
          if (widget.categoryName != null) ...[
            Text(
              widget.categoryName!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
          ],
          
          // Address
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcons(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Favorite (always shown)
        IconButton.filledTonal(
          onPressed: widget.onFavoriteToggle,
          icon: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavorite ? Colors.red : null,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              theme.colorScheme.surfaceVariant,
            ),
          ),
        ),
        
        // Call (conditional)
        if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) ...[
          SizedBox(width: 4),
          IconButton.filledTonal(
            onPressed: () => _callBusiness(widget.phoneNumber!),
            icon: Icon(Ionicons.call_outline),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                theme.colorScheme.surfaceVariant,
              ),
            ),
          ),
        ],
        
        // WhatsApp (conditional)
        if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) ...[
          SizedBox(width: 4),
          IconButton.filledTonal(
            onPressed: () => _openWhatsApp(widget.phoneNumber!),
            icon: Icon(Ionicons.logo_whatsapp),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                theme.colorScheme.surfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _navigateToBusiness,
              icon: Icon(Icons.navigation),
              label: Text('Navigate'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _viewBusinessDetails,
              icon: Icon(Icons.business),
              label: Text('See Business'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection(ThemeData theme) {
    if (_isLoadingPromotions) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_promotions == null || _promotions!.isEmpty) {
      return _buildNoPromotions(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.local_offer, size: 20, color: theme.colorScheme.primary),
              SizedBox(width: 8),
              Text(
                'Active Promotions (${_promotions!.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _promotions!.length,
            itemBuilder: (context, index) {
              return _buildPromotionCard(_promotions![index], theme);
            },
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPromotionCard(Promotion promotion, ThemeData theme) {
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promotion Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: promotion.imageUrl ?? '',
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 100,
                color: Colors.grey[200],
                child: Icon(Icons.local_offer, size: 32),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 100,
                color: Colors.grey[200],
                child: Icon(Icons.local_offer, size: 32),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.title,
                  style: theme.textTheme.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Valid: ${_formatDate(promotion.validUntil)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPromotions(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.local_offer_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'No active promotions at the moment',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _viewBusinessDetails,
            icon: Icon(Icons.info_outline),
            label: Text('View Business Info'),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  void _callBusiness(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!cleanPhone.startsWith('+') && cleanPhone.length <= 10) {
      cleanPhone = '57$cleanPhone';
    } else if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1);
    }
    
    final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone');
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToBusiness() async {
    await locator.get<AppMethods>().navigateToLocation(
      latitude: widget.location.latitude,
      longitude: widget.location.longitude,
      context: context,
    );
  }

  void _viewBusinessDetails() {
    Navigator.pop(context); // Close bottom sheet
    AutoRouter.of(context).push(
      BusinessDetailsView(businessId: widget.businessId),
    );
  }
}
2.3 Replace Marker Tap with Bottom Sheet
File: heroesapp/lib/src/presentation/cubits/map/map_cubit.dart
Lines: 104-124, 302-322 Changes:
// Modify marker creation to use onTap callback instead of direct navigation
final marker = Marker(
  markerId: markerId,
  position: LatLng(
    location.location!.latitude,
    location.location!.longitude,
  ),
  infoWindow: InfoWindow(
    title: business.name,
    snippet: location.isPrimary
        ? '${location.displayAddress} (Principal)'
        : location.displayAddress,
  ),
  icon: location.isPrimary
      ? BitmapDescriptor.defaultMarkerWithHue(84.62)
      : BitmapDescriptor.defaultMarkerWithHue(200),
  // ✅ NEW: Store business data in marker for bottom sheet
  onTap: () {
    // This will be handled in map_view.dart
    // Pass business data to bottom sheet
  },
);
In map_view.dart:
// Add method to show bottom sheet
void _showBusinessPreview(Marker marker) {
  // Get business data from marker
  final businessId = marker.markerId.value.split('_')[0];
  final business = context.read<MapCubit>().state.allBusinessMarkers
      .firstWhere((b) => b.businessId == businessId);
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BusinessMapPreviewSheet(
      businessId: business.businessId,
      businessName: business.name,
      categoryName: business.categoryName, // Need to add this
      address: business.address,
      phoneNumber: business.phoneNumber, // Need to fetch
      location: business.location,
      isFavorite: false, // Need to check
      onFavoriteToggle: () {
        // Handle favorite toggle
      },
    ),
  );
}

// Modify marker creation in mapWidget
markers: state.allMarkers.map((marker) {
  return marker.copyWith(
    onTapParam: () => _showBusinessPreview(marker),
  );
}).toSet(),
📊 PHASE 3: ADVANCED FEATURES 🚀 (Priority: MEDIUM - 3-4 hours)
3.1 Zoom-Based Marker Clustering
Dependencies:
# pubspec.yaml
dependencies:
  google_maps_cluster_manager: ^3.0.0+1
Implementation:
// In map_view.dart
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class MapViewState extends State<MapView> {
  late ClusterManager<BusinessMarker> _clusterManager;
  Set<Marker> _clusterMarkers = {};
  
  @override
  void initState() {
    super.initState();
    _initClusterManager();
  }
  
  void _initClusterManager() {
    _clusterManager = ClusterManager<BusinessMarker>(
      [], // Will be updated from state
      _updateMarkers,
      markerBuilder: _buildClusterMarker,
      levels: [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
      extraPercent: 0.2,
      stopClusteringZoom: 17.0,
    );
  }
  
  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _clusterMarkers = markers;
    });
  }
  
  Future<Marker> _buildClusterMarker(Cluster<BusinessMarker> cluster) async {
    if (cluster.isMultiple) {
      // Show cluster bubble with count
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: await _getClusterBitmapDescriptor(cluster.count),
        onTap: () {
          // Zoom into cluster
          final controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, 15),
          );
        },
      );
    } else {
      // Show individual marker
      final business = cluster.items.first;
      return Marker(
        markerId: MarkerId(business.businessId),
        position: LatLng(
          business.location.latitude,
          business.location.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(84.62),
        infoWindow: InfoWindow(
          title: business.name,
          snippet: business.address,
        ),
        onTap: () => _showBusinessPreview(business),
      );
    }
  }
  
  Future<BitmapDescriptor> _getClusterBitmapDescriptor(int count) async {
    // Create custom cluster icon with count
    // You can use a package or custom painter
    return BitmapDescriptor.defaultMarkerWithHue(
      count < 10 ? 120 : count < 50 ? 60 : 0, // Color based on count
    );
  }
  
  @override
  void dispose() {
    _clusterManager.dispose();
    super.dispose();
  }
}
📋 IMPLEMENTATION CHECKLIST
Phase 1: Critical Fixes ✅
 Colombia default location in map_cubit.dart
 Increase radius to 5km (2 places)
 Parallel location fetching in firestore_service.dart
 Test from Australia (should see Colombian businesses)
Phase 2: UX Enhancements ✅
 Create MapCategoryFilter widget
 Integrate category filter in map_view.dart
 Add filterByCategory() in map_cubit.dart
 Fetch categories in map cubit
 Create BusinessMapPreviewSheet widget
 Implement top section (name, category, address, icons)
 Implement action buttons (Navigate, See Business)
 Implement promotions carousel
 Handle no promotions case
 Replace marker tap with bottom sheet trigger
 Test bottom sheet UX (draggable, dismiss, navigation)
Phase 3: Advanced Features ✅
 Add clustering dependency
 Implement ClusterManager in map_view.dart
 Create custom cluster icons
 Test zoom-based clustering behavior
 Optimize clustering performance
🎯 SUCCESS CRITERIA
Functional Requirements
✅ Users in Australia can see Colombian businesses
✅ Map defaults to Bogotá center
✅ Categories filter visible businesses
✅ Bottom sheet shows on marker tap
✅ Navigate button opens map selection (Waze/Google/Apple)
✅ Call/WhatsApp work (if phone available)
✅ Favorite toggle works
✅ Promotions display (or placeholder if empty)
✅ Clustering works at different zoom levels
Performance Requirements
✅ Initial load < 2 seconds
✅ Category filter response < 100ms
✅ Bottom sheet opens < 200ms
✅ Marker clustering smooth at 60fps
✅ No memory leaks (tested for 10+ min usage)
UX Requirements
✅ Intuitive category selection
✅ Smooth bottom sheet drag interactions
✅ Clear visual hierarchy in bottom sheet
✅ Responsive design (works on all screen sizes)
✅ Error states handled gracefully