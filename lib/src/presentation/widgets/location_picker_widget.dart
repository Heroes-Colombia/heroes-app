import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/domain/services/places_service.dart';
import 'package:heroes_app/src/domain/models/autocomplete_prediction.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:developer';

class LocationResult {
  final LatLng coordinates;
  final String formattedAddress;
  final String? cityName;

  LocationResult({
    required this.coordinates,
    required this.formattedAddress,
    this.cityName,
  });
}

class LocationPickerWidget extends StatefulWidget {
  final String title;
  final String searchHint;
  final LatLng? initialLocation;

  const LocationPickerWidget({
    super.key,
    required this.title,
    required this.searchHint,
    this.initialLocation,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final FloatingSearchBarController _searchController =
      FloatingSearchBarController();
  final locator = GetIt.instance;

  static const double zoomFactor = 15.0;
  late LatLng _selectedLocation;
  String _selectedAddress = '';
  bool _isLoadingLocation = false;
  bool _isGettingAddress = false;
  bool _isUpdatingSearchFromAddress = false; // Prevent search loop
  bool _isSearching = false;
  List<AutocompletePrediction> _searchResults = [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoadingLocation = true);

    LatLng initialLocation;

    if (widget.initialLocation != null) {
      initialLocation = widget.initialLocation!;
    } else {
      // Try to get user's current location
      try {
        final locationData = await locator.get<AppMethods>().getUserLocation();
        if (locationData != null) {
          initialLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        } else {
          // Fallback to a default location (you can customize this)
          initialLocation = const LatLng(4.7110, -74.0721); // Bogotá, Colombia
        }
      } catch (e) {
        log('Error getting location: $e');
        initialLocation = const LatLng(4.7110, -74.0721); // Fallback
      }
    }

    _selectedLocation = initialLocation;
    _updateMarker(_selectedLocation);
    await _getAddressFromCoordinates(_selectedLocation);

    setState(() => _isLoadingLocation = false);
  }

  void _updateMarker(LatLng position) {
    final texts =
        locator.get<AppConstants>().authTexts['locationPickerWidget']!;

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: texts['selected-location-marker']!),
        ),
      };
    });
  }

  Future<void> _getAddressFromCoordinates(LatLng coordinates) async {
    final texts =
        locator.get<AppConstants>().authTexts['locationPickerWidget']!;
    setState(() => _isGettingAddress = true);

    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          if (placemark.street?.isNotEmpty == true) placemark.street,
          if (placemark.locality?.isNotEmpty == true) placemark.locality,
          if (placemark.administrativeArea?.isNotEmpty == true)
            placemark.administrativeArea,
          if (placemark.country?.isNotEmpty == true) placemark.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        setState(() {
          _selectedAddress =
              address.isNotEmpty ? address : texts['unknown-location']!;
        });

        // Update search bar with the address for editing
        _updateSearchBarWithAddress(_selectedAddress);
      } else {
        setState(() {
          _selectedAddress = texts['unknown-location']!;
        });
        _updateSearchBarWithAddress(_selectedAddress);
      }
    } catch (e) {
      log('Error getting address: $e');
      setState(() {
        _selectedAddress = texts['address-not-available']!;
      });
      _updateSearchBarWithAddress(_selectedAddress);
    }

    setState(() => _isGettingAddress = false);
  }

  void _updateSearchBarWithAddress(String address) {
    // Prevent search loop when updating from address
    _isUpdatingSearchFromAddress = true;

    _searchController.query = address;

    // Use a longer delay to ensure the query change doesn't trigger search
    Future.delayed(const Duration(milliseconds: 500), () {
      _isUpdatingSearchFromAddress = false;
    });
  }

  void _handleAddressSubmit(String address) {
    if (address.trim().isEmpty) return;
    _searchAddress(address.trim());
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    final placesService = locator.get<PlacesService>();
    final results = await placesService.getAutocomplete(query);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _goToCurrentLocation() async {
    final texts =
        locator.get<AppConstants>().authTexts['locationPickerWidget']!;
    setState(() => _isLoadingLocation = true);

    try {
      final locationData = await locator.get<AppMethods>().getUserLocation();
      if (locationData != null) {
        final currentPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        final controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentPosition, zoom: zoomFactor),
          ),
        );

        _selectedLocation = currentPosition;
        _updateMarker(_selectedLocation);
        await _getAddressFromCoordinates(_selectedLocation);
      } else {
        _showErrorSnackBar(texts['location-permission-error']!);
      }
    } catch (e) {
      log('Error getting current location: $e');
      _showErrorSnackBar(texts['location-service-error']!);
    }

    setState(() => _isLoadingLocation = false);
  }

  void _onMapTap(LatLng position) {
    _selectedLocation = position;
    _updateMarker(_selectedLocation);
    _getAddressFromCoordinates(_selectedLocation);
  }

  void _confirmSelection() {
    final result = LocationResult(
      coordinates: _selectedLocation,
      formattedAddress: _selectedAddress,
      cityName: null, // You can extract city from placemark if needed
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts =
        locator.get<AppConstants>().authTexts['locationPickerWidget']!;

    return Scaffold(
      body:
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation,
                      zoom: zoomFactor,
                    ),
                    onTap: _onMapTap,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true, // Enable zoom controls
                    zoomGesturesEnabled: true, // Enable pinch-to-zoom
                    scrollGesturesEnabled: true, // Enable pan gestures
                    tiltGesturesEnabled: true, // Enable tilt gestures
                    rotateGesturesEnabled: true, // Enable rotation gestures
                    mapToolbarEnabled: false,
                    cloudMapId:
                        theme.brightness == Brightness.light
                            ? locator.get<AppConstants>().lightMapTheme
                            : locator.get<AppConstants>().darkMapTheme,
                  ),

                  // Floating Back Button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    child: FloatingActionButton.small(
                      heroTag: "back_button",
                      onPressed: () => Navigator.of(context).pop(),
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),

                  // Floating Confirm Button
                  Positioned(
                    top:
                        MediaQuery.of(context).padding.top +
                        80, // Moved lower to avoid search bar overlap
                    right: 16,
                    child: FloatingActionButton.extended(
                      heroTag: "confirm_button",
                      onPressed:
                          _selectedAddress.isNotEmpty
                              ? _confirmSelection
                              : null,
                      backgroundColor:
                          _selectedAddress.isNotEmpty
                              ? theme.colorScheme.primary
                              : theme.disabledColor,
                      foregroundColor:
                          _selectedAddress.isNotEmpty
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                      label: Text(texts['confirm']!),
                      icon: const Icon(Icons.check),
                    ),
                  ),

                  // Search bar
                  FloatingSearchBar(
                    controller: _searchController,
                    hint: widget.searchHint,
                    showCursor: true,
                    transition: CircularFloatingSearchBarTransition(),
                    transitionDuration: const Duration(milliseconds: 600),
                    backgroundColor: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    physics: const BouncingScrollPhysics(),
                    accentColor: theme.colorScheme.primary,
                    iconColor: theme.colorScheme.onBackground,
                    height: 60,
                    onSubmitted: (query) {
                      if (!_isUpdatingSearchFromAddress &&
                          query.trim().isNotEmpty) {
                        _handleAddressSubmit(query.trim());
                      }
                    },
                    onQueryChanged: (query) {
                      if (_isUpdatingSearchFromAddress) return;
                      _searchAddress(query);
                    },
                    builder: (context, transition) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Material(
                          color: theme.colorScheme.surface,
                          elevation: 4,
                          child:
                              _isSearching
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _searchResults.isEmpty
                                  ? Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'No results found',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final prediction = _searchResults[index];
                                      return ListTile(
                                        title: Text(prediction.description),
                                        onTap: () async {
                                          final placesService =
                                              locator.get<PlacesService>();
                                          final selectedPlaceDetails =
                                              await placesService
                                                  .getPlaceDetails(
                                                    prediction.placeId,
                                                  );

                                          if (selectedPlaceDetails != null) {
                                            _selectedLocation =
                                                selectedPlaceDetails;
                                            _updateMarker(_selectedLocation);
                                            await _getAddressFromCoordinates(
                                              _selectedLocation,
                                            );
                                            final controller =
                                                await _controller.future;
                                            await controller.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                  target: _selectedLocation,
                                                  zoom: zoomFactor,
                                                ),
                                              ),
                                            );
                                            _searchController.close();
                                          } else {
                                            _showErrorSnackBar(
                                              texts['location-details-error']!,
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                        ),
                      );
                    },
                  ),

                  // Selected location info
                  Positioned(
                    bottom: 120,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            texts['selected-location-marker']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isGettingAddress
                              ? Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(texts['getting-address']!),
                                ],
                              )
                              : Text(
                                _selectedAddress,
                                style: theme.textTheme.bodyMedium,
                              ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                            'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Current location button - moved to left to avoid zoom controls overlap
                  Positioned(
                    bottom: 40,
                    left: 16, // Moved to left side
                    child: FloatingActionButton.small(
                      heroTag: "location_button",
                      onPressed: _goToCurrentLocation,
                      child:
                          _isLoadingLocation
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.gps_fixed),
                    ),
                  ),
                ],
              ),
    );
  }
}
