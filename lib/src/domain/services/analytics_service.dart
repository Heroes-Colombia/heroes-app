import 'dart:async';
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
/// OPTIMIZED V3:
/// - Single collection architecture (analytics_events only)
/// - Smart batching (time-based + count-based)
/// - 24-hour impression window (Meta/Facebook standard)
/// - Eliminated dual-write redundancy (50% write reduction)
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  bool _debugMode = false;

  // Smart batching configuration
  final List<Map<String, dynamic>> _eventQueue = [];
  static const int _maxBatchSize =
      50; // Increased from 20 for better efficiency
  static const Duration _flushInterval = Duration(
    seconds: 30,
  ); // Time-based flushing
  Timer? _flushTimer;

  late String _sessionId;
  String? _userId;
  Map<String, String>? _userContext;

  // 24-hour impression window (Meta/Facebook standard)
  // Prevents duplicate impressions while allowing daily re-engagement tracking
  final Map<String, DateTime> _impressionTimestamps = {};
  static const Duration _impressionWindow = Duration(hours: 24);

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

  /// Queue event for smart batching (time-based + count-based)
  /// Non-blocking: Uses timer-based flushing to prevent UI freezes
  void _queueEvent(Map<String, dynamic> eventData) {
    _eventQueue.add(eventData);

    // Start flush timer if not already running
    _flushTimer ??= Timer(_flushInterval, () {
      _processQueue();
    });

    // Flush immediately if batch is full (optimization for heavy users)
    if (_eventQueue.length >= _maxBatchSize) {
      _flushTimer?.cancel();
      _flushTimer = null;
      _processQueue();
    }
  }

  /// Process the event queue and batch write to Firestore
  /// Non-blocking: Runs async to prevent UI freezes
  void _processQueue() {
    if (_eventQueue.isEmpty) return;

    // Copy events and clear queue immediately (prevents race conditions)
    final eventsToWrite = List<Map<String, dynamic>>.from(_eventQueue);
    _eventQueue.clear();
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_debugMode) {
      log('📊 Analytics: Processing batch of ${eventsToWrite.length} events');
    }

    // Write batch asynchronously (non-blocking)
    _writeBatchToFirestore(eventsToWrite);
  }

  /// Write batch to Firestore with error recovery
  Future<void> _writeBatchToFirestore(List<Map<String, dynamic>> events) async {
    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('analytics_events');

      for (final eventData in events) {
        final docRef = collection.doc();
        batch.set(docRef, eventData);
      }

      await batch.commit();

      if (_debugMode) {
        log(
          '✅ Analytics: Successfully wrote ${events.length} events to analytics_events',
        );
      }
    } catch (e) {
      if (_debugMode) {
        log('❌ Analytics: Batch write failed - $e');
      }

      // Re-queue failed events (up to maxBatchSize to prevent infinite growth)
      if (_eventQueue.length < _maxBatchSize) {
        _eventQueue.addAll(events.take(_maxBatchSize - _eventQueue.length));
      }
    }
  }

  /// Flushes any remaining events in the queue
  /// Should be called when app is going to background or terminating
  Future<void> flushEvents() async {
    return _processQueue();
  }

  // ============================================================================
  // V3: Optimized Dashboard-Compatible Analytics Events
  // - Single collection architecture (analytics_events only)
  // - Smart batching (time + count based)
  // - 24-hour impression window (Meta/Facebook standard)
  // ============================================================================

  /// Track impression event (shown in feed/map)
  /// OPTIMIZED V3: 24-hour deduplication window (Meta/Facebook standard)
  /// - Prevents scroll bounce duplicates
  /// - Allows daily re-engagement tracking
  /// - Accurate conversion funnel metrics for Dashboard
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

    // Check if tracked recently (within 24-hour window)
    if (_impressionTimestamps.containsKey(impressionKey)) {
      final lastTracked = _impressionTimestamps[impressionKey]!;
      final timeSinceLastImpression = now.difference(lastTracked);

      if (timeSinceLastImpression < _impressionWindow) {
        // Within cooldown window - skip to prevent duplicates
        if (_debugMode) {
          final remainingHours =
              (_impressionWindow - timeSinceLastImpression).inHours;
          log(
            '📊 Impression cooldown active: $impressionKey (${remainingHours}h remaining)',
          );
        }
        return; // Skip duplicate impression
      }
    }

    // Update timestamp (either new or cooldown expired = daily re-engagement)
    _impressionTimestamps[impressionKey] = now;

    // Track the impression (queued for batching)
    _trackDashboardEvent(
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
  void trackDashboardView({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
    String? screen,
    Map<String, dynamic>? metadata,
  }) {
    _trackDashboardEvent(
      eventType: 'view',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
      screen: screen,
      metadata: metadata,
    );
  }

  /// Track save event (favorite button)
  void trackDashboardSave({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
    Map<String, dynamic>? metadata,
  }) {
    _trackDashboardEvent(
      eventType: 'save',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
      metadata: metadata,
    );
  }

  /// Track share event
  void trackDashboardShare({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
    Map<String, dynamic>? metadata,
  }) {
    _trackDashboardEvent(
      eventType: 'share',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
      metadata: metadata,
    );
  }

  /// Track click event (for heatmaps)
  void trackDashboardClick({
    required String entityType, // "business" | "promotion"
    required String entityId,
    String? businessId,
    String? locationId,
    String? screen,
    Map<String, dynamic>? metadata,
  }) {
    _trackDashboardEvent(
      eventType: 'click',
      entityType: entityType,
      entityId: entityId,
      businessId: businessId,
      locationId: locationId,
      screen: screen,
      metadata: metadata,
    );
  }

  /// Track redemption event (QR code scan)
  void trackDashboardRedemption({
    required String promotionId,
    required String businessId,
    String? locationId,
  }) {
    _trackDashboardEvent(
      eventType: 'redemption',
      entityType: 'promotion',
      entityId: promotionId,
      businessId: businessId,
      locationId: locationId,
    );
  }

  /// Internal method to queue Dashboard-compatible events for batching
  void _trackDashboardEvent({
    required String eventType,
    required String entityType,
    required String entityId,
    String? businessId,
    String? locationId,
    String? screen,
    Map<String, dynamic>? metadata,
  }) {
    try {
      // Get current user for user context
      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? _userId;

      // Build base metadata
      final baseMetadata = {
        'source': 'mobile_app',
        'screen': screen,
        'device': Platform.isIOS ? 'ios' : 'android',
      };

      // Merge with custom metadata if provided
      final mergedMetadata =
          metadata != null ? {...baseMetadata, ...metadata} : baseMetadata;

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
        'user_sex': _userContext?['sex'], // V3 demographic field
        'user_age_range': _userContext?['age_range'], // V3 demographic field
        // Business/Location Context (REQUIRED for filtering)
        'business_id': businessId,
        'location_id': locationId,

        // Session (OPTIONAL)
        'session_id': _sessionId,

        // Timestamp (REQUIRED)
        'timestamp': FieldValue.serverTimestamp(),

        // Metadata (OPTIONAL)
        'metadata': mergedMetadata,
      };

      // Remove null values to reduce document size
      eventData.removeWhere((key, value) => value == null);

      // Optimize metadata - remove null values and empty metadata
      if (eventData['metadata'] != null) {
        final metadata = eventData['metadata'] as Map<String, dynamic>;
        metadata.removeWhere((key, value) => value == null);

        // Remove metadata entirely if empty to save storage
        if (metadata.isEmpty) {
          eventData.remove('metadata');
        }
      }

      // Queue event for smart batching (non-blocking)
      _queueEvent(eventData);

      // Debug mode - print tracked events
      if (_debugMode) {
        log(
          '📊 Dashboard Analytics queued: $eventType | $entityType | $entityId',
        );
      }
    } catch (e) {
      // Silently fail - don't break user experience for analytics
      if (_debugMode) {
        log('⚠️ Dashboard analytics tracking failed: $e');
      }
    }
  }
}
