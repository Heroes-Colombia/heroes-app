# Multi-Location Enhancement - Mobile App Implementation

**Created:** January 20, 2026
**Status:** Ready for Implementation
**Estimated Time:** 30-40 minutes
**Priority:** Medium (Phase 1 Enhancement)

---

## Overview

This enhancement improves the user experience for businesses with multiple physical locations by:
1. Clearly indicating distance is from **primary location** on cards
2. Adding **location count badge** on cards (when >1 physical location)
3. Displaying **all locations** in the business details "Information" tab with distances and navigation

### Design Decision: Option 1 - Inside Information Tab

**Rejected Alternatives:**
- ❌ Option 2: New 4th tab "Ubicaciones" - Too prominent for secondary info
- ❌ Option 3: Inline below description - Cluttered layout

**Chosen Approach:**
- ✅ Option 1: Dedicated section inside existing "Information" tab
- Locations appear after contact info, before schedule
- Sorted by distance (nearest first)
- Only shown when business has multiple locations OR user needs to navigate

---

## Prerequisites

### Backend Requirements

**⚠️ CRITICAL:** Dashboard must implement auto-update logic first!

The dashboard needs to maintain denormalized counts in the main business document:

```typescript
// Dashboard: functions/src/triggers/onLocationWrite.ts
export const onLocationWrite = functions.firestore
  .document('businesses/{businessId}/locations/{locationId}')
  .onWrite(async (change, context) => {
    const businessId = context.params.businessId;

    // Get all active locations
    const locationsSnapshot = await admin.firestore()
      .collection('businesses')
      .doc(businessId)
      .collection('locations')
      .where('status', '==', 'active')
      .get();

    // Count physical locations
    const physicalCount = locationsSnapshot.docs.filter(
      doc => doc.data().type === 'physical'
    ).length;

    // Update business document
    await admin.firestore()
      .collection('businesses')
      .doc(businessId)
      .update({
        physical_locations_count: physicalCount,
        total_locations_count: locationsSnapshot.size,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
  });
```

**Mobile App Schema Change:**

```dart
// Add to Business and ListableBusiness models
class Business {
  // ... existing fields
  final int physicalLocationsCount; // NEW - auto-updated by backend
  final int totalLocationsCount;    // NEW - auto-updated by backend
}
```

---

## Implementation Tasks

### Task 1.1: Update Distance Indicator on Cards (5 min)

**File:** `lib/src/presentation/widgets/vertical_card_widget.dart`

**Current Code (Line ~140):**
```dart
if (formattedDistance != null && businessType != 'online')
  Text(
    '📍 $formattedDistance',
    style: TextStyle(...),
  ),
```

**New Code:**
```dart
if (formattedDistance != null && businessType != 'online')
  Row(
    children: [
      Text(
        '📍 Sede Principal • $formattedDistance',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: theme.textTheme.labelSmall!.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Show location count badge if >1 physical location
      if (physicalLocationsCount != null && physicalLocationsCount! > 1) ...[
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            '+${physicalLocationsCount! - 1}',
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ],
  ),
```

**Why:** Makes it explicit that distance is to primary location, not nearest location.

---

### Task 1.2: Create BusinessLocation Model (5 min)

**File:** `lib/src/domain/models/business_location_model.dart` (NEW)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a single location (physical or online) for a business.
/// Businesses can have multiple locations in the `locations` subcollection.
class BusinessLocation extends Equatable {
  final String id;
  final String name;
  final bool isPrimary;
  final String type; // "physical" | "online"
  final String? address;
  final GeoPoint? location;
  final Map<String, dynamic>? geoHash;
  final String status; // "active" | "inactive"
  final DateTime? createdAt;

  // Mutable field for distance calculation
  double? distanceKm;

  BusinessLocation({
    required this.id,
    required this.name,
    required this.isPrimary,
    required this.type,
    this.address,
    this.location,
    this.geoHash,
    required this.status,
    this.createdAt,
    this.distanceKm,
  });

  factory BusinessLocation.fromJson(Map<String, dynamic> json, String id) {
    // Parse location (handle both GeoPoint and Map)
    GeoPoint? location;
    try {
      if (json['location'] != null) {
        final loc = json['location'];
        if (loc is GeoPoint) {
          location = loc;
        } else if (loc is Map) {
          location = GeoPoint(
            (loc['latitude'] ?? loc['_latitude']) as double,
            (loc['longitude'] ?? loc['_longitude']) as double,
          );
        }
      }
    } catch (e) {
      location = null;
    }

    return BusinessLocation(
      id: id,
      name: json['name'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      type: json['type'] as String,
      address: json['address'] as String?,
      location: location,
      geoHash: json['geo_hash'] as Map<String, dynamic>?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : null,
    );
  }

  /// Calculate distance from user's location using Haversine formula
  void calculateDistance(double userLat, double userLng) {
    if (location == null) {
      distanceKm = null;
      return;
    }

    const double earthRadius = 6371; // km
    final double dLat = _toRadians(location!.latitude - userLat);
    final double dLng = _toRadians(location!.longitude - userLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) *
            cos(_toRadians(location!.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    distanceKm = earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  /// Get formatted distance string (e.g., "1.2 km" or "500 m")
  String? get formattedDistance {
    if (distanceKm == null) return null;
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  /// Check if this is a physical location
  bool get isPhysical => type == 'physical';

  /// Check if this is an online location
  bool get isOnline => type == 'online';

  @override
  List<Object?> get props => [
        id,
        name,
        isPrimary,
        type,
        address,
        location,
        status,
        distanceKm,
      ];
}
```

**Import in other files:**
```dart
import 'package:heroes_app/src/domain/models/business_location_model.dart';
```

---

### Task 1.3: Create BusinessLocationItem Widget (10 min)

**File:** `lib/src/presentation/widgets/business_location_item.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:heroes_app/src/domain/models/business_location_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget to display a single business location with navigation capability.
/// Shows primary badge, type icon, distance, and navigation button.
class BusinessLocationItem extends StatelessWidget {
  const BusinessLocationItem({
    super.key,
    required this.location,
    required this.onNavigate,
  });

  final BusinessLocation location;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPhysical = location.isPhysical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: location.isPrimary
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon (physical/online)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPhysical
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPhysical ? Icons.store : Icons.language,
              color: isPhysical
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSecondaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Location details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Primary badge
                Row(
                  children: [
                    if (location.isPrimary) ...[
                      Icon(
                        Icons.star,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        location.name,
                        style: TextStyle(
                          fontSize: theme.textTheme.titleSmall!.fontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Address (physical only)
                if (isPhysical && location.address != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    location.address!,
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall!.fontSize,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Distance (physical only)
                if (isPhysical && location.formattedDistance != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.formattedDistance!,
                        style: TextStyle(
                          fontSize: theme.textTheme.labelSmall!.fontSize,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                // Online indicator
                if (!isPhysical) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Compra online disponible',
                    style: TextStyle(
                      fontSize: theme.textTheme.bodySmall!.fontSize,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation button
          const SizedBox(width: 8),
          IconButton(
            onPressed: onNavigate,
            icon: Icon(
              isPhysical ? Icons.directions : Icons.open_in_new,
              color: theme.colorScheme.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            tooltip: isPhysical ? 'Cómo llegar' : 'Abrir sitio web',
          ),
        ],
      ),
    );
  }
}
```

**Import in business details:**
```dart
import 'package:heroes_app/src/presentation/widgets/business_location_item.dart';
```

---

### Task 1.4: Update Business Details Information Tab (10 min)

**File:** `lib/src/presentation/pages/dashboard/pages/search/promotion_details_view.dart`

**Location:** Inside the "Information" tab section, after contact info

**Add State Variables (at top of `_PromotionDetailsViewState`):**
```dart
class _PromotionDetailsViewState extends State<PromotionDetailsView> {
  // ... existing state
  List<BusinessLocation> _locations = [];
  bool _loadingLocations = false;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _loadingLocations = true);

    try {
      // Get user location for distance calculation
      final userLocation = await locator.get<AppMethods>().getUserLocation();
      _userLat = userLocation['latitude'];
      _userLng = userLocation['longitude'];

      // Fetch locations subcollection
      final locationsSnapshot = await locator
          .get<FirestoreService>()
          .firestore
          .collection('businesses')
          .doc(widget.business.id)
          .collection('locations')
          .where('status', isEqualTo: 'active')
          .get();

      final locations = locationsSnapshot.docs
          .map((doc) => BusinessLocation.fromJson(doc.data(), doc.id))
          .toList();

      // Calculate distances for physical locations
      if (_userLat != null && _userLng != null) {
        for (var location in locations) {
          if (location.isPhysical && location.location != null) {
            location.calculateDistance(_userLat!, _userLng!);
          }
        }
      }

      // Sort: Primary first, then by distance (physical), then online
      locations.sort((a, b) {
        if (a.isPrimary && !b.isPrimary) return -1;
        if (!a.isPrimary && b.isPrimary) return 1;

        // Both physical - sort by distance
        if (a.isPhysical && b.isPhysical) {
          if (a.distanceKm == null) return 1;
          if (b.distanceKm == null) return -1;
          return a.distanceKm!.compareTo(b.distanceKm!);
        }

        // Physical before online
        if (a.isPhysical && !b.isPhysical) return -1;
        if (!a.isPhysical && b.isPhysical) return 1;

        return 0;
      });

      setState(() {
        _locations = locations;
        _loadingLocations = false;
      });
    } catch (e) {
      setState(() => _loadingLocations = false);
      print('Error loading locations: $e');
    }
  }

  // Navigation helper
  void _navigateToLocation(BusinessLocation location) {
    if (location.isPhysical && location.location != null) {
      // Open in maps app
      final lat = location.location!.latitude;
      final lng = location.location!.longitude;
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (location.isOnline) {
      // Open business website (you'll need to add website field to Business model)
      if (widget.business.website != null) {
        final url = Uri.parse(widget.business.website!);
        launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }
}
```

**Add in Information Tab Section (after contact info, before schedule):**
```dart
// Inside the Information tab's column/list:

// === EXISTING CONTACT INFO ===
// ...

// === NEW: LOCATIONS SECTION ===
if (_locations.isNotEmpty || _loadingLocations) ...[
  const SizedBox(height: 24),
  const Divider(),
  const SizedBox(height: 16),

  // Section header
  Row(
    children: [
      Icon(
        Icons.location_on,
        size: 20,
        color: theme.colorScheme.primary,
      ),
      const SizedBox(width: 8),
      Text(
        'Ubicaciones (${_locations.length})',
        style: TextStyle(
          fontSize: theme.textTheme.titleMedium!.fontSize,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),

  // Loading indicator
  if (_loadingLocations)
    const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    ),

  // Location list
  if (!_loadingLocations)
    ..._locations.map((location) => BusinessLocationItem(
      location: location,
      onNavigate: () => _navigateToLocation(location),
    )),
],

// === EXISTING SCHEDULE/HOURS ===
// ...
```

---

## Testing Checklist

### Card View Tests
- [ ] Distance shows "📍 Sede Principal • X km" (not just "X km")
- [ ] Business with 2+ physical locations shows "+1", "+2", etc. badge
- [ ] Business with only 1 physical location shows no badge
- [ ] Online-only businesses show no distance/badge

### Business Details Tests
- [ ] Locations section appears in "Information" tab (not as 4th tab)
- [ ] Primary location shows ⭐ star icon
- [ ] Physical locations show 🏢 icon and distance
- [ ] Online locations show 🌐 icon
- [ ] Locations sorted: primary → nearest → farthest → online
- [ ] Tap physical location → opens Google Maps
- [ ] Tap online location → opens business website
- [ ] Single-location business shows section (for navigation convenience)

### Edge Cases
- [ ] No locations (shouldn't happen, but gracefully hide section)
- [ ] Location without coordinates (show but no distance)
- [ ] User location disabled (show locations without distances)
- [ ] Very long location names (ellipsis overflow)

---

## Performance Considerations

### Query Cost
- **1 additional Firestore read per business details view** (locations subcollection)
- Acceptable cost for UX improvement
- Cache locations in business details state (don't re-fetch on tab switch)

### Distance Calculation
- O(n) where n = number of locations (typically 1-5)
- Haversine formula is fast (~0.1ms per calculation)
- No performance concern

### Alternative (Not Recommended)
- Backend denormalization of nearest location distance
- Rejected: Adds complexity, requires user location in backend, stale data risk

---

## Migration Notes

### Backward Compatibility
- New fields (`physicalLocationsCount`, `totalLocationsCount`) are optional
- Old data without counts: badge won't show (acceptable degradation)
- Locations subcollection is new - existing businesses will have 0 locations until dashboard creates them

### Data Migration (Dashboard Responsibility)
Dashboard needs to:
1. Create primary location for all existing businesses
2. Run count update script to populate `*_locations_count` fields
3. Set up auto-update trigger for future changes

---

## Rollout Plan

### Phase 1: Backend (Dashboard - 1 hour)
1. Implement auto-update trigger
2. Add location count fields to business document
3. Create migration script for existing businesses
4. Test with 2-3 sample businesses

### Phase 2: Mobile App (This Document - 30-40 min)
1. Implement Task 1.1 (distance indicator)
2. Implement Task 1.2 (BusinessLocation model)
3. Implement Task 1.3 (BusinessLocationItem widget)
4. Implement Task 1.4 (Information tab update)
5. Test with real data

### Phase 3: QA & Launch (30 min)
1. Test all card scenarios
2. Test business details with 1, 2, 5+ locations
3. Test navigation (maps/website opening)
4. Verify performance (no lag on scroll)

**Total Time:** ~2-2.5 hours (backend + mobile + QA)

---

## Future Enhancements (Not in Scope)

1. **Distance-Based Filtering:** "Show only locations within 5km"
2. **Turn-by-Turn Navigation:** Integrated maps SDK (not external app)
3. **Location Hours:** Different schedules per location
4. **Location-Specific Promotions:** See Task 1.4 requirements (already supported in schema)

---

## Questions & Answers

**Q: Why not calculate distance to nearest location on cards?**
A: Requires 2x Firestore reads (business list + all locations). Too expensive for list views. Primary location is acceptable UX compromise.

**Q: Why not add a 4th "Ubicaciones" tab?**
A: Locations are supporting info, not primary content. Integration in "Information" tab keeps UI clean and reduces tab clutter.

**Q: What if business has no primary location?**
A: Dashboard validation prevents this. Migration script sets first location as primary. Fallback: sort by `created_at` and use first.

**Q: Should we cache locations?**
A: Yes, in component state (`_locations`). Don't re-fetch on tab switch. Only fetch once per business details view.

---

## References

- **Firebase Schema V2:** `.claude/FIREBASE_SCHEMA_V2.md`
- **Dashboard Implementation:** See dashboard's `.claude/tasks/LOCATION_COUNT_AUTO_UPDATE.md`
- **Haversine Formula:** [Wikipedia](https://en.wikipedia.org/wiki/Haversine_formula)
- **Flutter Maps Integration:** [url_launcher package](https://pub.dev/packages/url_launcher)

---

**Implementation Owner:** Flutter Team
**Dashboard Dependency:** Backend auto-update trigger (required first)
**Estimated Completion:** Week 2, Day 3-4 (after backend ready)
