import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/services/family_invitation_service.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';

@RoutePage()
class InviteFamilyView extends StatelessWidget {
  const InviteFamilyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Invitar Familia'), elevation: 0),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // Handle different states
          switch (state) {
            case ProfileInitial():
            case ProfileLoading():
              // If initial or loading, trigger load if needed and show loading
              if (state.user == null) {
                context.read<ProfileCubit>().getProfileInfo();
              }
              return const Center(child: CircularProgressIndicator());

            case ProfileLoaded():
              // Successfully loaded - check if user can invite family
              final user = state.user;
              if (user == null) {
                return _buildErrorView(
                  context,
                  theme,
                  'No se pudo cargar la información del usuario',
                );
              }

              if (!user.canInviteFamily) {
                return _buildErrorView(
                  context,
                  theme,
                  'Solo el personal militar puede invitar familiares',
                );
              }

              // User is valid - show the invite view
              return _InviteFamilyContent(user: user);

            default:
              // Error state
              return _buildErrorView(
                context,
                theme,
                'Error al cargar información. Intenta de nuevo.',
              );
          }
        },
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    ThemeData theme,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.router.maybePop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteFamilyContent extends StatefulWidget {
  final User user;

  const _InviteFamilyContent({required this.user});

  @override
  State<_InviteFamilyContent> createState() => _InviteFamilyContentState();
}

class _InviteFamilyContentState extends State<_InviteFamilyContent> {
  final _familyInvitationService = GetIt.instance<FamilyInvitationService>();
  String? _inviteCode;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInviteCode();
  }

  Future<void> _loadInviteCode() async {
    try {
      // Get or create invite code using the user from widget
      final code = await _familyInvitationService.getOrCreateInviteCode();

      if (!mounted) return;

      setState(() {
        _inviteCode = code;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _shareInviteCode() async {
    if (_inviteCode == null) return;

    const androidUrl =
        'https://play.google.com/store/apps/details?id=com.heroes.heroes_app';
    const iosUrl =
        'https://apps.apple.com/au/app/h%C3%A9roes-colombia/id6743999048';

    final message = '''
¡Hola! Te invito a Héroes Colombia 🎖️

Código de invitación: $_inviteCode

Descarga la app:
📱 iOS: $iosUrl
📱 Android: $androidUrl

Después de instalar, ingresa el código en el registro.
''';

    try {
      await Share.share(message, subject: 'Invitación a Héroes Colombia');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard() {
    if (_inviteCode == null) return;

    Clipboard.setData(ClipboardData(text: _inviteCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado al portapapeles'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show error if present
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error al cargar código', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _loadInviteCode();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading or content
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.family_restroom,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Invita a tu familia!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comparte tu código personal para que tu familia disfrute de promociones exclusivas',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Invite code display
          Text(
            'Tu código personal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _inviteCode ?? '',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copiar código',
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Share options
          Text(
            'Compartir invitación',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Share button
          ElevatedButton.icon(
            onPressed: _shareInviteCode,
            icon: const Icon(Icons.share),
            label: const Text('Compartir por WhatsApp, SMS, etc.'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cómo funciona',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionStep('1', 'Comparte tu código con tu familia'),
                _buildInstructionStep(
                  '2',
                  'Ellos descargan la app Héroes Colombia',
                ),
                _buildInstructionStep('3', 'Ingresan tu código al registrarse'),
                _buildInstructionStep(
                  '4',
                  '¡Listo! Pueden disfrutar de promociones exclusivas',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
