import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/src/presentation/widgets/location_picker_widget.dart';
import 'package:ionicons/ionicons.dart';

class LocationPickerField extends StatelessWidget {
  final String name;
  final String label;
  final String hint;
  final String searchHint;
  final String? Function(LocationResult?)? validator;
  final LatLng? initialLocation;
  final bool showTextField;
  final VoidCallback? onMapTap;

  const LocationPickerField({
    super.key,
    required this.name,
    required this.label,
    required this.hint,
    required this.searchHint,
    this.validator,
    this.initialLocation,
    this.showTextField = true,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormBuilderField<LocationResult>(
      name: name,
      validator: validator,
      builder: (field) {
        // Function to open the location picker map
        Future<void> openLocationPicker() async {
          final result = await Navigator.of(context).push<LocationResult>(
            MaterialPageRoute(
              builder:
                  (context) => LocationPickerWidget(
                    title: label,
                    searchHint: searchHint,
                    initialLocation:
                        field.value?.coordinates ?? initialLocation,
                  ),
            ),
          );

          if (result != null) {
            field.didChange(result);
            // Call the onMapTap callback if provided
            onMapTap?.call();
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTextField) ...[
              InkWell(
                onTap: openLocationPicker,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color:
                          field.hasError
                              ? Colors.red
                              : theme.colorScheme.outline,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: theme.textTheme.bodySmall!.fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              field.value?.formattedAddress ?? hint,
                              style: TextStyle(
                                color:
                                    field.value != null
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                fontSize: theme.textTheme.bodyMedium!.fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        field.value != null
                            ? Ionicons.checkmark_circle_outline
                            : Ionicons.location_outline,
                        color:
                            field.hasError
                                ? Colors.red
                                : theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (field.hasError) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                ),
              ),
            ],
            if (field.value != null && showTextField) ...[
              const SizedBox(height: 8),
              Text(
                'Location selected successfully',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: theme.textTheme.bodySmall!.fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Helper method to access the map picker directly
  static Future<LocationResult?> openLocationPicker(
    BuildContext context,
    String title,
    String searchHint,
    LatLng? initialLocation,
  ) async {
    return Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(
        builder:
            (context) => LocationPickerWidget(
              title: title,
              searchHint: searchHint,
              initialLocation: initialLocation,
            ),
      ),
    );
  }
}
