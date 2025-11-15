import 'dart:developer';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

/// Analytics service for tracking user interactions and business metrics
///
/// This service provides comprehensive analytics tracking for the Heroes Colombia app,
/// including user behavior, business performance, and conversion metrics.
///
/// V2: Now also tracks events to 'analytics_events' collection for Dashboard consumption
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  bool _debugMode = false;
  final List<Map<String, dynamic>> _eventQueue = [];
  static const int _batchSize = 20;
  late String _sessionId;
  String? _userId;
  Map<String, String>? _userContext;

  // CRITICAL FIX: Track impressions with time-based deduplication (Facebook/Meta style)
  // Prevents scroll bounces while allowing re-engagement tracking
  final Map<String, DateTime> _impressionTimestamps = {};
  static const Duration _impressionWindow = Duration(minutes: 3);

  /// CRITICAL FIX: Initialize session immediately in constructor for anonymous users
  AnalyticsService._internal() {
    _sessionId = _uuid.v4(); // Generate session ID immediately
    if (_debugMode) {
      log('Analytics: Session created - $_sessionId');
    }
  }

  /// Update session context when user logs in (don't regenerate session ID)
  void initializeSession({String? userId, Map<String, String>? userContext}) {
    _userId = userId;
    _userContext = userContext;
    if (_debugMode) {
      log('Analytics: Session context updated - User: $_userId');
    }
  }

  /// Get the FirebaseAnalytics instance for external use
  FirebaseAnalytics get analytics => _analytics;

  /// Get the FirebaseAnalyticsObserver for route tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Enable debug mode to log analytics events without sending them to Firebase
  void enableDebugMode() {
    _debugMode = true;
    _analytics.setAnalyticsCollectionEnabled(true);
  }

  /// Disable debug mode and ensure analytics collection is enabled
  void disableDebugMode() {
    _debugMode = false;
    _analytics.setAnalyticsCollectionEnabled(true);
  }

  /// Store custom event in Firestore for business analytics
  Future<void> _storeCustomEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final eventData = {
        'event_name': eventName,
        'user_id': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'day_key': _getDayKey(DateTime.now()),
        'month_key': _getMonthKey(DateTime.now()),
        ...parameters,
      };

      _eventQueue.add(eventData);

      if (_eventQueue.length >= _batchSize) {
        await _processQueue();
      }
    } catch (e) {
      if (_debugMode) {
        log('Error storing custom event: $e');
      }
    }
  }

  /// Process the event queue and batch write to Firestore
  Future<void> _processQueue() async {
    if (_eventQueue.isEmpty) return;

    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('user_analytics');

      for (final eventData in _eventQueue) {
        final docRef = collection.doc();
        batch.set(docRef, eventData);
      }

      await batch.commit();
      _eventQueue.clear();

      if (_debugMode) {
        log('Analytics: Successfully processed ${_eventQueue.length} events');
      }
    } catch (e) {
      if (_debugMode) {
        log('Error processing analytics queue: $e');
      }
    }
  }

  /// Generate day key for analytics aggregation
  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Generate month key for analytics aggregation
  String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Track when a user views a business
  ///
  /// Parameters:
  /// - [businessId]: The unique identifier of the business
  /// - [businessName]: The name of the business
  /// - [category]: The category of the business
  /// - [location]: Optional location information
  /// - [searchContext]: Optional context if viewed from search
  Future<void> trackBusinessView({
    required String businessId,
    required String businessName,
    String? category,
    GeoPoint? location,
    String? searchContext,
  }) async {
    if (businessId.isEmpty || businessName.isEmpty) {
      log('Analytics Error: Invalid parameters for trackBusinessView');
      return;
    }

    if (_debugMode) {
      log('Analytics: Business view - $businessName');
    }

    await _analytics.logEvent(
      name: 'business_viewed',
      parameters: {
        'business_id': businessId,
        'business_name': businessName,
        if (category != null) 'category': category,
        if (searchContext != null) 'search_context': searchContext,
      },
    );

    await _storeCustomEvent('business_viewed', {
      'business_id': businessId,
      'business_name': businessName,
      'category': category,
      'location': location,
      'search_context': searchContext,
    });
  }

  /// Track business search activity
  ///
  /// Parameters:
  /// - [searchTerm]: The search query used
  /// - [resultsCount]: Number of results returned
  /// - [userLocation]: Optional user location for proximity analysis
  /// - [filters]: Optional filters applied
  Future<void> trackBusinessSearch({
    required String searchTerm,
    required int resultsCount,
    GeoPoint? userLocation,
    Map<String, dynamic>? filters,
  }) async {
    if (searchTerm.isEmpty) {
      log('Analytics Error: Empty search term in trackBusinessSearch');
      return;
    }

    if (_debugMode) {
      log('Analytics: Business search - "$searchTerm" returned $resultsCount results');
    }

    await _analytics.logEvent(
      name: 'business_search',
      parameters: {
        'search_term': searchTerm,
        'results_count': resultsCount,
        if (filters != null) 'filters_applied': filters.keys.join(','),
      },
    );

    await _storeCustomEvent('business_search', {
      'search_term': searchTerm,
      'results_count': resultsCount,
      'user_location': userLocation,
      'filters': filters,
    });
  }

  /// Track promotion interactions
  ///
  /// Parameters:
  /// - [promotionId]: The unique identifier of the promotion
  /// - [businessId]: The business offering the promotion
  /// - [businessName]: The name of the business
  /// - [action]: The action taken ('view', 'share', 'redeem')
  /// - [discountPercentage]: The discount percentage
  Future<void> trackPromotionView({
    required String promotionId,
    required String businessId,
    required String businessName,
    required int discountPercentage,
  }) async {
    if (promotionId.isEmpty || businessId.isEmpty || businessName.isEmpty) {
      log('Analytics Error: Invalid parameters for trackPromotionView');
      return;
    }

    if (_debugMode) {
      log('Analytics: Promotion view - $businessName ($discountPercentage% discount)');
    }

    await _analytics.logEvent(
      name: 'promotion_viewed',
      parameters: {
        'promotion_id': promotionId,
        'business_id': businessId,
        'business_name': businessName,
        'discount_percentage': discountPercentage,
      },
    );

    await _storeCustomEvent('promotion_viewed', {
      'promotion_id': promotionId,
      'business_id': businessId,
      'business_name': businessName,
      'discount_percentage': discountPercentage,
    });
  }

  /// Track promotion sharing
  Future<void> trackPromotionShare({
    required String promotionId,
    required String businessId,
    required String businessName,
    required String shareMethod,
  }) async {
    if (promotionId.isEmpty || businessId.isEmpty) {
      log('Analytics Error: Invalid parameters for trackPromotionShare');
      return;
    }

    if (_debugMode) {
      log('Analytics: Promotion shared - $businessName via $shareMethod');
    }

    await _analytics.logEvent(
      name: 'promotion_shared',
      parameters: {
        'promotion_id': promotionId,
        'business_id': businessId,
        'business_name': businessName,
        'share_method': shareMethod,
      },
    );

    await _storeCustomEvent('promotion_shared', {
      'promotion_id': promotionId,
      'business_id': businessId,
      'business_name': businessName,
      'share_method': shareMethod,
    });
  }

  /// Track promotion redemption
  Future<void> trackPromotionRedemption({
    required String promotionId,
    required String businessId,
    required String businessName,
    required int discountPercentage,
  }) async {
    if (promotionId.isEmpty || businessId.isEmpty) {
      log('Analytics Error: Invalid parameters for trackPromotionRedemption');
      return;
    }

    if (_debugMode) {
      log('Analytics: Promotion redeemed - $businessName ($discountPercentage% discount)');
    }

    await _analytics.logEvent(
      name: 'promotion_redeemed',
      parameters: {
        'promotion_id': promotionId,
        'business_id': businessId,
        'business_name': businessName,
        'discount_percentage': discountPercentage,
      },
    );

    await _storeCustomEvent('promotion_redeemed', {
      'promotion_id': promotionId,
      'business_id': businessId,
      'business_name': businessName,
      'discount_percentage': discountPercentage,
    });
  }

  /// Track when a user adds a business to favorites
  Future<void> trackFavoriteAdded({
    required String businessId,
    required String businessName,
    String? category,
  }) async {
    if (businessId.isEmpty || businessName.isEmpty) {
      log('Analytics Error: Invalid parameters for trackFavoriteAdded');
      return;
    }

    if (_debugMode) {
      log('Analytics: Favorite added - $businessName');
    }

    await _analytics.logEvent(
      name: 'favorite_added',
      parameters: {
        'business_id': businessId,
        'business_name': businessName,
        if (category != null) 'category': category,
      },
    );

    await _storeCustomEvent('favorite_added', {
      'business_id': businessId,
      'business_name': businessName,
      'category': category,
    });
  }

  /// Track when a user removes a business from favorites
  Future<void> trackFavoriteRemoved({
    required String businessId,
    required String businessName,
  }) async {
    if (businessId.isEmpty || businessName.isEmpty) {
      log('Analytics Error: Invalid parameters for trackFavoriteRemoved');
      return;
    }

    if (_debugMode) {
      log('Analytics: Favorite removed - $businessName');
    }

    await _analytics.logEvent(
      name: 'favorite_removed',
      parameters: {
        'business_id': businessId,
        'business_name': businessName,
      },
    );

    await _storeCustomEvent('favorite_removed', {
      'business_id': businessId,
      'business_name': businessName,
    });
  }

  /// Track nearby business searches with location intelligence
  Future<void> trackNearbyBusinessesSearch({
    required GeoPoint userLocation,
    required double radiusKm,
    required int resultsCount,
    String? category,
  }) async {
    if (_debugMode) {
      log('Analytics: Nearby search - ${radiusKm}km radius, $resultsCount results');
    }

    await _analytics.logEvent(
      name: 'nearby_search',
      parameters: {
        'radius_km': radiusKm,
        'results_count': resultsCount,
        if (category != null) 'category': category,
      },
    );

    await _storeCustomEvent('nearby_search', {
      'user_location': userLocation,
      'radius_km': radiusKm,
      'results_count': resultsCount,
      'category': category,
    });
  }

  /// Get business analytics for a specific business and date range
  ///
  /// Returns aggregated analytics data for business owners and admins
  Future<Map<String, dynamic>> getBusinessAnalytics({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
    DocumentSnapshot? lastDocument,
    int pageSize = 1000,
  }) async {
    try {
      // Input validation
      if (businessId.isEmpty) {
        log('Analytics Error: Invalid businessId for getBusinessAnalytics');
        return {};
      }

      if (endDate.isBefore(startDate)) {
        log(
          'Analytics Error: End date is before start date in getBusinessAnalytics',
        );
        return {};
      }

      if (_debugMode) {
        log(
          'Analytics: Getting business analytics for $businessId from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
        );
      }

      // First check if user has permission to access this business
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        log('Analytics Error: No authenticated user');
        return {};
      }

      // Check if user owns this business or is admin
      try {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (!userDoc.exists) {
          log('Analytics Error: User document not found');
          return {};
        }

        final userData = userDoc.data()!;
        final userType = userData['permission'] as String? ?? '';
        
        if (userType != 'business_owner' && userType != 'admin') {
          log('Analytics Error: User does not have permission to view analytics');
          return {};
        }

        // Additional check: if user is a business owner, verify they own this business
        if (userType == 'business_owner') {
          final businessDoc = await _firestore.collection('businesses').doc(businessId).get();
          if (!businessDoc.exists || businessDoc.data()!['user_id'] != currentUser.uid) {
            log('Analytics Error: Business owner can only view analytics for their own business');
            return {};
          }
        }
      } catch (permissionError) {
        log('Analytics Permission Error: $permissionError');
        return {};
      }

      // Build query with pagination
      Query<Map<String, dynamic>> query = _firestore
          .collection('user_analytics')
          .where('business_id', isEqualTo: businessId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      int views = 0;
      int promotionViews = 0;
      int favorites = 0;
      int shares = 0;
      int redemptions = 0;
      Set<String> uniqueUsers = {};

      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final String? eventName = data['event_name'] as String?;
        final String? userId = data['user_id'] as String?;

        if (eventName == null || userId == null) {
          continue;
        }

        uniqueUsers.add(userId);

        switch (eventName) {
          case 'business_viewed':
            views++;
            break;
          case 'promotion_viewed':
            promotionViews++;
            break;
          case 'favorite_added':
            favorites++;
            break;
          case 'promotion_shared':
            shares++;
            break;
          case 'promotion_redeemed':
            redemptions++;
            break;
          default:
            break;
        }
      }

      return {
        'total_views': views,
        'promotion_views': promotionViews,
        'favorites_added': favorites,
        'shares': shares,
        'redemptions': redemptions,
        'unique_users': uniqueUsers.length,
        'period_start': startDate.toIso8601String(),
        'period_end': endDate.toIso8601String(),
        'last_document': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        'has_more': snapshot.docs.length == pageSize,
      };
    } on FirebaseException catch (e) {
      log('Error getting business analytics: ${e.message ?? e.code}');
      return {};
    } catch (e) {
      log('Unexpected error in getBusinessAnalytics: $e');
      return {};
    }
  }

  /// Get user demographics for a specific business
  Future<Map<String, dynamic>> getUserDemographics({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Input validation
      if (businessId.isEmpty) {
        log(
          'Analytics Error: Invalid businessId for getUserDemographics',
        );
        return {};
      }

      if (_debugMode) {
        log('Analytics: Getting user demographics for business $businessId');
      }

      // Check permissions first
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        log('Analytics Error: No authenticated user');
        return {};
      }

      try {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (!userDoc.exists) {
          log('Analytics Error: User document not found');
          return {};
        }

        final userData = userDoc.data()!;
        final userType = userData['permission'] as String? ?? '';
        
        if (userType != 'business_owner' && userType != 'admin') {
          log('Analytics Error: User does not have permission to view demographics');
          return {
            'total_unique_users': 0,
            'user_types': {},
            'ranks': {},
            'regions': {},
          };
        }
      } catch (permissionError) {
        log('Analytics Permission Error in demographics: $permissionError');
        return {
          'total_unique_users': 0,
          'user_types': {},
          'ranks': {},
          'regions': {},
        };
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore
              .collection('user_analytics')
              .where('business_id', isEqualTo: businessId)
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'timestamp',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .get();

      Map<String, int> userTypes = {};
      Map<String, int> ranks = {};
      Map<String, int> regions = {};
      Set<String> uniqueUsers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['user_id'] as String?;

        if (userId == null) continue;

        if (!uniqueUsers.contains(userId)) {
          uniqueUsers.add(userId);

          // Get user details for demographics
          try {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              
              final userType = userData['user_type'] as String? ?? 'unknown';
              final rank = userData['military_rank'] as String? ?? 'N/A';
              final region = userData['region'] as String? ?? 'unknown';

              userTypes[userType] = (userTypes[userType] ?? 0) + 1;
              ranks[rank] = (ranks[rank] ?? 0) + 1;
              regions[region] = (regions[region] ?? 0) + 1;
            }
          } catch (e) {
            if (_debugMode) {
              log('Error getting user demographics for user $userId: $e');
            }
          }
        }
      }

      return {
        'total_unique_users': uniqueUsers.length,
        'user_types': userTypes,
        'ranks': ranks,
        'regions': regions,
      };
    } on FirebaseException catch (e) {
      log('Error getting user demographics: ${e.message ?? e.code}');
      return {};
    } catch (e) {
      log('Unexpected error in getUserDemographics: $e');
      return {};
    }
  }

  /// Flushes any remaining events in the queue
  /// Should be called when app is going to background or terminating
  Future<void> flushEvents() async {
    return _processQueue();
  }

  // ============================================================================
  // V2: Dashboard-Compatible Analytics Events
  // Tracks events to 'analytics_events' collection for Dashboard consumption
  // ============================================================================

  /// Track impression event (shown in feed/map)
  /// Matches Dashboard schema exactly
  /// CRITICAL FIX: Time-based deduplication (Facebook/Meta style)
  /// - Prevents scroll bounce duplicates (3-minute cooldown window)
  /// - Allows re-engagement tracking after cooldown period
  /// - Provides accurate conversion funnel metrics for Dashboard
  Future<void> trackDashboardImpression({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
    String? screen,
  }) async {
    // Create unique key for this impression (entity + context)
    final impressionKey = '$entityType:$entityId:${screen ?? "unknown"}';
    final now = DateTime.now();

    // Check if tracked recently (within 3-minute window)
    if (_impressionTimestamps.containsKey(impressionKey)) {
      final lastTracked = _impressionTimestamps[impressionKey]!;
      final timeSinceLastImpression = now.difference(lastTracked);

      if (timeSinceLastImpression < _impressionWindow) {
        // Within cooldown window - skip to prevent scroll bounce duplicates
        if (_debugMode) {
          final remainingSeconds = (_impressionWindow - timeSinceLastImpression).inSeconds;
          log('📊 Impression cooldown active: $impressionKey (${remainingSeconds}s remaining)');
        }
        return; // Skip duplicate impression
      }
    }

    // Update timestamp (either new or cooldown expired = re-engagement)
    _impressionTimestamps[impressionKey] = now;

    // Track the impression
    await _trackDashboardEvent(
      eventType: 'impression',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
      screen: screen,
    );

    if (_debugMode) {
      log('📊 Impression tracked: $impressionKey');
    }
  }

  /// Track view event (details page opened)
  /// Matches Dashboard schema exactly
  Future<void> trackDashboardView({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
    String? screen,
  }) async {
    await _trackDashboardEvent(
      eventType: 'view',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
      screen: screen,
    );
  }

  /// Track save event (favorite button)
  /// Matches Dashboard schema exactly
  Future<void> trackDashboardSave({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
  }) async {
    await _trackDashboardEvent(
      eventType: 'save',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
    );
  }

  /// Track share event
  /// Matches Dashboard schema exactly
  Future<void> trackDashboardShare({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
  }) async {
    await _trackDashboardEvent(
      eventType: 'share',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
    );
  }

  /// Track click event (for heatmaps)
  /// Matches Dashboard schema exactly
  Future<void> trackDashboardClick({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
    String? screen,
  }) async {
    await _trackDashboardEvent(
      eventType: 'click',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
      screen: screen,
    );
  }

  /// Track redemption event (QR code scan)
  /// Matches Dashboard schema exactly
  Future<void> trackDashboardRedemption({
    required String promotionId,
    required String businessId,
    String? locationId,
  }) async {
    await _trackDashboardEvent(
      eventType: 'redemption',
      entityType: 'promotion',
      entityId: promotionId,
      businessId: businessId,
      locationId: locationId,
    );
  }

  /// Internal method to write Dashboard-compatible events to Firestore
  /// Schema matches Dashboard expectations exactly
  Future<void> _trackDashboardEvent({
    required String eventType,
    required String entityType,
    required String entityId,
    String? businessId,
    String? locationId,
    String? screen,
  }) async {
    try {
      // Get current user for user context
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? _userId;

      // Build event data matching Dashboard schema
      final eventData = {
        // Event Classification (REQUIRED)
        'event_type': eventType,
        'entity_type': entityType,
        'entity_id': entityId,

        // User Context (OPTIONAL - but required for Pro+ analytics)
        'user_id': userId,
        'user_type': userId != null ? 'consumer' : 'anonymous',
        'user_rank': _userContext?['rank'],
        'user_city': _userContext?['city'],

        // Business/Location Context (REQUIRED for filtering)
        'business_id': businessId,
        'location_id': locationId,

        // Session (OPTIONAL)
        'session_id': _sessionId,

        // Timestamp (REQUIRED)
        'timestamp': FieldValue.serverTimestamp(),

        // Metadata (OPTIONAL)
        'metadata': {
          'source': 'mobile_app',
          'screen': screen,
          'device': Platform.isIOS ? 'ios' : 'android',
        },
      };

      // Remove null values to reduce document size
      eventData.removeWhere((key, value) => value == null);

      // CRITICAL FIX: Optimize metadata - remove null values and empty metadata
      if (eventData['metadata'] != null) {
        final metadata = eventData['metadata'] as Map<String, dynamic>;
        metadata.removeWhere((key, value) => value == null);

        // Remove metadata entirely if empty to save storage
        if (metadata.isEmpty) {
          eventData.remove('metadata');
        }
      }

      // Write to analytics_events collection for Dashboard
      await _firestore.collection('analytics_events').add(eventData);

      // Debug mode - print tracked events
      if (_debugMode) {
        log('📊 Dashboard Analytics: $eventType | $entityType | $entityId');
      }
    } catch (e) {
      // Silently fail - don't break user experience for analytics
      if (_debugMode) {
        log('⚠️ Dashboard analytics tracking failed: $e');
      }
    }
  }
}