import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/models/verification_models.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/email_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:heroes_app/src/domain/services/military_verification_service.dart';
import 'package:heroes_app/src/domain/repositories/firestorage_service.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Enum for signup steps
enum SignupStep { formEntry, militaryVerification, accountCreation, completed }

@RoutePage()
class SignUpView extends StatefulWidget {
  const SignUpView({super.key, required this.onResult});
  final Function(bool?) onResult;

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _pageController = PageController();
  final locator = GetIt.instance;
  
  // State management
  SignupStep _currentStep = SignupStep.formEntry;
  Map<String, dynamic> _formData = {};
  bool _isLoading = false;
  
  // Key to force form rebuild when returning with saved data
  GlobalKey<FormBuilderState> _formBuilderKey = GlobalKey<FormBuilderState>();
  
  // Military verification state
  final ImagePicker _imagePicker = ImagePicker();
  final MilitaryVerificationService _verificationService = MilitaryVerificationService();
  int _currentAttempt = 1;
  VerificationResult? _lastResult;

  @override
  void dispose() {
    _pageController.dispose();
    _verificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = locator.get<AppConstants>().authTexts['signupView']!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: _currentStep == SignupStep.formEntry,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep != SignupStep.formEntry) {
          _goToPreviousStep();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            texts['title']!,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: theme.textTheme.bodyLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: _currentStep != SignupStep.formEntry
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goToPreviousStep,
                )
              : null,
        ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(theme),
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              children: [
                _buildFormEntryStep(texts, theme),
                _buildMilitaryVerificationStep(texts, theme),
                _buildAccountCreationStep(texts, theme),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // Navigation method for back button
  void _goToPreviousStep() {
    if (_currentStep == SignupStep.militaryVerification) {
      setState(() {
        _currentStep = SignupStep.formEntry;
        // Force form rebuild with saved data by generating new key
        _formBuilderKey = GlobalKey<FormBuilderState>();
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == SignupStep.accountCreation) {
      setState(() {
        _currentStep = SignupStep.militaryVerification;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Progress indicator widget
  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(1, 'Información', _currentStep.index >= 0, theme),
          Expanded(child: _buildProgressLine(_currentStep.index >= 1, theme)),
          _buildStepIndicator(2, 'Verificación', _currentStep.index >= 1, theme),
          Expanded(child: _buildProgressLine(_currentStep.index >= 2, theme)),
          _buildStepIndicator(3, 'Cuenta', _currentStep.index >= 2, theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isCompleted, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          child: Center(
            child: isCompleted
              ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 18)
              : Text(
                  step.toString(),
                  style: TextStyle(
                    color: isCompleted 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted, ThemeData theme) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isCompleted 
        ? theme.colorScheme.primary 
        : theme.colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  // Step 1: Form Entry
  Widget _buildFormEntryStep(Map<String, String> texts, ThemeData theme) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formBuilderKey,
          initialValue: _formData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: "logo",
                child: SvgPicture.asset(
                  theme.brightness == Brightness.dark
                      ? 'assets/images/heroes_black_logo.svg'
                      : 'assets/images/heroes_white_logo.svg',
                  height: 50,
                  width: double.infinity,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // License and ID fields (not on iOS)
              if (!Platform.isIOS) ...[
                FormBuilderTextField(
                  name: 'license',
                  key: const Key('license'),
                  decoration: InputDecoration(
                    labelText: texts['license-label']!,
                    hintText: texts['license-hint']!,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => validateInputs(context, value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 12),
                FormBuilderTextField(
                  name: 'identification_card',
                  key: const Key('identification_card'),
                  decoration: InputDecoration(
                    labelText: texts['identification-card-label']!,
                    hintText: texts['identification-card-hint']!,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => validateInputs(context, value),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],
              
              // Name fields
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'first_name',
                      key: const Key('_register_first_name'),
                      decoration: InputDecoration(
                        labelText: texts['firstname-label']!,
                        hintText: texts['firstname-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => validateInputs(context, value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'second_name',
                      key: const Key('_register_second_name'),
                      decoration: InputDecoration(
                        labelText: texts['secondname-label']!,
                        hintText: texts['secondname-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Last name fields
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'first_last_name',
                      key: const Key('_register_last_name'),
                      decoration: InputDecoration(
                        labelText: texts['first-lastname-label']!,
                        hintText: texts['first-lastname-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => validateInputs(context, value),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'second_last_name',
                      decoration: InputDecoration(
                        labelText: texts['second-lastname-label']!,
                        hintText: texts['second-lastname-hint']!,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Rank dropdown
              FormBuilderDropdown(
                name: 'rank',
                key: const Key('_register_rank'),
                dropdownColor: theme.colorScheme.surface,
                decoration: InputDecoration(
                  labelText: texts['rank-label']!,
                  hintText: texts['rank-hint']!,
                  border: const OutlineInputBorder(),
                ),
                items: getRanks(context),
                validator: (value) => validateInputs(context, value),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 12),
              
              // Email field
              EmailInputWidget(
                keyName: 'signup_email',
                key: const Key('signup_email'),
                name: 'email',
                label: texts['email-label']!,
                hintText: texts['email-hint']!,
              ),
              const SizedBox(height: 12),
              
              // Password field
              PasswordInput(
                keyName: '_register_password',
                name: 'password',
                label: texts['password-label']!,
                hintText: texts['password-hint']!,
              ),
              const SizedBox(height: 24),
              
              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _proceedToVerification(texts),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continuar a Verificación'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 2: Military Verification (full implementation)
  Widget _buildMilitaryVerificationStep(Map<String, String> texts, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInstructionCard(theme),
          const SizedBox(height: 24),
          if (_lastResult != null) _buildResultCard(theme),
          const SizedBox(height: 24),
          _buildCameraButton(theme),
          if (_isLoading) _buildProcessingIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Ionicons.shield_checkmark, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Verificación de Identidad Militar',
                  style: theme.textTheme.titleMedium?.copyWith(
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
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Ionicons.shield_checkmark, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔒 Privacidad: Tu foto NO se almacena. Solo se usa para verificación temporal y se elimina automáticamente.',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    if (_lastResult == null) return const SizedBox.shrink();

    final result = _lastResult!;
    Color cardColor;
    IconData icon;
    String title;

    switch (result.status) {
      case VerificationStatus.approved:
        cardColor = Colors.green;
        icon = Icons.check_circle;
        title = '¡Verificación Exitosa!';
        break;
      case VerificationStatus.retryRequired:
        cardColor = Colors.orange;
        icon = Icons.warning;
        title = 'Verificación Parcial';
        break;
      case VerificationStatus.failed:
        cardColor = Colors.red;
        icon = Icons.error;
        title = 'Verificación Fallida';
        break;
      case VerificationStatus.manualReview:
        cardColor = Colors.blue;
        icon = Icons.pending;
        title = 'Revisión Manual Requerida';
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
                Icon(icon, color: cardColor),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: cardColor)),
              ],
            ),
            if (result.reason != null) ...[
              const SizedBox(height: 8),
              Text(result.reason!),
            ],
            if (result.mismatches.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Discrepancias encontradas:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._getRelevantMismatches(result.mismatches).map((mismatch) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text('• ${_getFieldDisplayName(mismatch.fieldName)}: "${mismatch.userInput}" vs "${mismatch.ocrExtracted}"'),
              )),
            ],
            const SizedBox(height: 12),
            Text('Puntuación: ${(result.matchScore * 100).toStringAsFixed(1)}%'),
            Text('Intento: ${result.attemptNumber}/3'),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _showImageSourceDialog(theme),
        icon: Icon(Ionicons.camera),
        label: Text(_currentAttempt == 1 
            ? 'Agregar Documento Militar' 
            : 'Reintentar Verificación ($_currentAttempt/3)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text('Procesando documento militar...', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Image source selection dialog
  void _showImageSourceDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Documento Militar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Ionicons.camera_outline, color: theme.colorScheme.primary),
                title: const Text('Tomar Foto'),
                subtitle: const Text('Usar la cámara para fotografiar el documento'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image_outline, color: theme.colorScheme.primary),
                title: const Text('Seleccionar de Galería'),
                subtitle: const Text('Elegir una foto existente'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Military verification methods
  Future<void> _takePhoto(ImageSource source) async {
    try {
      // Only request camera permission when using camera
      if (source == ImageSource.camera) {
        final permissionStatus = await Permission.camera.request();
        if (permissionStatus != PermissionStatus.granted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de cámara requerido')),
          );
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      // Convert form data to the required format
      final userEnteredData = <String, String>{};
      for (final entry in _formData.entries) {
        if (entry.value != null) {
          userEnteredData[entry.key] = entry.value.toString();
        }
      }

      final result = await _verificationService.verifyMilitaryIdentity(
        userEnteredData: userEnteredData,
        militaryIdImage: image,
        userId: 'temp_user_id', // We don't have a user ID yet
        attemptNumber: _currentAttempt,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _lastResult = result;
        // Only increment if not approved (so user can see current attempt number correctly)
        if (result.status != VerificationStatus.approved) {
          _currentAttempt++;
        }
      });

      // Handle the result
      if (result.status == VerificationStatus.approved) {
        // Move to account creation
        _proceedToAccountCreation();
      } else if (result.status == VerificationStatus.manualReview) {
        // Create user account for manual review and save image
        await _handleManualReview(image);
      } else if (_currentAttempt > 3) {
        // Max attempts reached - create user account for manual review
        await _handleManualReview(image);
      }
      // Otherwise, user can retry with the feedback shown
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Step 3: Account Creation
  Widget _buildAccountCreationStep(Map<String, String> texts, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('Creando tu cuenta...', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          ] else ...[
            Icon(Icons.person_add, size: 70, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text('Crear Cuenta', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text('Verificación completa. Crea tu cuenta y accede a todas las promociones que tenemos para ti.', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _createAccount(texts),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text('Crear Cuenta'),
            ),
          ],
        ],
      ),
    );
  }

  // Navigation methods
  Future<void> _proceedToVerification(Map<String, String> texts) async {
    // Get the current FormBuilder state using the dynamic key
    final formBuilderState = _formBuilderKey.currentState;
    if (formBuilderState == null) return;
    
    // Validate form
    final formIsValid = formBuilderState.saveAndValidate();
    if (!formIsValid) return;

    // Save form data
    final rawFormData = formBuilderState.value;
    _formData = <String, dynamic>{};
    
    for (final entry in rawFormData.entries) {
      if (entry.value != null && entry.value.toString().isNotEmpty) {
        _formData[entry.key] = entry.value;
      }
    }

    // Check if email already exists before proceeding
    final email = _formData['email']?.toString();
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un email válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = locator.get<AuthService>();
      final emailExists = await authService.isEmailRegistered(email);
      
      if (!mounted) return;
      
      if (emailExists) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este correo electrónico ya está registrado. Usa otro email o inicia sesión.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Email is available, proceed to verification
      setState(() {
        _isLoading = false;
        _currentStep = SignupStep.militaryVerification;
      });
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage = 'Error al verificar el email';
      if (e.toString().contains('Email format is invalid')) {
        errorMessage = 'El formato del email no es válido';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _proceedToAccountCreation() {
    setState(() {
      _currentStep = SignupStep.accountCreation;
    });
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _createAccount(Map<String, String> texts) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = User.toInitialFirebaseJson(_formData, null);
      final result = await context.read<AuthCubit>().signUp(userData);

      if (!mounted) return;

      if (result.success) {
        // Success - navigate to dashboard
        locator.get<AppMethods>().showDialogAlert(
          context,
          "¡Cuenta Creada!",
          "Tu cuenta ha sido creada exitosamente. Ya puedes acceder a todas las promociones.",
          "Continuar",
          () => AutoRouter.of(context).replaceAll([DashBoardView()]),
        );
      } else {
        // Error creating account
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Error creando la cuenta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleManualReview(XFile militaryIdImage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account with pending status for manual review
      final userData = User.toInitialFirebaseJson(_formData, null);
      
      // Override status to pending and active to false for manual review
      userData['status'] = 'pending';
      userData['active'] = false;
      userData['verified'] = false;
      userData['requires_manual_review'] = true;
      
      final result = await context.read<AuthCubit>().signUp(userData);

      if (!mounted) return;

      if (result.success) {
        // Upload the military ID image for admin review
        try {
          final fireStorageService = locator.get<FireStorageService>();
          final userId = result.userId;
          
          if (userId != null) {
            await fireStorageService.uploadUserIdentification(militaryIdImage, userId);
          }
        } catch (e) {
          // Log error but don't fail the whole process - image upload is not critical
        }

        // Show manual review message and navigate to unverified user view
        if (!mounted) return;
        locator.get<AppMethods>().showDialogAlert(
          context,
          "Revisión Manual Requerida",
          "Tu documento será revisado por nuestro equipo en 24-48 horas. Te notificaremos por email cuando esté listo.",
          "Entendido",
          () => AutoRouter.of(context).replaceAll([UnverifiedUserView()]),
        );
      } else {
        // Registration failed - show error and go back to login
        if (!mounted) return;
        locator.get<AppMethods>().showDialogAlert(
          context,
          "Error en el registro",
          result.errorMessage ?? "No se pudo crear la cuenta. Intenta nuevamente.",
          "Entendido",
          () => AutoRouter.of(context).replaceAll([LoginView(onResult: (callback) {})]),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar revisión manual: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Navigate back to login on error
      AutoRouter.of(context).replaceAll([LoginView(onResult: (callback) {})]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to filter out duplicate and irrelevant mismatches
  List<FieldMismatch> _getRelevantMismatches(List<FieldMismatch> allMismatches) {
    // Priority order: show most user-relevant comparisons only
    final relevantFields = ['identification', 'first_name', 'apellidos_compound'];
    final filteredMismatches = <FieldMismatch>[];
    
    for (final field in relevantFields) {
      final mismatch = allMismatches.firstWhere(
        (m) => m.fieldName == field,
        orElse: () => FieldMismatch(fieldName: '', userInput: '', ocrExtracted: '', similarity: 1.0),
      );
      
      if (mismatch.fieldName.isNotEmpty && mismatch.similarity < 0.8) {
        filteredMismatches.add(mismatch);
      }
    }
    
    return filteredMismatches;
  }
  
  // Helper method to translate field names to user-friendly Spanish
  String _getFieldDisplayName(String fieldName) {
    switch (fieldName) {
      case 'identification':
        return 'Número de identificación';
      case 'first_name':
        return 'Nombres';
      case 'apellidos_compound':
        return 'Apellidos';
      case 'first_last_name':
        return 'Primer apellido';
      case 'second_last_name':
        return 'Segundo apellido';
      default:
        return fieldName; // Fallback to original name
    }
  }

  // Validation method
  String? validateInputs(BuildContext context, String? value) {
    final texts = locator.get<AppConstants>().authTexts['signupView']!;
    final message = locator.get<AppMethods>().emptyStringValidator(
      value,
      texts['genericValidator']!,
    );
    return message;
  }

  //This method is used to get the ranks from the constants file
  List<DropdownMenuItem<String>> getRanks(BuildContext context) {
    List<DropdownMenuItem<String>> dropdownItems = [];
    var theme = Theme.of(context);
    var locator = GetIt.instance;
    var ranksMap = locator.get<AppConstants>().ranks;

    ranksMap.forEach((category, subCategories) {
      String categoryValue = "Category_$category";
      dropdownItems.add(
        DropdownMenuItem(
          enabled: false,
          value: categoryValue,
          child: Text(
            locator.get<AppMethods>().capitalize(category),
            style: TextStyle(
              fontSize: theme.textTheme.bodyLarge!.fontSize,
              fontWeight: theme.textTheme.labelLarge!.fontWeight,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );

      subCategories.forEach((subCategory, options) {
        String subCategoryValue = "SubCategory_$subCategory";
        dropdownItems.add(
          DropdownMenuItem(
            enabled: false,
            value: subCategoryValue,
            child: Container(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                locator.get<AppMethods>().capitalize(subCategory),
                style: TextStyle(
                  fontSize: theme.textTheme.labelMedium!.fontSize,
                  fontWeight: theme.textTheme.labelLarge!.fontWeight,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        );

        for (var option in options) {
          String optionValue = option;
          dropdownItems.add(
            DropdownMenuItem(
              value: "${category}_${subCategory}_$optionValue",
              child: Container(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  locator.get<AppMethods>().capitalize(option),
                  style: TextStyle(
                    fontSize: theme.textTheme.labelMedium!.fontSize,
                    fontWeight: theme.textTheme.labelLarge!.fontWeight,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }
      });

      dropdownItems.add(
        DropdownMenuItem(
          value: "",
          enabled: false,
          child: Container(
            width: double.infinity,
            height: 1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    });

    return dropdownItems;
  }

}
