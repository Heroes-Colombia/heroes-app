import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Set to true locally to preview the force update screen without Firebase.
const bool debugForceUpdate = false;

// Set to true locally to preview the soft update banner without Firebase.
const bool debugSoftUpdate = false;

// Pass release notes at run time without touching the codebase:
// flutter run --dart-define=DEBUG_VERSION_NOTES="Your message here"
const String _debugVersionNotes = String.fromEnvironment(
  'DEBUG_VERSION_NOTES',
  defaultValue: 'Nueva versión disponible para descargar',
);

class UpdateStatus {
  final bool forceUpdate;
  final bool softUpdate;
  final String latestVersion;
  final String latestVersionNotes;

  const UpdateStatus({
    required this.forceUpdate,
    required this.softUpdate,
    required this.latestVersion,
    required this.latestVersionNotes,
  });
}

class ForceUpdateService {
  static const _minVersionKey = 'min_required_version';
  static const _latestVersionKey = 'latest_version';
  static const _latestVersionNotesKey = 'latest_version_notes';

  Future<UpdateStatus> checkStatus() async {
    // Debug overrides for local testing (only active in debug builds).
    if (kDebugMode && debugForceUpdate) {
      return const UpdateStatus(
        forceUpdate: true,
        softUpdate: false,
        latestVersion: 'debug',
        latestVersionNotes: _debugVersionNotes,
      );
    }
    if (kDebugMode && debugSoftUpdate) {
      return const UpdateStatus(
        forceUpdate: false,
        softUpdate: true,
        latestVersion: 'debug',
        latestVersionNotes: _debugVersionNotes,
      );
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await remoteConfig.setDefaults({
        _minVersionKey: '0.0.0',
        _latestVersionKey: '0.0.0',
        _latestVersionNotesKey: '',
      });

      await remoteConfig.fetchAndActivate();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final minVersion = remoteConfig.getString(_minVersionKey);
      final latestVersion = remoteConfig.getString(_latestVersionKey);
      final notes = remoteConfig.getString(_latestVersionNotesKey);

      return UpdateStatus(
        forceUpdate: _isVersionBelow(currentVersion, minVersion),
        softUpdate: _isVersionBelow(currentVersion, latestVersion),
        latestVersion: latestVersion,
        latestVersionNotes: notes,
      );
    } catch (_) {
      // If Remote Config is unreachable, never block the user.
      return const UpdateStatus(
        forceUpdate: false,
        softUpdate: false,
        latestVersion: '',
        latestVersionNotes: '',
      );
    }
  }

  // Returns true if [current] is strictly less than [minimum].
  bool _isVersionBelow(String current, String minimum) {
    final currentParts = _parseParts(current);
    final minimumParts = _parseParts(minimum);
    for (var i = 0; i < 3; i++) {
      if (currentParts[i] < minimumParts[i]) return true;
      if (currentParts[i] > minimumParts[i]) return false;
    }
    return false;
  }

  List<int> _parseParts(String version) {
    final parts = version.split('.');
    return List.generate(
      3,
      (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0,
    );
  }
}
