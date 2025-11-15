# Flutter App - Schema V2 Migration Guide

**Last Updated:** January 20, 2026
**Dashboard Status:** ✅ Complete (All migrations done)
**Flutter Status:** ⏳ Pending Migration

---

## 📋 What Changed in Backend (Already Done)

### ✅ Database Migrations Completed:

1. **Users Collection**
   - Added `user_type` field (`admin`, `consumer`, `business_team`)
   - Added `business_roles` array for team members
   - Kept `permission` field for backward compatibility

2. **Businesses Collection**
   - No breaking changes to parent document
   - Added `businesses/{id}/locations` subcollection

3. **Promotions Collection**
   - New collection created: `promotions`
   - Old collection preserved: `advertisements` (for rollback)
   - New fields: `location_ids`, `views_count`, `saves_count`

4. **Categories**
   - No migration needed - already uses simple IDs

5. **Security Rules**
   - Updated and deployed to production
   - App can still read with current code

---

## 🔴 Required Flutter App Updates

### Priority 1: Critical (Breaks without these)

#### 1. Update User Model
**File:** `lib/src/domain/models/user.dart`

Add new fields (optional, for future use):
```dart
class User {
  // Existing fields...
  final String permission; // Keep this (V1)

  // Add V2 fields
  final String? userType; // "admin" | "consumer" | "business_team"
  final List<BusinessRole>? businessRoles;

  // Constructor, fromJson, toJson updates...
}

class BusinessRole {
  final String businessId;
  final String role; // "owner" | "manager" | "staff"
  final List<String> permissions;
  final DateTime addedAt;
}
```

**Status:** Optional - App still works with V1 `permission` field

---

#### 2. Migrate from `advertisements` to `promotions`
**Files:**
- `lib/src/domain/repositories/firestore_service.dart`
- Any widgets/pages reading advertisements

**Changes:**
```dart
// OLD
final adsRef = firestore.collection('advertisements');

// NEW
final promosRef = firestore.collection('promotions');
```

**Field mapping:**
```dart
// All fields are the same EXCEPT:
business_id: // Same as before
location_ids: [] // NEW - empty array = all locations
views_count: 0 // NEW
saves_count: 0 // NEW
```

**Status:** ⚠️ REQUIRED - `advertisements` collection will be deleted after migration

---

### Priority 2: Enhanced Features (Optional)

#### 3. Support Multiple Locations
**File:** `lib/src/domain/models/business.dart`

```dart
class Business {
  // Existing fields - KEEP THESE
  final GeoPoint location; // Primary location (from parent doc)
  final String address;    // Primary address (from parent doc)

  // Add method to fetch locations subcollection
  Future<List<BusinessLocation>> getLocations() async {
    final snapshot = await firestore
      .collection('businesses')
      .doc(id)
      .collection('locations')
      .get();
    return snapshot.docs.map((doc) => BusinessLocation.fromJson(doc.data())).toList();
  }
}

class BusinessLocation {
  final String id;
  final String name;
  final bool isPrimary;
  final String type; // "physical" | "online"
  final String? address;
  final GeoPoint? location;
  final String status;
}
```

**Status:** Optional - Current map queries still work with parent location field

---

#### 4. Handle Location-Targeted Promotions
**File:** `lib/src/presentation/pages/dashboard/pages/search/promotion_details_view.dart`

```dart
class Promotion {
  final String businessId;
  final List<String> locationIds; // NEW FIELD

  // Check if promotion applies to a specific location
  bool appliesToLocation(String locationId) {
    return locationIds.isEmpty || locationIds.contains(locationId);
  }

  // Get applicable locations
  Future<List<BusinessLocation>> getApplicableLocations() async {
    if (locationIds.isEmpty) {
      // Applies to all locations
      return Business.getLocations(businessId);
    } else {
      // Fetch specific locations
      final locations = await Business.getLocations(businessId);
      return locations.where((loc) => locationIds.contains(loc.id)).toList();
    }
  }
}
```

**Status:** Optional - Backward compatible (empty array = all locations)

---

## 📝 Step-by-Step Migration Plan

### Step 1: Update Models (Low Risk)
1. Add optional V2 fields to User model
2. Add LocationIds field to Promotion model
3. Test that existing data still loads

### Step 2: Migrate Queries (Medium Risk)
1. Update FirestoreService to read from `promotions` instead of `advertisements`
2. Test thoroughly in dev/staging
3. Verify all promotion features still work

### Step 3: Test Compatibility (Critical)
1. Test with migrated backend data
2. Verify users can still login
3. Verify businesses still display
4. Verify promotions still show

### Step 4: Deploy
1. Deploy Flutter app update
2. Monitor for errors
3. Once stable, delete `advertisements` collection from backend

---

## 🔍 Testing Checklist

- [ ] User login still works (V1 + V2 schema)
- [ ] Business list loads correctly
- [ ] Business details show with primary location
- [ ] Promotions load from new `promotions` collection
- [ ] Search and filtering still work
- [ ] Map view shows businesses correctly
- [ ] Favorites still work
- [ ] Profile updates work

---

## ⚠️ Important Notes

1. **Backward Compatibility:** App currently works because:
   - Security rules allow public read of active businesses/promotions
   - Parent business documents still have location/address fields
   - V1 `permission` field still exists on users

2. **No Breaking Changes (Yet):**
   - Business parent document fields preserved
   - Users have both V1 and V2 fields
   - Old `advertisements` collection still exists

3. **When to Delete Old Data:**
   - Only delete `advertisements` collection AFTER Flutter app is migrated and tested
   - Do NOT delete V1 user fields (`permission`) - needed for backward compatibility

---

## 🔗 Reference Documents

- **Backend Schema:** `heroes-colombia-dashboard/.claude/FIREBASE_SCHEMA_V2.md`
- **Flutter App Docs:** `heroesapp/CLAUDE.md`
- **Dashboard Remaining Tasks:** `heroes-colombia-dashboard/.claude/REMAINING_TASKS.md`

---

**Next Steps:**
1. Review this migration guide
2. Start with Step 1 (Update Models)
3. Test each step thoroughly
4. Deploy when ready

**Questions?** Refer to FIREBASE_SCHEMA_V2.md for detailed field documentation.
