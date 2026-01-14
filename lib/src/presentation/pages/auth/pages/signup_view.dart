import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:heroes_app/src/domain/models/user_model.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/presentation/widgets/password_input_widget.dart';
import 'package:heroes_app/src/presentation/widgets/searchable_rank_selector.dart';
import 'package:heroes_app/src/presentation/widgets/sex_toggle_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/services/family_invitation_service.dart';
import 'package:intl/intl.dart';

// Enum for 4-step signup flow with clear optional steps
enum SignupStep { account, personalDetails, familyInvitation, preferences }

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
  SignupStep _currentStep = SignupStep.account;
  Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  // Form keys for each step
  final _accountFormKey = GlobalKey<FormBuilderState>();
  final _personalDetailsFormKey = GlobalKey<FormBuilderState>();
  final _familyInvitationFormKey = GlobalKey<FormBuilderState>();
  final _preferencesFormKey = GlobalKey<FormBuilderState>();

  // Categories state
  List<BusinessCategory> _allCategories = [];
  List<String> _selectedCategories = [];

  // Invite code state (for beneficiaries joining via invite)
  final _inviteCodeController = TextEditingController();
  String? _invitedByMilitaryUid;
  String? _selectedRelationship;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('business_categories')
              .get();

      setState(() {
        _allCategories =
            snapshot.docs
                .map((doc) => BusinessCategory.fromJson(doc.data()))
                .toList();
      });
    } catch (e) {
      // Silently fail - categories are optional
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = locator.get<AppConstants>().authTexts['signupView']!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: _currentStep == SignupStep.account,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep != SignupStep.account) {
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
          leading:
              _currentStep != SignupStep.account
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
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAccountStep(texts, theme),
                  _buildPersonalDetailsStep(texts, theme),
                  _buildFamilyInvitationStep(texts, theme),
                  _buildPreferencesStep(texts, theme),
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
    if (_currentStep == SignupStep.personalDetails) {
      setState(() {
        _currentStep = SignupStep.account;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == SignupStep.familyInvitation) {
      setState(() {
        _currentStep = SignupStep.personalDetails;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == SignupStep.preferences) {
      setState(() {
        _currentStep = SignupStep.familyInvitation;
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
          _buildStepIndicator(1, 'Cuenta', _currentStep.index >= 0, theme),
          Expanded(child: _buildProgressLine(_currentStep.index >= 1, theme)),
          _buildStepIndicator(2, 'Personal', _currentStep.index >= 1, theme),
          Expanded(child: _buildProgressLine(_currentStep.index >= 2, theme)),
          _buildStepIndicator(3, 'Familia', _currentStep.index >= 2, theme),
          Expanded(child: _buildProgressLine(_currentStep.index >= 3, theme)),
          _buildStepIndicator(
            4,
            'Preferencias',
            _currentStep.index >= 3,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int step,
    String label,
    bool isCompleted,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          child: Center(
            child:
                isCompleted
                    ? Icon(
                      Icons.check,
                      color: theme.colorScheme.onPrimary,
                      size: 18,
                    )
                    : Text(
                      step.toString(),
                      style: TextStyle(
                        color:
                            isCompleted
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted, ThemeData theme) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color:
          isCompleted
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  // Step 1: Account Creation (Email + Password)
  Widget _buildAccountStep(Map<String, String> texts, ThemeData theme) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _accountFormKey,
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
              const SizedBox(height: 24),

              // Welcome message
              Text(
                '¡Bienvenido!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Creemos tu cuenta en segundos',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email field with async validation
              FormBuilderTextField(
                name: 'email',
                key: const Key('signup_email'),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: texts['email-label']!,
                  hintText: texts['email-hint']!,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  // First validate email format
                  final emailValidation = locator
                      .get<AppMethods>()
                      .validateEmail(value, texts);
                  if (emailValidation != null) {
                    return emailValidation;
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 12),

              // Password field
              PasswordInput(
                keyName: '_register_password',
                name: 'password',
                label: texts['password-label']!,
                hintText: texts['password-hint']!,
              ),
              const SizedBox(height: 12),

              // Confirm Password field
              FormBuilderTextField(
                name: 'confirm_password',
                key: const Key('_register_confirm_password'),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  hintText: 'Confirma tu contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu contraseña';
                  }
                  final password =
                      _accountFormKey.currentState?.fields['password']?.value;
                  if (value != password) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),

              // Terms and Privacy acceptance
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Al continuar, aceptas nuestros ',
                    style: theme.textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap:
                        () =>
                            context.router.push(const TermsAndConditionsView()),
                    child: Text(
                      'Términos y Condiciones',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(' y ', style: theme.textTheme.bodySmall),
                  GestureDetector(
                    onTap: () => context.router.push(const PrivacyPolicyView()),
                    child: Text(
                      'Política de Privacidad',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text('.', style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _proceedToPersonalDetails(texts),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 2: Personal Details
  Widget _buildPersonalDetailsStep(Map<String, String> texts, ThemeData theme) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _personalDetailsFormKey,
          initialValue: _formData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
              Text(
                'Cuéntanos sobre ti',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Para personalizar tu experiencia',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // First name
              FormBuilderTextField(
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
              const SizedBox(height: 12),

              // Last names row
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

              // Date of birth picker
              FormBuilderDateTimePicker(
                name: 'date_of_birth',
                inputType: InputType.date,
                format: DateFormat('dd/MM/yyyy'),
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  hintText: 'Selecciona tu fecha de nacimiento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null) return 'Campo requerido';
                  final age = DateTime.now().difference(value).inDays ~/ 365;
                  if (age < 10) return 'Debes tener al menos 10 años';
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1920, 1, 1),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 12),

              // Rank selector
              FormBuilderField<String>(
                name: 'rank',
                key: const Key('_register_rank'),
                validator: (value) => validateInputs(context, value),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                builder: (field) {
                  return SearchableRankSelector(
                    selectedRank: field.value,
                    onRankSelected: (rank) {
                      field.didChange(rank);
                    },
                    labelText: texts['rank-label']!,
                    hintText: texts['rank-hint']!,
                    validator: (value) => validateInputs(context, value),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Sex toggle - compact switch below rank
              FormBuilderField<String>(
                name: 'sex',
                validator: (value) => value == null ? 'Campo requerido' : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                builder: (field) {
                  return SexToggleWidget(
                    selectedSex: field.value,
                    onSexChanged: (sex) => field.didChange(sex),
                    errorText: field.errorText,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _proceedToFamilyInvitation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 3: Family Invitation (Optional)
  Widget _buildFamilyInvitationStep(
    Map<String, String> texts,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _familyInvitationFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message with optional badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Código de Invitación',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OPCIONAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Si un familiar te invitó, úsalo aquí',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Invite code section
              _buildInviteCodeSection(theme),
              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _proceedToPreferences(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Continuar'),
              ),
              const SizedBox(height: 12),

              // Skip button - prominent
              if (!_isLoading)
                OutlinedButton(
                  onPressed: () => _proceedToPreferences(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Saltar - No tengo código'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 4: Preferences (Optional)
  Widget _buildPreferencesStep(Map<String, String> texts, ThemeData theme) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _preferencesFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message with optional badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tus Preferencias',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OPCIONAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Preferences section
              _buildPreferencesSection(theme),
              const SizedBox(height: 24),

              // Create account button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _createAccount(texts),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Crear Cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCodeSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '¿Tienes un código de invitación?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Si un familiar te invitó, ingresa el código aquí (opcional)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Invite code input with prominent validation
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inviteCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Código de invitación',
                      hintText: 'HEROES-ABC123',
                      border: OutlineInputBorder(),
                      helperText: 'Ingresa el código y presiona "Validar"',
                      helperMaxLines: 2,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      setState(() {
                        if (_invitedByMilitaryUid != null) {
                          _invitedByMilitaryUid = null;
                          _selectedRelationship = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed:
                      _inviteCodeController.text.isEmpty
                          ? null
                          : _validateInviteCode,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Validar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Show relationship selector if code is valid
            if (_invitedByMilitaryUid != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡Código válido! Selecciona tu relación familiar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRelationship,
                decoration: const InputDecoration(
                  labelText: 'Relación familiar',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'spouse', child: Text('Esposo/a')),
                  DropdownMenuItem(value: 'child', child: Text('Hijo/a')),
                  DropdownMenuItem(value: 'parent', child: Text('Padre/Madre')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRelationship = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tus preferencias (opcional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona tus categorías favoritas para recibir promociones personalizadas',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),

            if (_allCategories.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 7,
                runSpacing: 1,
                children:
                    _allCategories.map((category) {
                      final isSelected = _selectedCategories.contains(
                        category.name,
                      );
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category.name);
                            } else {
                              _selectedCategories.remove(category.name);
                            }
                          });
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _validateInviteCode() async {
    final code = _inviteCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    try {
      final familyService = locator.get<FamilyInvitationService>();
      final militaryUser = await familyService.validateInviteCode(code);

      if (!mounted) return;

      if (militaryUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código inválido. Verifica e intenta de nuevo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Code is valid
      setState(() {
        _invitedByMilitaryUid = militaryUser['uid'] as String;
        _inviteCodeController.text = code;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Código válido! Invitado por ${militaryUser['first_name']}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al validar código: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Navigation methods
  Future<void> _proceedToPersonalDetails(Map<String, String> texts) async {
    final formState = _accountFormKey.currentState;
    if (formState == null) return;

    if (!formState.saveAndValidate()) return;

    // Save form data
    final rawFormData = formState.value;
    _formData.addAll(rawFormData);

    // Check if email already exists
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
            content: Text(
              'Este correo electrónico ya está registrado. Usa otro email o inicia sesión.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Email is available, proceed to personal details
      setState(() {
        _isLoading = false;
        _currentStep = SignupStep.personalDetails;
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
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _proceedToFamilyInvitation() {
    final formState = _personalDetailsFormKey.currentState;
    if (formState == null) return;

    if (!formState.saveAndValidate()) return;

    // Save form data
    final rawFormData = formState.value;
    _formData.addAll(rawFormData);

    setState(() {
      _currentStep = SignupStep.familyInvitation;
    });

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _proceedToPreferences() {
    // No validation needed for family invitation step as it's optional
    setState(() {
      _currentStep = SignupStep.preferences;
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
      // Add preferences to form data
      if (_selectedCategories.isNotEmpty) {
        _formData['preferred_categories'] = _selectedCategories;
      }

      // Determine if this is a beneficiary (invited family member) or regular user
      final isBeneficiary =
          _invitedByMilitaryUid != null &&
          _inviteCodeController.text.isNotEmpty;

      if (isBeneficiary && _selectedRelationship == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona tu relación familiar'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final userData = User.toInitialFirebaseJson(
        _formData,
        isBeneficiary ? UserPermissions.beneficiary : null,
      );

      // Add beneficiary-specific fields if using invite code
      if (isBeneficiary) {
        // user_type is now automatically set by toInitialFirebaseJson based on permission
        userData['verified'] = true; // Auto-verify family members
        userData['status'] = 'active';
        userData['rank'] = 'OTROS_GRADOS_Beneficiarios';
      }

      final result = await context.read<AuthCubit>().signUp(userData);

      if (!mounted) return;

      if (result.success) {
        // If beneficiary, create family relationship
        bool familyLinkCreated = false;
        if (isBeneficiary && result.userId != null) {
          try {
            final familyService = locator.get<FamilyInvitationService>();
            await familyService.createFamilyRelationship(
              inviteCode: _inviteCodeController.text.toUpperCase(),
              militaryUid: _invitedByMilitaryUid!,
              beneficiaryUid: result.userId!,
              relationship: _selectedRelationship!,
              beneficiaryName:
                  '${_formData['first_name']} ${_formData['first_last_name']}',
            );
            familyLinkCreated = true;
          } catch (e) {
            // Log error and show warning but don't fail the signup
            debugPrint('Error creating family relationship: $e');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '⚠️ Tu cuenta fue creada, pero hubo un problema al vincular con tu familiar. '
                    'Por favor contacta a soporte para completar la vinculación.',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 6),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          }
        }

        if (!mounted) return;

        // Success - navigate to dashboard with appropriate message
        String successMessage;
        if (isBeneficiary) {
          if (familyLinkCreated) {
            successMessage =
                "¡Bienvenido a Héroes Colombia! Tu cuenta ha sido vinculada exitosamente con tu familiar.";
          } else {
            successMessage =
                "Tu cuenta ha sido creada. Nota: La vinculación familiar requiere atención - por favor contacta a soporte.";
          }
        } else {
          successMessage =
              "Tu cuenta ha sido creada exitosamente. Ya puedes acceder a todas las promociones.";
        }

        locator.get<AppMethods>().showDialogAlert(
          context,
          "¡Cuenta Creada!",
          successMessage,
          "Continuar",
          () => AutoRouter.of(context).replaceAll([const IntroRouteView()]),
        );
      } else {
        // Error creating account
        String errorMessage = result.errorMessage ?? 'Error creando la cuenta';

        // Special handling for email-already-in-use errors
        if (result.errorCode == 'email-already-in-use') {
          errorMessage =
              'Este correo electrónico ya está registrado. '
              'Por favor usa otro email o inicia sesión con tu cuenta existente.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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

  // Validation method
  String? validateInputs(BuildContext context, String? value) {
    final texts = locator.get<AppConstants>().authTexts['signupView']!;
    final message = locator.get<AppMethods>().emptyStringValidator(
      value,
      texts['genericValidator']!,
    );
    return message;
  }
}
