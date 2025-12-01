import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/presentation/cubits/profile/profile_cubit.dart';

@RoutePage()
class EditPreferencesView extends StatefulWidget {
  const EditPreferencesView({super.key});

  @override
  State<EditPreferencesView> createState() => _EditPreferencesViewState();
}

class _EditPreferencesViewState extends State<EditPreferencesView> {
  List<BusinessCategory> _allCategories = [];
  List<String> _selectedCategories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndPreferences();
  }

  Future<void> _loadCategoriesAndPreferences() async {
    try {
      // Load categories from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('business_categories')
          .get();

      final categories = snapshot.docs
          .map((doc) => BusinessCategory.fromJson(doc.data()))
          .toList();

      // Get user's current preferences
      if (!mounted) return;
      final user = context.read<ProfileCubit>().state.user;
      final currentPreferences = user?.preferredCategories ?? [];

      if (!mounted) return;

      setState(() {
        _allCategories = categories;
        _selectedCategories = List.from(currentPreferences);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar categorías: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Update user preferences in Firestore via ProfileCubit
      await context.read<ProfileCubit>().updateProfileInfo({
        'preferred_categories': _selectedCategories,
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias actualizadas correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to profile
      context.router.maybePop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar preferencias: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Preferencias'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selecciona tus categorías favoritas para recibir promociones personalizadas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selected count
                  Text(
                    '${_selectedCategories.length} categorías seleccionadas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category chips
                  if (_allCategories.isEmpty)
                    const Center(
                      child: Text('No hay categorías disponibles'),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allCategories.map((category) {
                        final isSelected = _selectedCategories.contains(category.name);
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
                          checkmarkColor: theme.colorScheme.primary,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar Preferencias',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
