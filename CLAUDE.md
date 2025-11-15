# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Plan & Review
- Always in plan mode to make a plan.
- After getting the plan, make sure you write the plan to .claude/tasks/TASK_NAME.md.
- The plan should be a detailed implementation plan and the reasoning behind them, as well as tasks broken down.
- If the task requires external knowledge or certain package, also research to get latest knowledge (use Task tool for research)
- Do not over plan it, always think MVP.
- Once you write the plan, firstly ask me to review it. Do not continue until I approve the plan.

### While implementing
- You should update the plan as you work.
- After you complete tasks in the plan, you should update and append detailed descriptions of the changes you made, so following tasks can be easily handed over to other engineers.

---

## Project Overview

**Heroes Colombia Mobile App** is a Flutter application that serves as the **consumer-facing platform** for military personnel and government employees in Colombia to discover local businesses offering special promotions and discounts. The app features location-based business discovery with Google Maps integration.

**Role Evolution:**
- **Previous (V1)**: Attempted to handle both consumer browsing AND business management
- **Current (V2)**: **Consumer-only focus** - Browse, view, favorite, and redeem promotions
- **Future (V3)**: Will add team member redemption processing (staff use app to scan/verify)

**⚠️ IMPORTANT - Business Management:**
Business owners now use the **Dashboard** (Next.js web app) to manage their businesses. The Flutter app NO LONGER handles business CRUD operations. However, **DO NOT REMOVE existing business management code** - it will be enhanced later for staff redemption features.

---

## Source of Truth

**This app's data structure MUST match:**
1. **Website** ([heroes-colombia-website](../heroes-colombia-website)) - Handles trial sign-ups and marketing
2. **Dashboard** ([heroes-colombia-dashboard](../heroes-colombia-dashboard)) - Handles business management
3. **Firebase Schema V2** - See `dashboard/.claude/FIREBASE_SCHEMA_V2.md`

**Key principle:** Dashboard and Website are authoritative for business data. Flutter app is read-only consumer of that data.

---

## Development Commands

### Build and Development
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub deps` - Show dependency tree

### Code Quality
- `flutter analyze` - Run static analysis
- `flutter test` - Run unit tests
- `flutter pub run build_runner build` - Generate code (auto_route, freezed, etc.)

### Version Management
- `./ios/update_version.sh` - Script to sync iOS version with pubspec.yaml version

---

## Architecture Overview

### Clean Architecture Structure (Maintained)
The project follows clean architecture principles with these main layers:

- **Domain Layer** (`lib/src/domain/`):
  - `models/` - Data models (Business, User, Promotion, etc.)
  - `repositories/` - Abstract interfaces for data access
  - `services/` - Business logic services (Analytics, Places)

- **Presentation Layer** (`lib/src/presentation/`):
  - `cubits/` - BLoC state management using Cubit pattern
  - `pages/` - UI screens organized by feature
  - `widgets/` - Reusable UI components

- **Configuration** (`lib/src/config/`):
  - `router/` - AutoRoute navigation configuration
  - `app_themes.dart` - Theme definitions

### State Management
- **Primary**: Flutter BLoC with Cubit pattern
- **Cubits**: Organized by feature (auth, business, profile, map, etc.)
- **Global State**: MultiBlocProvider in `main.dart` provides app-wide cubits

### Dependency Injection
- **Container**: GetIt (singleton pattern)
- **Setup**: `lib/src/locator.dart` registers all dependencies
- **Services**: Firebase services, repositories, utilities

### Navigation
- **Router**: AutoRoute with nested routes
- **Guards**: AuthGuard for protected routes
- **Structure**:
  - Entry point (`/`)
  - Auth flows (`/welcome`)
  - User dashboard (`/dashboard`) - protected (CONSUMER VIEW)
  - Business dashboard (`/businessDashboard`) - DEPRECATED (use web dashboard instead)
  - Individual pages with custom transitions

---

## Firebase Integration (Schema V2)

### Collections Used by Flutter App

**READ-ONLY Collections (consume data created by Dashboard/Website):**

#### 1. `businesses/`
```dart
{
  name: String
  identification: String
  email: String
  phone_number: String
  address: String
  location: GeoPoint
  geo_hash: { geohash: String, geopoint: GeoPoint }
  category_ids: List<String>  // ⚠️ CHANGED: Was string array, now IDs
  status: String  // "pending" | "active" | "inactive"
  featured: bool
  featured_image: String
  owner_name: String
  owner_uid: String
  plan: String  // "gratis" | "basico" | "pro" | "enterprise"
}
```

**Subcollection:** `businesses/{businessId}/locations/`
```dart
{
  name: String
  is_primary: bool
  type: String  // "physical" | "online"
  address: String?
  location: GeoPoint?
  geo_hash: Map?
  status: String
  created_at: Timestamp
}
```

#### 2. `promotions/` (previously `advertisements`)
```dart
{
  business_id: String
  title: String
  description: String
  instructions: String
  percentage: int
  featured_image: String
  location_ids: List<String>  // ⚠️ NEW: Targets specific locations or [] = all
  expired_at: Timestamp
  status: String  // "draft" | "pending" | "active" | "inactive" | "expired"
  is_featured: bool
  views_count: int?
  saves_count: int?
  created_at: Timestamp
}
```

#### 3. `business_categories/`
```dart
{
  category_id: String  // e.g., "restaurant"
  name: String
  icon_url: String
  status: String
  sort_order: int
}
```

**READ-WRITE Collections (user actions):**

#### 4. `users/`
```dart
{
  uid: String
  email: String
  user_type: String  // "consumer" | "business_team"

  // Consumer fields (military personnel)
  first_name: String?
  second_name: String?
  first_last_name: String?
  second_last_name: String?
  identification_card: String?
  license: String?
  rank: String?
  favourite_businesses: List<String>  // Business IDs
  device_notification_token: String?

  // Business team fields (for future redemption processing)
  business_roles: List<Map>?  // [{ business_id, role, permissions }]

  status: String  // "pending" | "active" | "rejected"
  verified: bool
  created_at: Timestamp
}
```

#### 5. `redemptions/` (Phase 2 - Future)
```dart
{
  promotion_id: String
  business_id: String
  location_id: String?
  user_id: String
  user_military_id: String
  redeemed_at: Timestamp
  redemption_method: String  // "manual" | "qr_code"
  processed_by: String?  // Staff user ID
  status: String
}
```

---

## Feature Modules & Implementation Status

### ✅ Phase 1: Consumer Features (IMPLEMENT NOW - Week 2)

#### 1. **Authentication** (`lib/src/presentation/pages/auth/`)
- ✅ Login for military personnel
- ✅ Signup with military ID verification
- ✅ Password recovery
- ⚠️ Business signup - KEEP CODE but redirect to website in UI

#### 2. **Dashboard** (`lib/src/presentation/pages/dashboard/`)
**Consumer-facing features:**
- ✅ Home feed with featured businesses/promotions
- ✅ Search businesses by name, category, location
- ✅ Browse by categories
- ✅ View business details
- ✅ View promotion details
- ✅ Favorite businesses (save to user profile)
- ✅ Map view with nearby businesses (geospatial queries)
- ✅ Profile management (update military info)

#### 3. **Maps & Location** (`lib/src/presentation/pages/dashboard/pages/map/`)
- ✅ Interactive map with business markers
- ✅ Geospatial queries (find nearby businesses)
- ✅ Navigate to business location (Google Maps/Waze integration)
- ✅ Filter by category on map

#### 4. **Search & Discovery** (`lib/src/presentation/pages/dashboard/pages/search/`)
- ✅ Search delegate for businesses
- ✅ Category filtering
- ✅ Sort by distance, rating, newest
- ✅ View all businesses list
- ✅ View business details with multiple locations

---

### 🔒 Phase 2: Enhanced Consumer Features (PLANNED - Future)

#### 5. **Redemption System** (Future Implementation)
- ⏳ View QR code for promotion redemption
- ⏳ Show digital military ID card
- ⏳ Redemption history
- ⏳ Track savings/benefits

#### 6. **Social Features** (Future Implementation)
- ⏳ Review businesses (write, view)
- ⏳ Rate businesses
- ⏳ Share promotions with friends
- ⏳ Report issues

#### 7. **Notifications** (Partially Implemented)
- ✅ Push notification setup (FCM token storage)
- ⏳ Receive promotion notifications
- ⏳ Favorite business alerts
- ⏳ Nearby business notifications

---

### 🚫 Deprecated: Business Management Features

**⚠️ IMPORTANT:** These features are NOW handled by the **web dashboard**. Do NOT remove code, but mark as deprecated and guide users to dashboard.

#### Business Dashboard Pages (`lib/src/presentation/pages/business_dashboard/`)
- ❌ `owned_businesses_view.dart` - List businesses (redirect to dashboard)
- ❌ `owned_business_details_view.dart` - Manage business (redirect to dashboard)
- ❌ `business_analytics_view.dart` - View analytics (redirect to dashboard)
- ⏳ **FUTURE USE:** Staff will use these pages for in-store redemption processing

**Migration Strategy:**
1. Show banner: "Manage your business on the web dashboard at app.heroescolombia.com"
2. Provide deep link to dashboard
3. Keep code but disable editing features
4. In future, repurpose for staff redemption workflow

---

## Data Model Updates (V1 → V2 Migration)

### ⚠️ CRITICAL: User Permission/Type Schema

**IMPORTANT:** The user schema uses BOTH `permission` (V1) and `user_type` (V2) for backward compatibility:

#### Current V1 Schema (Flutter App - DO NOT REMOVE):
```dart
{
  "permission": "admin" | "beneficiary" | "business" | "user"  // KEEP THIS
}
```

#### New V2 Schema (Dashboard + Flutter - ADD THIS):
```dart
{
  "permission": "admin" | "beneficiary" | "business" | "user"  // V1 - Keep for compatibility
  "user_type": "admin" | "consumer" | "business_team"          // V2 - New field
  "business_roles"?: [                                          // V2 - Only for business_team
    {
      business_id: String
      role: "owner" | "manager" | "staff"
      permissions: List<String>
      added_at: Timestamp
    }
  ]
}
```

#### Migration Mapping:
- `permission: "admin"` → `user_type: "admin"`
- `permission: "beneficiary"` → `user_type: "consumer"`
- `permission: "user"` → `user_type: "consumer"`
- `permission: "business"` → `user_type: "business_team"` (+ add `business_roles` array)

**Migration Script:** Run `node scripts/migrate-user-types.js` in the dashboard project.

**Flutter App Changes Needed:**
1. ✅ Keep reading `permission` field (existing code works)
2. ⏳ Add `user_type` field to User model (optional, for future use)
3. ⏳ Add `business_roles` field to User model (for staff features in Phase 2)

### Breaking Changes

#### 1. **Collection Rename: `advertisements` → `promotions`**
```dart
// OLD (V1)
final ads = await firestore.collection('advertisements').get();

// NEW (V2)
final promotions = await firestore.collection('promotions').get();
```

#### 2. **Business Categories: Strings → IDs**
```dart
// OLD (V1)
class Business {
  final List<String> categories; // ["restaurant", "gym"]
}

// NEW (V2)
class Business {
  final List<String> categoryIds; // ["cat_restaurant_001", "cat_gym_002"]

  // Helper to resolve category names
  Future<List<BusinessCategory>> getCategories() async {
    final cats = await firestore
      .collection('business_categories')
      .where(FieldPath.documentId, whereIn: categoryIds)
      .get();
    return cats.docs.map((doc) => BusinessCategory.fromJson(doc.data())).toList();
  }
}
```

#### 3. **Multiple Locations per Business**
```dart
// OLD (V1) - Single location in business document
class Business {
  final GeoPoint location;
  final String address;
}

// NEW (V2) - Locations subcollection
class Business {
  final GeoPoint location;  // Primary location (denormalized for performance)
  final String address;     // Primary location address

  // Fetch all locations
  Future<List<BusinessLocation>> getLocations() async {
    final locs = await firestore
      .collection('businesses')
      .doc(id)
      .collection('locations')
      .get();
    return locs.docs.map((doc) => BusinessLocation.fromJson(doc.data())).toList();
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

#### 4. **Promotion Location Targeting**
```dart
// OLD (V1) - Promotion belonged to single business
class Promotion {
  final String businessId;
}

// NEW (V2) - Promotion can target specific locations
class Promotion {
  final String businessId;
  final List<String> locationIds; // Empty = all locations

  bool appliesToLocation(String locationId) {
    return locationIds.isEmpty || locationIds.contains(locationId);
  }
}
```

---

## Week 2 Implementation Plan

**See:** `.claude/tasks/WEEK2_FLUTTER_APP_MIGRATION.md` (will be created next)

**Priority Tasks:**
1. Update models to match Schema V2
2. Migrate queries from `advertisements` to `promotions`
3. Add location subcollection support
4. Implement category ID resolution
5. Add "Managed on Dashboard" banners
6. Test consumer features thoroughly

**Timeline:** January 20-24, 2026

---

**Last Updated:** January 20, 2026
**Schema Version:** V2 (Backend migrated, Flutter app pending update)
**Dashboard Alignment:** ✅ Complete
**Backend Migrations:** ✅ All Complete (users, locations, promotions, security rules)
**Flutter Migration Status:** ⏳ Pending - See `.claude/tasks/SCHEMA_V2_MIGRATION_GUIDE.md`
