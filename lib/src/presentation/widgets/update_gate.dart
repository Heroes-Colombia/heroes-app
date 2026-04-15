import 'dart:io';
import 'package:flutter/material.dart';
import 'package:heroes_app/src/domain/services/force_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _androidStoreUrl =
    'https://play.google.com/store/apps/details?id=com.heroes.heroes_app';
const _iosStoreUrl =
    'https://apps.apple.com/app/heroes-colombia/id6740527898';

class UpdateGate extends StatefulWidget {
  final Widget child;
  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

const _dismissedVersionKey = 'soft_update_dismissed_version';

class _UpdateGateState extends State<UpdateGate> {
  late final Future<UpdateStatus> _statusFuture;
  // Tracked separately so dismissing immediately hides the banner
  // without re-fetching Remote Config.
  String _dismissedVersion = '';

  @override
  void initState() {
    super.initState();
    _statusFuture = _load();
  }

  Future<UpdateStatus> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _dismissedVersion = prefs.getString(_dismissedVersionKey) ?? '';
      });
    }
    return ForceUpdateService().checkStatus();
  }

  Future<void> _dismiss(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedVersionKey, version);
    if (mounted) setState(() => _dismissedVersion = version);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UpdateStatus>(
      future: _statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.child;
        }

        final status = snapshot.data ??
            const UpdateStatus(
              forceUpdate: false,
              softUpdate: false,
              latestVersion: '',
              latestVersionNotes: '',
            );

        // Force update: non-dismissible full screen.
        if (status.forceUpdate) {
          return const _ForceUpdateScreen();
        }

        // Soft update: show banner unless this exact version was already dismissed.
        final alreadyDismissed = _dismissedVersion == status.latestVersion;
        if (status.softUpdate && !alreadyDismissed) {
          return Stack(
            children: [
              widget.child,
              _SoftUpdateBanner(
                notes: status.latestVersionNotes,
                onDismiss: () => _dismiss(status.latestVersion),
              ),
            ],
          );
        }

        return widget.child;
      },
    );
  }
}

// ── Force update ──────────────────────────────────────────────────────────────

class _ForceUpdateScreen extends StatelessWidget {
  const _ForceUpdateScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.system_update,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Actualización requerida',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hay una nueva versión disponible con mejoras importantes. '
                  'Por favor actualiza la app para continuar.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Actualizar ahora'),
                  onPressed: _openStore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openStore() {
    final url = Platform.isIOS ? _iosStoreUrl : _androidStoreUrl;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

// ── Soft update banner ────────────────────────────────────────────────────────

class _SoftUpdateBanner extends StatelessWidget {
  final String notes;
  final VoidCallback onDismiss;

  const _SoftUpdateBanner({required this.notes, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        color: colorScheme.primaryContainer,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.new_releases_outlined,
                    color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nueva versión disponible',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          notes,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: _openStore,
                            child: const Text('Actualizar'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: colorScheme.onPrimaryContainer,
                            ),
                            onPressed: onDismiss,
                            child: const Text('Ahora no'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      size: 18, color: colorScheme.onPrimaryContainer),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openStore() {
    final url = Platform.isIOS ? _iosStoreUrl : _androidStoreUrl;
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
