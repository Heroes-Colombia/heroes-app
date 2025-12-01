import 'package:flutter/material.dart';

/// A compact, switch-style toggle for sex/gender selection
/// Minimal design without label, suitable for inline placement
class SexToggleWidget extends StatelessWidget {
  final String? selectedSex;
  final ValueChanged<String> onSexChanged;
  final String? errorText;

  const SexToggleWidget({
    super.key,
    required this.selectedSex,
    required this.onSexChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact switch-style toggle
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: hasError
                ? Border.all(color: theme.colorScheme.error, width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(
                context: context,
                value: 'male',
                label: 'Masculino',
                icon: Icons.male,
                isSelected: selectedSex == 'male',
              ),
              _buildOption(
                context: context,
                value: 'female',
                label: 'Femenino',
                icon: Icons.female,
                isSelected: selectedSex == 'female',
              ),
            ],
          ),
        ),

        // Error text if needed
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onSexChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
