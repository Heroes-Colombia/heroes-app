import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/verification_models.dart';
import 'package:heroes_app/src/domain/services/military_verification_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class MilitaryVerificationView extends StatefulWidget {
  final Map<String, String> userEnteredData;
  final String userId;

  const MilitaryVerificationView({
    super.key,
    required this.userEnteredData,
    required this.userId,
  });

  @override
  State<MilitaryVerificationView> createState() =>
      _MilitaryVerificationViewState();
}

class _MilitaryVerificationViewState extends State<MilitaryVerificationView> {
  final GetIt locator = GetIt.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final MilitaryVerificationService _verificationService =
      MilitaryVerificationService();

  int _currentAttempt = 1;
  VerificationResult? _lastResult;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'MilitaryVerificationView: initState called. User ID: ${widget.userId}',
    );
  }

  @override
  void dispose() {
    debugPrint('MilitaryVerificationView: dispose called');
    _verificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MilitaryVerificationView: build method started.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación Militar'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionCard(),
            const SizedBox(height: 24),
            if (_lastResult != null) _buildResultCard(),
            const Spacer(),
            _buildCameraButton(),
            if (_isProcessing) _buildProcessingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Ionicons.shield_checkmark,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Verificación de Identidad Militar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Para verificar tu identidad militar, usa ÚNICAMENTE tu documento oficial que incluya:',
            ),
            const SizedBox(height: 8),
            _buildRequirementsList(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Ionicons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NO uses cédula de ciudadanía regular. Debe ser documento militar oficial.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_currentAttempt > 1) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Ionicons.information_circle,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Intento $_currentAttempt de ${MilitaryVerificationService.maxAttempts}',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsList() {
    return Column(
      children: [
        _buildRequirementItem('✓ "MINISTERIO DE DEFENSA NACIONAL"'),
        _buildRequirementItem('✓ "POLICIA NACIONAL" (o institución militar)'),
        _buildRequirementItem('✓ "Grado del titular" con tu rango militar'),
        _buildRequirementItem('✓ Tu nombre completo e identificación'),
      ],
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    if (_lastResult == null) return const SizedBox.shrink();

    final result = _lastResult!;
    Color cardColor;
    IconData iconData;
    String title;

    switch (result.status) {
      case VerificationStatus.approved:
        cardColor = Colors.green;
        iconData = Ionicons.checkmark_circle;
        title = '¡Verificación Exitosa!';
        break;
      case VerificationStatus.retryRequired:
        cardColor = Colors.orange;
        iconData = Ionicons.warning;
        title = 'Intenta Nuevamente';
        break;
      case VerificationStatus.manualReview:
        cardColor = Colors.blue;
        iconData = Ionicons.time;
        title = 'Revisión Manual';
        break;
      case VerificationStatus.failed:
        cardColor = Colors.red;
        iconData = Ionicons.close_circle;
        title = 'Verificación Fallida';
        break;
    }

    return Card(
      color: cardColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: cardColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.reason ?? 'Sin información adicional'),
            if (result.mismatches.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Campos que no coinciden:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...result.mismatches.map(
                (mismatch) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '• ${mismatch.fieldName}: ${(mismatch.similarity * 100).toStringAsFixed(0)}% coincidencia',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Puntuación general: ${(result.matchScore * 100).toStringAsFixed(0)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    String buttonText;
    bool isEnabled = !_isProcessing;

    if (_currentAttempt == 1) {
      buttonText = 'Tomar Foto del Documento Militar';
    } else if (_currentAttempt <= MilitaryVerificationService.maxAttempts) {
      buttonText =
          'Intentar Nuevamente ($_currentAttempt/${MilitaryVerificationService.maxAttempts})';
    } else {
      buttonText = 'Máximo de Intentos Alcanzado';
      isEnabled = false;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? _takePicture : null,
        icon: Icon(_isProcessing ? Icons.hourglass_empty : Ionicons.camera),
        label: Text(buttonText),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Procesando documento...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    if (_currentAttempt > MilitaryVerificationService.maxAttempts) {
      _navigateToManualReview();
      return;
    }

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se requiere permiso de cámara para verificar el documento',
          ),
        ),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al tomar la foto: $e')));
    }
  }

  Future<void> _processImage(XFile image) async {
    setState(() {
      _isProcessing = true;
    });
    debugPrint(
      'MilitaryVerificationView: _processImage started. Attempt: $_currentAttempt',
    );

    try {
      final result = await _verificationService.verifyMilitaryIdentity(
        userEnteredData: widget.userEnteredData,
        militaryIdImage: image,
        userId: widget.userId,
        attemptNumber: _currentAttempt,
      );
      debugPrint(
        'MilitaryVerificationService returned result: ${result.status}, Score: ${result.matchScore}',
      );

      setState(() {
        _lastResult = result;
        _isProcessing = false;
      });

      await _handleVerificationResult(result);
    } catch (e) {
      debugPrint(
        'MilitaryVerificationView: Error during verification in _processImage: $e',
      );
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error durante la verificación: $e')),
      );
      // Even if there's an error, we should still pop back to the previous screen
      // or handle it gracefully to avoid leaving the user stuck.
      // For now, we'll let the outer try-catch in signup_view handle navigation if this throws.
    }
  }

  Future<void> _handleVerificationResult(VerificationResult result) async {
    debugPrint(
      'MilitaryVerificationView: _handleVerificationResult called with status: ${result.status}',
    );
    switch (result.status) {
      case VerificationStatus.approved:
        debugPrint(
          'MilitaryVerificationView: Status approved. Popping with result.',
        );
        await _showSuccessDialog();
        break;
      case VerificationStatus.retryRequired:
        debugPrint(
          'MilitaryVerificationView: Status retryRequired. Incrementing attempt.',
        );
        setState(() {
          _currentAttempt++;
        });
        break;
      case VerificationStatus.manualReview:
        debugPrint(
          'MilitaryVerificationView: Status manualReview. Popping with result.',
        );
        await _showManualReviewDialog();
        break;
      case VerificationStatus.failed:
        debugPrint(
          'MilitaryVerificationView: Status failed. Current attempt: $_currentAttempt, Max attempts: ${MilitaryVerificationService.maxAttempts}',
        );
        if (_currentAttempt < MilitaryVerificationService.maxAttempts) {
          setState(() {
            _currentAttempt++;
          });
        } else {
          debugPrint(
            'MilitaryVerificationView: Max attempts reached for failed status. Popping with result.',
          );
          await _showManualReviewDialog(); // This will pop to login
        }
        break;
    }
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    debugPrint('MilitaryVerificationView: Showing success dialog.');
    locator.get<AppMethods>().showDialogAlert(
      context,
      "¡Cuenta Verificada!",
      "Tu identidad militar ha sido verificada exitosamente. Ya puedes acceder a todas las promociones.",
      "Continuar",
      () {
        debugPrint(
          'MilitaryVerificationView: Success dialog confirmed. Popping to SignUpView.',
        );
        Navigator.of(context).pop(_lastResult);
      },
    );
  }

  Future<void> _showManualReviewDialog() async {
    if (!mounted) return;
    debugPrint('MilitaryVerificationView: Showing manual review dialog.');
    locator.get<AppMethods>().showDialogAlert(
      context,
      "Revisión Manual Requerida",
      "Tu documento será revisado por nuestro equipo en 24-48 horas. Te notificaremos por email cuando esté listo.",
      "Entendido",
      () {
        debugPrint(
          'MilitaryVerificationView: Manual review dialog confirmed. Popping to SignUpView with result.',
        );
        Navigator.of(context).pop(_lastResult);
      },
    );
  }

  void _navigateToManualReview() {
    debugPrint(
      'MilitaryVerificationView: Navigating to manual review (popping with result).',
    );
    Navigator.of(context).pop(_lastResult);
  }

  void _navigateToLogin() {
    debugPrint(
      'MilitaryVerificationView: Navigating to login (popping with result).',
    );
    Navigator.of(context).pop(_lastResult);
  }
}
