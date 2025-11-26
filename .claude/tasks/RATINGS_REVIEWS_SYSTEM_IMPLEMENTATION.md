# Ratings & Reviews System Implementation Plan (Option B)
## Full Separation: Ratings vs. Reviews

**Created**: January 20, 2025
**Target Completion**: Week 11-13 (April-May 2025)
**Effort**: 7-8 days
**Priority**: HIGH (Social proof is critical for marketplace trust)

---

## Executive Summary

This plan implements a **two-tier feedback system** separating quick ratings (5 seconds) from detailed reviews (2-3 minutes), following industry best practices from Rappi, Uber, and Airbnb.

**Key Benefits**:
- ✅ More users leave feedback (quick rating vs. lengthy review)
- ✅ Scalable (handles millions of ratings/reviews)
- ✅ Better UX (don't force users to write text)
- ✅ Richer data (understand satisfaction without reading text)
- ✅ Easier moderation (only reviews need approval, ratings auto-approved)

---

## Architecture Overview

### Three-Layer System

```
┌─────────────────────────────────────────────────────┐
│                  USER EXPERIENCE                     │
├─────────────────────────────────────────────────────┤
│  1. Quick Rating (⭐⭐⭐⭐⭐) - 5 seconds             │
│  2. Optional Review (+ photos) - 2-3 minutes        │
│  3. View Others' Reviews - Endless scroll           │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│               FIREBASE COLLECTIONS                   │
├─────────────────────────────────────────────────────┤
│  ratings/          → Quick star ratings (1-5)       │
│  reviews/          → Detailed text + photos         │
│  businesses/       → Denormalized summary           │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│              CLOUD FUNCTIONS (Auto)                  │
├─────────────────────────────────────────────────────┤
│  onRatingCreated   → Update business rating_average │
│  onReviewApproved  → Update business review_count   │
└─────────────────────────────────────────────────────┘
```

---

## Firebase Schema Design

### Collection 1: `ratings` (Quick Feedback)

**Purpose**: Lightweight, always-collected feedback after user interacts with business

```typescript
// Collection: ratings
{
  rating_id: string              // Auto-generated document ID
  business_id: string            // Reference to business
  user_id: string                // Reference to user
  rating: number                 // 1-5 stars (integer)

  // Context (for analytics)
  source: "after_visit" | "business_detail" | "prompt"
  device_type: "ios" | "android" | "web"

  // Metadata
  created_at: Timestamp
  updated_at: Timestamp?         // If user changes rating

  // Validation
  status: "active" | "deleted"   // Soft delete if user removes
}

// Firestore Indexes Required:
// - business_id ASC, created_at DESC
// - user_id ASC, business_id ASC (prevent duplicate ratings)
// - business_id ASC, rating DESC (find top-rated)
```

**Business Rules**:
- ✅ One rating per user per business (upsert pattern)
- ✅ User can change rating anytime
- ✅ No moderation needed (just stars, no abuse potential)
- ✅ Instant - updates business average in real-time

---

### Collection 2: `reviews` (Detailed Feedback)

**Purpose**: Rich, moderated content with text, photos, and social features

```typescript
// Collection: reviews
{
  review_id: string              // Auto-generated document ID
  business_id: string            // Reference to business
  user_id: string                // Reference to user

  // Rating (required even for reviews)
  rating: number                 // 1-5 stars (must match rating in ratings collection)

  // Content
  title: string?                 // Optional short title (e.g., "Great food!")
  comment: string                // Required text review (min 10 chars)
  photos: string[]?              // Array of Cloud Storage URLs

  // User Info (denormalized for display)
  user_display_name: string      // e.g., "TTE González"
  user_rank: string?             // e.g., "Teniente" (for badge display)
  user_verified: boolean         // Show "Verified Military" badge

  // Social Features
  helpful_count: number          // "X people found this helpful"
  helpful_users: string[]        // User IDs who marked helpful (prevent duplicates)

  // Moderation
  status: "pending" | "approved" | "rejected" | "flagged"
  moderation_reason: string?     // If rejected: "Spam", "Inappropriate", etc.
  moderated_by: string?          // Admin user ID
  moderated_at: Timestamp?

  // Metadata
  created_at: Timestamp
  updated_at: Timestamp?         // If user edits review
  edited: boolean                // Show "Edited" badge if true

  // Flags (for abuse reporting)
  flag_count: number             // Number of users who reported
  flagged_by: string[]           // User IDs who flagged
}

// Firestore Indexes Required:
// - business_id ASC, status ASC, created_at DESC
// - business_id ASC, helpful_count DESC (most helpful)
// - status ASC, created_at ASC (moderation queue)
// - user_id ASC, created_at DESC (user's review history)
```

**Business Rules**:
- ✅ Optional - user can rate without reviewing
- ✅ One review per user per business
- ✅ Requires moderation before display (status: pending → approved)
- ✅ User can edit within 48 hours of posting
- ✅ Photos optional (max 5 per review)
- ✅ Can be flagged by other users for moderation

---

### Collection 3: `businesses` (Denormalized Summary)

**Add these fields to existing Business model**:

```typescript
// Add to existing businesses collection
{
  // ... existing fields (name, location, etc.)

  // ===== NEW: Rating Summary (denormalized) =====
  rating_average: number?        // e.g., 4.3 (calculated from ratings collection)
  rating_count: number           // Total number of ratings
  rating_distribution: {         // For histogram display
    "5": number,                 // Count of 5-star ratings
    "4": number,
    "3": number,
    "2": number,
    "1": number
  }?

  // ===== NEW: Review Summary (denormalized) =====
  review_count: number           // Total approved reviews

  // ===== NEW: Recent Reviews (for preview) =====
  recent_reviews: Array<{        // Last 3 approved reviews
    review_id: string,
    user_display_name: string,
    rating: number,
    comment: string,             // Truncated to 150 chars
    created_at: Timestamp
  }>?

  // ===== NEW: Metadata =====
  last_rating_at: Timestamp?     // When last rating was received
  last_review_at: Timestamp?     // When last review was approved
}
```

**Why Denormalize?**
- 🚀 **Performance**: Show `★ 4.3 (127)` on business cards without querying ratings collection
- 💰 **Cost**: Avoid 1000s of reads when listing businesses
- 📊 **UX**: Instant display of rating histogram on detail page

**Update Strategy**:
- Cloud Functions auto-update on every rating/review change
- Recalculate `rating_average` from all ratings in `ratings` collection
- Update `recent_reviews` array when review is approved

---

## Flutter Model Updates

### Model 1: Rating Model (NEW)

```dart
// lib/src/domain/models/rating_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Rating extends Equatable {
  final String? id;              // Document ID
  final String businessId;
  final String userId;
  final int rating;              // 1-5 stars
  final String source;           // "after_visit" | "business_detail" | "prompt"
  final String deviceType;       // "ios" | "android"
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status;           // "active" | "deleted"

  const Rating({
    this.id,
    required this.businessId,
    required this.userId,
    required this.rating,
    this.source = 'business_detail',
    this.deviceType = 'android',
    required this.createdAt,
    this.updatedAt,
    this.status = 'active',
  });

  @override
  List<Object?> get props => [
        id,
        businessId,
        userId,
        rating,
        source,
        deviceType,
        createdAt,
        updatedAt,
        status,
      ];

  factory Rating.fromJson(Map<String, dynamic> json, String documentId) {
    return Rating(
      id: documentId,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      source: json['source'] as String? ?? 'business_detail',
      deviceType: json['device_type'] as String? ?? 'android',
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'user_id': userId,
      'rating': rating,
      'source': source,
      'device_type': deviceType,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'status': status,
    };
  }

  Rating copyWith({
    String? id,
    String? businessId,
    String? userId,
    int? rating,
    String? source,
    String? deviceType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Rating(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      source: source ?? this.source,
      deviceType: deviceType ?? this.deviceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}
```

---

### Model 2: Review Model (ENHANCED)

```dart
// lib/src/domain/models/review_model.dart
// REPLACE existing UserReview class with this:

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String? id;                    // Document ID
  final String businessId;
  final String userId;
  final int rating;                    // 1-5 stars
  final String? title;                 // Optional short title
  final String comment;                // Required text
  final List<String>? photos;          // Cloud Storage URLs

  // User info (denormalized)
  final String userDisplayName;        // "TTE González"
  final String? userRank;              // "Teniente"
  final bool userVerified;             // Show verified badge

  // Social features
  final int helpfulCount;              // Number of helpful votes
  final List<String> helpfulUsers;     // User IDs who found helpful

  // Moderation
  final String status;                 // "pending" | "approved" | "rejected" | "flagged"
  final String? moderationReason;
  final String? moderatedBy;
  final DateTime? moderatedAt;

  // Metadata
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool edited;

  // Flags
  final int flagCount;
  final List<String> flaggedBy;

  const Review({
    this.id,
    required this.businessId,
    required this.userId,
    required this.rating,
    this.title,
    required this.comment,
    this.photos,
    required this.userDisplayName,
    this.userRank,
    this.userVerified = false,
    this.helpfulCount = 0,
    this.helpfulUsers = const [],
    this.status = 'pending',
    this.moderationReason,
    this.moderatedBy,
    this.moderatedAt,
    required this.createdAt,
    this.updatedAt,
    this.edited = false,
    this.flagCount = 0,
    this.flaggedBy = const [],
  });

  @override
  List<Object?> get props => [
        id,
        businessId,
        userId,
        rating,
        title,
        comment,
        photos,
        userDisplayName,
        userRank,
        userVerified,
        helpfulCount,
        helpfulUsers,
        status,
        moderationReason,
        moderatedBy,
        moderatedAt,
        createdAt,
        updatedAt,
        edited,
        flagCount,
        flaggedBy,
      ];

  // Helper: Check if current user found this helpful
  bool isHelpfulBy(String userId) {
    return helpfulUsers.contains(userId);
  }

  // Helper: Check if current user flagged this
  bool isFlaggedBy(String userId) {
    return flaggedBy.contains(userId);
  }

  // Helper: Check if review is approved
  bool get isApproved => status == 'approved';

  // Helper: Format created date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? 'año' : 'años'}';
    }
  }

  factory Review.fromJson(Map<String, dynamic> json, String documentId) {
    return Review(
      id: documentId,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : null,
      userDisplayName: json['user_display_name'] as String,
      userRank: json['user_rank'] as String?,
      userVerified: json['user_verified'] as bool? ?? false,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      helpfulUsers: json['helpful_users'] != null
          ? List<String>.from(json['helpful_users'] as List)
          : [],
      status: json['status'] as String? ?? 'pending',
      moderationReason: json['moderation_reason'] as String?,
      moderatedBy: json['moderated_by'] as String?,
      moderatedAt: json['moderated_at'] != null
          ? (json['moderated_at'] as Timestamp).toDate()
          : null,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] as Timestamp).toDate()
          : null,
      edited: json['edited'] as bool? ?? false,
      flagCount: json['flag_count'] as int? ?? 0,
      flaggedBy: json['flagged_by'] != null
          ? List<String>.from(json['flagged_by'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'user_id': userId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'photos': photos,
      'user_display_name': userDisplayName,
      'user_rank': userRank,
      'user_verified': userVerified,
      'helpful_count': helpfulCount,
      'helpful_users': helpfulUsers,
      'status': status,
      'moderation_reason': moderationReason,
      'moderated_by': moderatedBy,
      'moderated_at': moderatedAt != null
          ? Timestamp.fromDate(moderatedAt!)
          : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
      'edited': edited,
      'flag_count': flagCount,
      'flagged_by': flaggedBy,
    };
  }

  Review copyWith({
    String? id,
    String? businessId,
    String? userId,
    int? rating,
    String? title,
    String? comment,
    List<String>? photos,
    String? userDisplayName,
    String? userRank,
    bool? userVerified,
    int? helpfulCount,
    List<String>? helpfulUsers,
    String? status,
    String? moderationReason,
    String? moderatedBy,
    DateTime? moderatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? edited,
    int? flagCount,
    List<String>? flaggedBy,
  }) {
    return Review(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userRank: userRank ?? this.userRank,
      userVerified: userVerified ?? this.userVerified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
      status: status ?? this.status,
      moderationReason: moderationReason ?? this.moderationReason,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      edited: edited ?? this.edited,
      flagCount: flagCount ?? this.flagCount,
      flaggedBy: flaggedBy ?? this.flaggedBy,
    );
  }
}
```

---

### Model 3: Business Model (ENHANCED)

```dart
// lib/src/domain/models/business_model.dart
// ADD these fields to existing Business class:

class Business extends Equatable {
  // ... all existing fields

  // ===== NEW: Rating fields =====
  final double? ratingAverage;      // e.g., 4.3
  final int ratingCount;            // Total ratings
  final Map<String, int>? ratingDistribution; // {"5": 80, "4": 20, ...}

  // ===== NEW: Review fields =====
  final int reviewCount;            // Total approved reviews
  final List<RecentReview>? recentReviews; // Last 3 approved reviews

  // ===== NEW: Metadata =====
  final DateTime? lastRatingAt;
  final DateTime? lastReviewAt;

  const Business({
    // ... existing params
    this.ratingAverage,
    this.ratingCount = 0,
    this.ratingDistribution,
    this.reviewCount = 0,
    this.recentReviews,
    this.lastRatingAt,
    this.lastReviewAt,
  });

  // Helper: Get star display string
  String get ratingDisplay {
    if (ratingAverage == null || ratingCount == 0) {
      return 'Sin calificaciones';
    }
    return '${ratingAverage!.toStringAsFixed(1)} ★';
  }

  // Helper: Get rating with count
  String get ratingWithCount {
    if (ratingAverage == null || ratingCount == 0) {
      return 'Sin calificaciones';
    }
    return '${ratingAverage!.toStringAsFixed(1)} ($ratingCount)';
  }

  // Helper: Check if has reviews
  bool get hasReviews => reviewCount > 0;

  // Helper: Check if has ratings
  bool get hasRatings => ratingCount > 0;

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      // ... existing fields

      ratingAverage: json['rating_average']?.toDouble(),
      ratingCount: json['rating_count'] as int? ?? 0,
      ratingDistribution: json['rating_distribution'] != null
          ? Map<String, int>.from(json['rating_distribution'])
          : null,
      reviewCount: json['review_count'] as int? ?? 0,
      recentReviews: json['recent_reviews'] != null
          ? (json['recent_reviews'] as List)
              .map((e) => RecentReview.fromJson(e))
              .toList()
          : null,
      lastRatingAt: json['last_rating_at'] != null
          ? (json['last_rating_at'] as Timestamp).toDate()
          : null,
      lastReviewAt: json['last_review_at'] != null
          ? (json['last_review_at'] as Timestamp).toDate()
          : null,
    );
  }
}

// Helper class for recent reviews preview
class RecentReview extends Equatable {
  final String reviewId;
  final String userDisplayName;
  final int rating;
  final String comment;          // Truncated to 150 chars
  final DateTime createdAt;

  const RecentReview({
    required this.reviewId,
    required this.userDisplayName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [reviewId, userDisplayName, rating, comment, createdAt];

  factory RecentReview.fromJson(Map<String, dynamic> json) {
    return RecentReview(
      reviewId: json['review_id'] as String,
      userDisplayName: json['user_display_name'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_display_name': userDisplayName,
      'rating': rating,
      'comment': comment,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
```

---

## User Experience Flows

### Flow 1: Quick Rating (5 seconds)

**Trigger Points**:
1. **After viewing business details** for > 30 seconds → Bottom sheet prompt
2. **After favoriting a business** → Immediate prompt
3. **Manual**: Tap "Rate" button on business detail page

**UI Flow**:
```
┌─────────────────────────────────────────┐
│  ¿Cómo calificas este negocio?          │
│                                          │
│        ⭐ ⭐ ⭐ ⭐ ⭐                    │
│       (Tap to select 1-5 stars)         │
│                                          │
│  [Maybe Later]  [Submit Rating]         │
└─────────────────────────────────────────┘
```

**Code Example**:
```dart
// lib/src/presentation/widgets/rating_prompt_sheet.dart

void showRatingPrompt(BuildContext context, String businessId, String businessName) {
  showModalBottomSheet(
    context: context,
    builder: (context) => RatingPromptSheet(
      businessId: businessId,
      businessName: businessName,
    ),
  );
}

class RatingPromptSheet extends StatefulWidget {
  final String businessId;
  final String businessName;

  const RatingPromptSheet({
    required this.businessId,
    required this.businessName,
    super.key,
  });

  @override
  State<RatingPromptSheet> createState() => _RatingPromptSheetState();
}

class _RatingPromptSheetState extends State<RatingPromptSheet> {
  int? selectedRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '¿Cómo calificas a ${widget.businessName}?',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                iconSize: 48,
                icon: Icon(
                  selectedRating != null && starValue <= selectedRating!
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    selectedRating = starValue;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tal vez luego'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: selectedRating == null
                      ? null
                      : () {
                          _submitRating(context);
                        },
                  child: const Text('Calificar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to full review page
              context.router.push(WriteReviewRoute(
                businessId: widget.businessId,
                initialRating: selectedRating ?? 5,
              ));
            },
            child: const Text('Escribir reseña completa'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating(BuildContext context) async {
    try {
      final userId = GetIt.instance<AuthService>().getUserId();

      final rating = Rating(
        businessId: widget.businessId,
        userId: userId,
        rating: selectedRating!,
        source: 'business_detail',
        createdAt: DateTime.now(),
      );

      await GetIt.instance<FirestoreService>().submitRating(rating);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Gracias por tu calificación!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
```

---

### Flow 2: Detailed Review (2-3 minutes)

**Trigger Points**:
1. **From rating prompt**: "Escribir reseña completa" button
2. **Business detail page**: "Escribir reseña" button
3. **After rating submitted**: "¿Quieres compartir más detalles?" prompt

**UI Flow**:
```
┌─────────────────────────────────────────┐
│  Escribe tu reseña                       │
│                                          │
│  Calificación: ⭐⭐⭐⭐⭐              │
│                                          │
│  Título (opcional)                       │
│  ┌────────────────────────────────────┐ │
│  │ Excelente comida                    │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Tu opinión (mín. 10 caracteres)        │
│  ┌────────────────────────────────────┐ │
│  │ La comida estuvo deliciosa y el    │ │
│  │ servicio fue excelente...          │ │
│  └────────────────────────────────────┘ │
│                                          │
│  Agregar fotos (opcional)                │
│  [📷] [📷] [+]                          │
│                                          │
│  [Cancelar]  [Enviar Reseña]            │
└─────────────────────────────────────────┘
```

---

### Flow 3: View Reviews (Infinite Scroll)

**Business Detail Page**:
```
┌─────────────────────────────────────────┐
│  [Business Header]                       │
│                                          │
│  ⭐ 4.3 (127 calificaciones)            │
│  📝 45 reseñas                          │
│                                          │
│  Distribución:                           │
│  5★ ████████████████████████ 80         │
│  4★ ██████ 20                           │
│  3★ ███ 15                              │
│  2★ █ 8                                 │
│  1★ █ 4                                 │
│                                          │
│  [Escribir Reseña]                      │
│                                          │
│  Ordenar: [Más recientes ▼]             │
│  - Más recientes                         │
│  - Más útiles                           │
│  - Mejor calificadas                     │
│  - Peor calificadas                      │
│                                          │
│  ┌───────────────────────────────────┐  │
│  │ ⭐⭐⭐⭐⭐ TTE González ✓       │  │
│  │ Hace 2 días                        │  │
│  │                                    │  │
│  │ "Excelente comida"                 │  │
│  │ La comida estuvo deliciosa...      │  │
│  │                                    │  │
│  │ [📷 Photo]                        │  │
│  │                                    │  │
│  │ 👍 5 personas encontraron útil     │  │
│  │ [¿Te fue útil?] [Reportar]        │  │
│  └───────────────────────────────────┘  │
│                                          │
│  [More reviews... infinite scroll]       │
└─────────────────────────────────────────┘
```

---

## Services Implementation

### Service: Rating Service

```dart
// lib/src/domain/services/rating_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/src/domain/models/rating_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authService = GetIt.instance<AuthService>();

  /// Submit or update a rating (upsert pattern)
  Future<void> submitRating(Rating rating) async {
    final userId = _authService.getUserId();

    // Check if user already rated this business
    final existingRating = await _firestore
        .collection('ratings')
        .where('business_id', isEqualTo: rating.businessId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingRating.docs.isNotEmpty) {
      // Update existing rating
      await existingRating.docs.first.reference.update({
        'rating': rating.rating,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } else {
      // Create new rating
      await _firestore.collection('ratings').add(rating.toJson());
    }
  }

  /// Get user's rating for a business
  Future<Rating?> getUserRating(String businessId) async {
    final userId = _authService.getUserId();

    final snapshot = await _firestore
        .collection('ratings')
        .where('business_id', isEqualTo: businessId)
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return Rating.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  /// Delete user's rating
  Future<void> deleteRating(String businessId) async {
    final userId = _authService.getUserId();

    final snapshot = await _firestore
        .collection('ratings')
        .where('business_id', isEqualTo: businessId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': 'deleted',
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get rating statistics for a business
  Future<Map<String, dynamic>> getBusinessRatingStats(String businessId) async {
    final snapshot = await _firestore
        .collection('ratings')
        .where('business_id', isEqualTo: businessId)
        .where('status', isEqualTo: 'active')
        .get();

    if (snapshot.docs.isEmpty) {
      return {
        'average': null,
        'count': 0,
        'distribution': {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0},
      };
    }

    final ratings = snapshot.docs.map((doc) => doc.data()['rating'] as int).toList();
    final distribution = <int, int>{};

    for (var rating in ratings) {
      distribution[rating] = (distribution[rating] ?? 0) + 1;
    }

    final average = ratings.reduce((a, b) => a + b) / ratings.length;

    return {
      'average': average,
      'count': ratings.length,
      'distribution': {
        '1': distribution[1] ?? 0,
        '2': distribution[2] ?? 0,
        '3': distribution[3] ?? 0,
        '4': distribution[4] ?? 0,
        '5': distribution[5] ?? 0,
      },
    };
  }
}
```

---

### Service: Review Service

```dart
// lib/src/domain/services/review_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _authService = GetIt.instance<AuthService>();

  /// Submit a new review
  Future<void> submitReview(Review review, List<File>? photoFiles) async {
    // Upload photos if provided
    List<String>? photoUrls;
    if (photoFiles != null && photoFiles.isNotEmpty) {
      photoUrls = await _uploadReviewPhotos(review.businessId, photoFiles);
    }

    // Create review with uploaded photo URLs
    final reviewWithPhotos = review.copyWith(photos: photoUrls);

    await _firestore.collection('reviews').add(reviewWithPhotos.toJson());
  }

  /// Upload review photos to Cloud Storage
  Future<List<String>> _uploadReviewPhotos(String businessId, List<File> photos) async {
    final userId = _authService.getUserId();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uploadedUrls = <String>[];

    for (int i = 0; i < photos.length; i++) {
      final ref = _storage.ref().child(
        'reviews/$businessId/$userId/${timestamp}_$i.jpg',
      );

      await ref.putFile(photos[i]);
      final url = await ref.getDownloadURL();
      uploadedUrls.add(url);
    }

    return uploadedUrls;
  }

  /// Get approved reviews for a business (paginated)
  Future<List<Review>> getBusinessReviews(
    String businessId, {
    int limit = 10,
    DocumentSnapshot? startAfter,
    String orderBy = 'created_at', // 'created_at' | 'helpful_count'
  }) async {
    var query = _firestore
        .collection('reviews')
        .where('business_id', isEqualTo: businessId)
        .where('status', isEqualTo: 'approved')
        .orderBy(orderBy, descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => Review.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get user's review for a business
  Future<Review?> getUserReview(String businessId) async {
    final userId = _authService.getUserId();

    final snapshot = await _firestore
        .collection('reviews')
        .where('business_id', isEqualTo: businessId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return Review.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  /// Mark review as helpful
  Future<void> markReviewHelpful(String reviewId) async {
    final userId = _authService.getUserId();
    final reviewRef = _firestore.collection('reviews').doc(reviewId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reviewRef);
      final helpfulUsers = List<String>.from(snapshot.data()?['helpful_users'] ?? []);

      if (helpfulUsers.contains(userId)) {
        // User already marked helpful - remove
        helpfulUsers.remove(userId);
      } else {
        // Add user to helpful list
        helpfulUsers.add(userId);
      }

      transaction.update(reviewRef, {
        'helpful_users': helpfulUsers,
        'helpful_count': helpfulUsers.length,
      });
    });
  }

  /// Flag review for moderation
  Future<void> flagReview(String reviewId, String reason) async {
    final userId = _authService.getUserId();
    final reviewRef = _firestore.collection('reviews').doc(reviewId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reviewRef);
      final flaggedBy = List<String>.from(snapshot.data()?['flagged_by'] ?? []);

      if (!flaggedBy.contains(userId)) {
        flaggedBy.add(userId);

        transaction.update(reviewRef, {
          'flagged_by': flaggedBy,
          'flag_count': flaggedBy.length,
          'status': flaggedBy.length >= 3 ? 'flagged' : snapshot.data()?['status'],
        });
      }
    });
  }

  /// Edit user's review (within 48 hours)
  Future<void> editReview(String reviewId, String newComment, String? newTitle) async {
    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    final snapshot = await reviewRef.get();

    if (!snapshot.exists) throw Exception('Review not found');

    final review = Review.fromJson(snapshot.data()!, snapshot.id);
    final hoursSinceCreation = DateTime.now().difference(review.createdAt).inHours;

    if (hoursSinceCreation > 48) {
      throw Exception('Cannot edit review after 48 hours');
    }

    await reviewRef.update({
      'comment': newComment,
      'title': newTitle,
      'edited': true,
      'updated_at': FieldValue.serverTimestamp(),
      'status': 'pending', // Re-submit for moderation
    });
  }
}
```

---

## Migration Script

```dart
// scripts/migrate_reviews_to_collections.dart

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateReviewsToCollections() async {
  final firestore = FirebaseFirestore.instance;

  print('Starting review migration...');

  // Get all businesses
  final businessesSnapshot = await firestore.collection('businesses').get();
  print('Found ${businessesSnapshot.docs.length} businesses');

  int totalReviewsMigrated = 0;
  int businessesWithReviews = 0;

  for (var businessDoc in businessesSnapshot.docs) {
    final businessId = businessDoc.id;
    final businessData = businessDoc.data();

    // Get embedded reviews
    final embeddedReviews = businessData['reviews'] ?? [];
    if (embeddedReviews.isEmpty) continue;

    businessesWithReviews++;
    print('\nMigrating ${embeddedReviews.length} reviews for business: ${businessData['name']}');

    // Track ratings for this business
    final ratingValues = <int>[];
    final ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final recentReviews = <Map<String, dynamic>>[];

    for (var review in embeddedReviews) {
      try {
        final rating = (review['rate'] as double).round();
        ratingValues.add(rating);
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;

        // 1. Create rating document
        await firestore.collection('ratings').add({
          'business_id': businessId,
          'user_id': review['user_id'],
          'rating': rating,
          'source': 'migration',
          'device_type': 'unknown',
          'created_at': review['created_at'] ?? FieldValue.serverTimestamp(),
          'status': 'active',
        });

        // 2. Create review document (if has comment)
        if (review['comment'] != null && (review['comment'] as String).isNotEmpty) {
          final reviewDoc = await firestore.collection('reviews').add({
            'business_id': businessId,
            'user_id': review['user_id'],
            'rating': rating,
            'title': null,
            'comment': review['comment'],
            'photos': null,
            'user_display_name': 'Usuario',  // Default - update later
            'user_rank': null,
            'user_verified': false,
            'helpful_count': 0,
            'helpful_users': [],
            'status': 'approved',  // Auto-approve migrated reviews
            'created_at': review['created_at'] ?? FieldValue.serverTimestamp(),
            'edited': false,
            'flag_count': 0,
            'flagged_by': [],
          });

          // Add to recent reviews (keep last 3)
          if (recentReviews.length < 3) {
            recentReviews.add({
              'review_id': reviewDoc.id,
              'user_display_name': 'Usuario',
              'rating': rating,
              'comment': (review['comment'] as String).substring(
                0,
                (review['comment'] as String).length > 150
                  ? 150
                  : (review['comment'] as String).length
              ),
              'created_at': review['created_at'] ?? FieldValue.serverTimestamp(),
            });
          }
        }

        totalReviewsMigrated++;
      } catch (e) {
        print('  Error migrating review: $e');
      }
    }

    // 3. Update business document with denormalized data
    final ratingAverage = ratingValues.isEmpty
      ? null
      : ratingValues.reduce((a, b) => a + b) / ratingValues.length;

    await businessDoc.reference.update({
      'rating_average': ratingAverage,
      'rating_count': ratingValues.length,
      'rating_distribution': {
        '1': ratingDistribution[1],
        '2': ratingDistribution[2],
        '3': ratingDistribution[3],
        '4': ratingDistribution[4],
        '5': ratingDistribution[5],
      },
      'review_count': recentReviews.length,
      'recent_reviews': recentReviews,
      'last_rating_at': FieldValue.serverTimestamp(),
      'last_review_at': recentReviews.isNotEmpty ? FieldValue.serverTimestamp() : null,

      // KEEP old reviews field for now (backup)
      'reviews_backup': embeddedReviews,
    });

    print('  ✓ Migrated ${ratingValues.length} ratings and ${recentReviews.length} reviews');
    print('  ✓ Average rating: ${ratingAverage?.toStringAsFixed(1)}');
  }

  print('\n=== Migration Complete ===');
  print('Businesses processed: ${businessesSnapshot.docs.length}');
  print('Businesses with reviews: $businessesWithReviews');
  print('Total reviews migrated: $totalReviewsMigrated');
  print('\nIMPORTANT: Run update_user_display_names.dart next to populate user names in reviews');
}

// Helper script: Update user display names in reviews
Future<void> updateUserDisplayNames() async {
  final firestore = FirebaseFirestore.instance;

  print('Updating user display names in reviews...');

  final reviewsSnapshot = await firestore
      .collection('reviews')
      .where('user_display_name', isEqualTo: 'Usuario')
      .get();

  print('Found ${reviewsSnapshot.docs.length} reviews to update');

  for (var reviewDoc in reviewsSnapshot.docs) {
    final review = reviewDoc.data();
    final userId = review['user_id'];

    try {
      // Get user data
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) continue;

      final userData = userDoc.data()!;
      final rank = userData['rank'] ?? '';
      final lastName = userData['first_last_name'] ?? '';

      // Format: "TTE González"
      final displayName = rank.isNotEmpty && lastName.isNotEmpty
          ? '${rank.split('_').last} $lastName'
          : 'Usuario';

      await reviewDoc.reference.update({
        'user_display_name': displayName,
        'user_rank': rank,
        'user_verified': userData['verified'] ?? false,
      });

      print('  ✓ Updated review ${reviewDoc.id}: $displayName');
    } catch (e) {
      print('  ✗ Error updating review ${reviewDoc.id}: $e');
    }
  }

  print('Display names updated!');
}

void main() async {
  await migrateReviewsToCollections();
  await updateUserDisplayNames();
}
```

---

## Cloud Functions (Auto-Update Denormalized Data)

```javascript
// functions/src/index.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

/**
 * When a rating is created/updated, recalculate business rating_average
 */
export const onRatingChanged = functions.firestore
  .document('ratings/{ratingId}')
  .onWrite(async (change, context) => {
    const ratingData = change.after.exists ? change.after.data() : null;

    // Get business ID
    const businessId = ratingData?.business_id || change.before.data()?.business_id;
    if (!businessId) return;

    // Get all active ratings for this business
    const ratingsSnapshot = await db
      .collection('ratings')
      .where('business_id', '==', businessId)
      .where('status', '==', 'active')
      .get();

    if (ratingsSnapshot.empty) {
      // No ratings - clear fields
      await db.collection('businesses').doc(businessId).update({
        rating_average: null,
        rating_count: 0,
        rating_distribution: null,
        last_rating_at: null,
      });
      return;
    }

    // Calculate average and distribution
    const ratings = ratingsSnapshot.docs.map(doc => doc.data().rating);
    const average = ratings.reduce((a, b) => a + b, 0) / ratings.length;

    const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    ratings.forEach(rating => {
      distribution[rating] = (distribution[rating] || 0) + 1;
    });

    // Update business document
    await db.collection('businesses').doc(businessId).update({
      rating_average: parseFloat(average.toFixed(2)),
      rating_count: ratings.length,
      rating_distribution: distribution,
      last_rating_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Updated business ${businessId}: ${average.toFixed(1)} stars (${ratings.length} ratings)`);
  });

/**
 * When a review is approved, update business review_count and recent_reviews
 */
export const onReviewApproved = functions.firestore
  .document('reviews/{reviewId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if status changed to approved
    if (before.status !== 'approved' && after.status === 'approved') {
      const businessId = after.business_id;

      // Get all approved reviews for this business
      const reviewsSnapshot = await db
        .collection('reviews')
        .where('business_id', '==', businessId)
        .where('status', '==', 'approved')
        .orderBy('created_at', 'desc')
        .limit(3)
        .get();

      const recentReviews = reviewsSnapshot.docs.map(doc => {
        const data = doc.data();
        return {
          review_id: doc.id,
          user_display_name: data.user_display_name,
          rating: data.rating,
          comment: data.comment.substring(0, 150), // Truncate
          created_at: data.created_at,
        };
      });

      // Count total approved reviews
      const totalReviewsSnapshot = await db
        .collection('reviews')
        .where('business_id', '==', businessId)
        .where('status', '==', 'approved')
        .count()
        .get();

      // Update business document
      await db.collection('businesses').doc(businessId).update({
        review_count: totalReviewsSnapshot.data().count,
        recent_reviews: recentReviews,
        last_review_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Updated business ${businessId}: ${totalReviewsSnapshot.data().count} reviews`);
    }
  });
```

---

## UI Components

### Component 1: Rating Stars Display

```dart
// lib/src/presentation/widgets/rating_stars.dart

import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? count;
  final double size;
  final bool showCount;

  const RatingStars({
    required this.rating,
    this.count,
    this.size = 16,
    this.showCount = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: size,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: size * 0.875,
          ),
        ),
        if (showCount && count != null) ...[
          Text(
            ' ($count)',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: size * 0.875,
            ),
          ),
        ],
      ],
    );
  }
}
```

---

### Component 2: Rating Distribution Chart

```dart
// lib/src/presentation/widgets/rating_distribution_chart.dart

import 'package:flutter/material.dart';

class RatingDistributionChart extends StatelessWidget {
  final Map<String, int> distribution;
  final int totalCount;

  const RatingDistributionChart({
    required this.distribution,
    required this.totalCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [5, 4, 3, 2, 1].map((stars) {
        final count = distribution[stars.toString()] ?? 0;
        final percentage = totalCount > 0 ? count / totalCount : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                '$stars★',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorForRating(stars),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 32,
                child: Text(
                  count.toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorForRating(int stars) {
    if (stars >= 4) return Colors.green;
    if (stars >= 3) return Colors.amber;
    return Colors.red;
  }
}
```

---

### Component 3: Review Card

```dart
// lib/src/presentation/widgets/review_card.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/domain/models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool currentUserId;
  final VoidCallback onHelpful;
  final VoidCallback onFlag;

  const ReviewCard({
    required this.review,
    required this.currentUserId,
    required this.onHelpful,
    required this.onFlag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User info + rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    review.userDisplayName[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userDisplayName,
                            style: theme.textTheme.titleSmall,
                          ),
                          if (review.userVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        review.formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Star rating
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title (if present)
            if (review.title != null && review.title!.isNotEmpty) ...[
              Text(
                review.title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Comment
            Text(
              review.comment,
              style: theme.textTheme.bodyMedium,
            ),

            // Photos (if present)
            if (review.photos != null && review.photos!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photos!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.photos![index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),

            // Actions
            Row(
              children: [
                // Helpful button
                TextButton.icon(
                  onPressed: onHelpful,
                  icon: Icon(
                    review.isHelpfulBy(currentUserId)
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    size: 16,
                  ),
                  label: Text(
                    review.helpfulCount > 0
                        ? '${review.helpfulCount} ${review.helpfulCount == 1 ? 'persona' : 'personas'} encontraron útil'
                        : '¿Te fue útil?',
                  ),
                ),
                const Spacer(),
                // Flag button
                IconButton(
                  onPressed: onFlag,
                  icon: Icon(
                    review.isFlaggedBy(currentUserId)
                        ? Icons.flag
                        : Icons.flag_outlined,
                    size: 18,
                  ),
                  tooltip: 'Reportar',
                ),
              ],
            ),

            // Edited badge
            if (review.edited) ...[
              const SizedBox(height: 4),
              Text(
                'Editado',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Implementation Timeline

### Week 11: Models & Services (3 days)
- [ ] Day 1: Create Rating model, Review model (enhanced)
- [ ] Day 2: Update Business model with new fields
- [ ] Day 3: Implement RatingService and ReviewService

### Week 12: UI & UX (3 days)
- [ ] Day 1: Rating prompt bottom sheet
- [ ] Day 2: Write review page with photo upload
- [ ] Day 3: Review list page with pagination

### Week 13: Migration & Polish (2 days)
- [ ] Day 1: Run migration script, deploy Cloud Functions
- [ ] Day 2: Update business cards to show ratings, test end-to-end

**Total: 8 days**

---

## Success Metrics

Track these metrics after launch:

### Engagement Metrics
- **Rating submission rate**: % of users who view a business and rate it (target: > 15%)
- **Review submission rate**: % of ratings that convert to reviews (target: > 25%)
- **Average rating per business**: Should stabilize around 4.0-4.5
- **Review approval time**: Admin should approve within 24 hours

### Quality Metrics
- **Photo attachment rate**: % of reviews with photos (target: > 30%)
- **Helpful votes per review**: Social proof indicator (target: > 5 per review)
- **Flag rate**: % of reviews flagged (should be < 2%)

### Business Impact
- **Businesses with ratings**: % of total businesses (target: > 80% by launch)
- **Conversion lift**: Do businesses with ratings get more favorites? (expect +30%)
- **Enterprise upgrade correlation**: Do highly-rated businesses upgrade more?

---

## Next Steps

1. **Review and approve this plan**
2. **Schedule implementation** in your roadmap (Week 11-13)
3. **Set up Cloud Functions project** (if not already done)
4. **Design review moderation dashboard** for admins

---

**Questions? Ready to implement? Let me know!** 🚀