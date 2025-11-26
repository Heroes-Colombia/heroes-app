import 'dart:developer';

/// In-memory cache service with TTL support for API responses.
/// Used to reduce unnecessary Firestore reads and improve app performance.
class CacheService {
  final Map<String, _CacheEntry> _cache = {};

  /// Default TTL of 5 minutes
  static const Duration defaultTTL = Duration(minutes: 5);

  /// Get cached data if valid, returns null if expired or not found
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      log('Cache MISS: $key');
      return null;
    }

    if (entry.isExpired) {
      log('Cache EXPIRED: $key');
      _cache.remove(key);
      return null;
    }

    log('Cache HIT: $key');
    return entry.data as T;
  }

  /// Store data in cache with optional custom TTL
  void set<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      data: data,
      expiry: DateTime.now().add(ttl ?? defaultTTL),
    );
    log('Cache SET: $key (expires in ${(ttl ?? defaultTTL).inMinutes} min)');
  }

  /// Check if a valid cache entry exists
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      return false;
    }
    return true;
  }

  /// Invalidate a specific cache entry
  void invalidate(String key) {
    _cache.remove(key);
    log('Cache INVALIDATED: $key');
  }

  /// Invalidate all entries matching a prefix (e.g., 'businesses_')
  void invalidatePrefix(String prefix) {
    final keysToRemove = _cache.keys.where((k) => k.startsWith(prefix)).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    log('Cache INVALIDATED prefix: $prefix (${keysToRemove.length} entries)');
  }

  /// Clear all cached data
  void clear() {
    _cache.clear();
    log('Cache CLEARED');
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> get stats => {
    'totalEntries': _cache.length,
    'validEntries': _cache.values.where((e) => !e.isExpired).length,
    'expiredEntries': _cache.values.where((e) => e.isExpired).length,
  };
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry({required this.data, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Cache keys for consistent key naming
class CacheKeys {
  static const String featuredBusinesses = 'businesses_featured';
  static const String normalBusinesses = 'businesses_normal';
  static const String onlineBusinesses = 'businesses_online';
  static const String businessCategories = 'business_categories';
  static const String featuredPromotions = 'promotions_featured';

  static String businessDetails(String id) => 'business_$id';
  static String promotionDetails(String id) => 'promotion_$id';
}
