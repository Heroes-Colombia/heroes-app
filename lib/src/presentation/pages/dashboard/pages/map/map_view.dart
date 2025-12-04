import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';
import 'package:heroes_app/src/domain/models/business_location.dart';
import 'package:heroes_app/src/presentation/cubits/map/map_cubit.dart';
import 'package:heroes_app/src/presentation/cubits/business/business_details/business_details_cubit.dart';
import 'package:heroes_app/src/presentation/widgets/map_category_filter.dart';
import 'package:heroes_app/src/presentation/widgets/business_map_preview_sheet.dart';
import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:location/location.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';

@RoutePage()
class MapView extends StatefulWidget {
  final LocationData? initialCameraLocation;
  const MapView({super.key, required this.initialCameraLocation});

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final locator = GetIt.instance;
  static const zoomFactor = 12.30;
  static const selectedZoomFactor = 12.30;
  var onDragStartPosition = const LatLng(0, 0);
  var onEndDragPosition = const LatLng(0, 0);
  bool useAutomaticSearch = false;
  bool useSearchResults = false;
  bool useSearchSelected = false;

  // Store cubit reference to avoid context access in dispose
  late final MapCubit _mapCubit;

  @override
  void initState() {
    super.initState();
    _mapCubit = context.read<MapCubit>();
    _mapCubit.getMapInitialInformation(context, widget.initialCameraLocation);
    // Load categories for filter
    _mapCubit.loadCategories();
  }

  @override
  void dispose() {
    // Cancel any stream subscriptions in the cubit
    // Safe to call because we stored the reference in initState
    try {
      _mapCubit.cancelSubscriptions();
    } catch (e) {
      // Cubit may have been closed already - safe to ignore
    }

    // Dispose the controller if it was completed
    if (_controller.isCompleted) {
      _controller.future
          .then((controller) {
            try {
              controller.dispose();
            } catch (e) {
              // Controller already disposed or invalid - safe to ignore
            }
          })
          .catchError((error) {
            // Completer was completed with an error - safe to ignore
          });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var texts = locator.get<AppConstants>().dashBoardTexts['mapView']!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: BlocListener<MapCubit, MapState>(
        listenWhen:
            (previous, current) =>
                previous.selectedBusinessIdForPreview !=
                    current.selectedBusinessIdForPreview &&
                current.selectedBusinessIdForPreview != null,
        listener: (context, state) {
          if (state.selectedBusinessIdForPreview != null) {
            _showBusinessPreview(
              state.selectedBusinessIdForPreview!,
              state.selectedLocationIdForPreview,
              context,
            );
            context.read<MapCubit>().clearSelectedBusiness();
          }
        },
        child: BlocBuilder<MapCubit, MapState>(
          builder: (context, state) {
            switch (state.status) {
              case BusinessViewCubitStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case BusinessViewCubitStatus.success:
                return successView(state);
              default:
                return Center(child: Text(texts['search-error-title']!));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: goToUserPosition,
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }

  Widget successView(MapState state) {
    var appTheme = Theme.of(context).brightness;
    var theme = Theme.of(context);
    var texts = locator.get<AppConstants>().dashBoardTexts["mapView"]!;

    return Stack(
      fit: StackFit.expand,
      children: [
        mapWidget(appTheme, state),
        FloatingSearchBar(
          hint: texts["search-hint"]!,
          transition: CircularFloatingSearchBarTransition(),
          transitionDuration: const Duration(milliseconds: 600),
          backgroundColor: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          physics: const BouncingScrollPhysics(),
          accentColor: theme.colorScheme.background,
          iconColor: theme.colorScheme.onBackground,
          height: 60,
          progress: false,
          onSubmitted: (query) {
            setState(() {
              useAutomaticSearch = true;
              useSearchResults = true;
            });

            context.read<MapCubit>().onSearchSubmitted(query, context);
          },
          onQueryChanged: (query) {
            setState(() {
              useAutomaticSearch = true;
              useSearchResults = false;
            });
            context.read<MapCubit>().searchBusiness(query);
          },
          onFocusChanged: (isFocused) {
            if (isFocused) {
              context.read<MapCubit>().searchBusiness("");
            }
          },
          builder: (context, transition) {
            return useSearchResults
                ? searchResults(theme, texts)
                : searchSuggestions(theme, texts);
          },
        ),
        // Category Filter (positioned below search bar)
        if (state.businessCategories.isNotEmpty)
          Positioned(
            top:
                140, // Below the search bar with spacing (60px bar + ~28px top margin/padding)
            left: 0,
            right: 0,
            height: 50, // Fixed height to avoid blocking map interactions
            child: MapCategoryFilter(
              categories: state.businessCategories,
              selectedCategoryId: state.selectedCategoryId,
              onCategorySelected: (categoryId) {
                context.read<MapCubit>().filterByCategory(categoryId);
              },
            ),
          ),
        state.isMapLoading
            ? Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                height: 50,
                width: 50,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
            )
            : const SizedBox.shrink(),
      ],
    );
  }

  //Widgets

  GoogleMap mapWidget(Brightness appTheme, MapState state) {
    return GoogleMap(
      // Removed UniqueKey() - it was forcing expensive map recreations
      // The disposal issues are now properly handled with mounted checks and try-catch
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      cameraTargetBounds: CameraTargetBounds.unbounded,
      mapToolbarEnabled: true,
      compassEnabled: false,
      cloudMapId:
          appTheme == Brightness.light
              ? locator.get<AppConstants>().lightMapTheme
              : locator.get<AppConstants>().darkMapTheme,
      buildingsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target:
            state.initialMapCenter ??
            LatLng(
              state.userLocation!.latitude!,
              state.userLocation!.longitude!,
            ),
        zoom: zoomFactor,
      ),
      onMapCreated: (GoogleMapController controller) {
        if (!mounted) {
          controller.dispose();
          return;
        }
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
      onCameraMoveStarted: () async {
        if (!mounted) return;
        final controllerInfo = await getMapControllerInfo();
        if (!mounted) return;

        setState(() {
          useAutomaticSearch = true;
          onDragStartPosition = controllerInfo[0];
        });
      },
      onCameraIdle: () async {
        if (!mounted) return;
        final controllerInfo = await getMapControllerInfo();
        if (!mounted) return;
        final zoomLevel = await controllerInfo[1];

        setState(() {
          onEndDragPosition = controllerInfo[0];
        });

        handleCameraMovement(zoomLevel);
      },
      markers: state.filtredMarkers.toSet(),
    );
  }

  Container searchSuggestions(ThemeData theme, Map<String, String> texts) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  texts['search-suggestions']!,
                  style: theme.textTheme.labelLarge,
                ),
                state.filtredMarkers.isEmpty
                    ? Expanded(
                      child: Center(child: Text(texts['search-error']!)),
                    )
                    : Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: state.filtredMarkers.length,
                        itemBuilder: (context, index) {
                          final business = state.filtredMarkers[index];
                          return ListTile(
                            title: Text(
                              business.infoWindow.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              business.infoWindow.snippet!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              // Track click on search suggestion
                              final analyticsService =
                                  locator.get<AnalyticsService>();
                              analyticsService.trackDashboardClick(
                                entityType: 'business',
                                entityId: business.markerId.value,
                                businessId: business.markerId.value,
                                screen: 'map_search_suggestions',
                              );

                              goToMarkerPosition(
                                business.position.latitude,
                                business.position.longitude,
                              );

                              FloatingSearchBar.of(context)?.close();
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container searchResults(ThemeData theme, Map<String, String> texts) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  texts['search-results']!,
                  style: theme.textTheme.labelLarge,
                ),
                state.searchedMarkers.isEmpty
                    ? Expanded(
                      child: Center(child: Text(texts['search-error']!)),
                    )
                    : Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: state.searchedMarkers.length,
                        itemBuilder: (context, index) {
                          final business = state.searchedMarkers[index];
                          return ListTile(
                            title: Text(
                              business.infoWindow.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              business.infoWindow.snippet!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () async {
                              // Extract businessId and locationId from markerId
                              // Format: "businessId_locationId"
                              final markerIdParts = business.markerId.value
                                  .split('_');
                              final businessId = markerIdParts[0];
                              final locationId =
                                  markerIdParts.length > 1
                                      ? markerIdParts[1]
                                      : null;

                              // Track click on search result
                              final analyticsService =
                                  locator.get<AnalyticsService>();
                              analyticsService.trackDashboardClick(
                                entityType: 'business',
                                entityId: businessId,
                                businessId: businessId,
                                screen: 'map_search_results',
                              );

                              // Store cubit reference before async gap
                              final mapCubit = context.read<MapCubit>();

                              // Close search bar
                              FloatingSearchBar.of(context)?.close();

                              // Navigate to the location
                              await goToMarkerPosition(
                                business.position.latitude,
                                business.position.longitude,
                              );

                              // Trigger preview via cubit (which will be handled by BlocListener)
                              if (!mounted) return;
                              mapCubit.selectBusinessForPreview(
                                businessId,
                                locationId: locationId,
                              );
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        },
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  //Methods

  Future<void> goToUserPosition() async {
    if (!mounted) return;
    if (!_controller.isCompleted) return;

    try {
      final GoogleMapController controller = await _controller.future;
      if (!mounted) return;

      final userLocation = _mapCubit.state.userLocation;
      if (userLocation == null ||
          userLocation.latitude == null ||
          userLocation.longitude == null) {
        return; // Cannot navigate without valid location
      }

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(userLocation.latitude!, userLocation.longitude!),
            zoom: zoomFactor,
          ),
        ),
      );
    } on StateError catch (_) {
      // GoogleMap widget was disposed - ignore silently
    }
  }

  Future<void> goToMarkerPosition(latitude, longitude) async {
    if (!mounted) return;
    if (!_controller.isCompleted) return;

    try {
      final GoogleMapController controller = await _controller.future;
      if (!mounted) return;

      final businessLocation = LatLng(latitude, longitude);

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: businessLocation, zoom: selectedZoomFactor),
        ),
      );
    } on StateError catch (_) {
      // GoogleMap widget was disposed - ignore silently
    }
  }

  Future<void> handleCameraMovement(double zoomLevel) async {
    if (!useAutomaticSearch) return;

    //We check if the camera moved more than 2km from the start position
    final distance = await _mapCubit.getDistanceBetweenPointsInKm(
      onDragStartPosition,
      onEndDragPosition,
    );

    if (!mounted) return;
    if (distance > 0.4) {
      _mapCubit.addBusinessesInCurrentPosition(
        GeoPoint(onEndDragPosition.latitude, onEndDragPosition.longitude),
        context,
      );
    }
  }

  Future<List<dynamic>> getMapControllerInfo() async {
    if (!mounted) return [const LatLng(0, 0), 0.0];
    if (!_controller.isCompleted) return [const LatLng(0, 0), 0.0];

    try {
      final GoogleMapController controller = await _controller.future;
      if (!mounted) return [const LatLng(0, 0), 0.0];

      final cameraCenterLatlng = await controller.getLatLng(
        const ScreenCoordinate(x: 0, y: 0),
      );
      if (!mounted) return [const LatLng(0, 0), 0.0];

      final zoomLevel = await controller.getZoomLevel();

      return [cameraCenterLatlng, zoomLevel];
    } on StateError catch (_) {
      // GoogleMap widget was disposed while we were trying to access the controller
      // This is expected during rapid navigation - return safe defaults
      return [const LatLng(0, 0), 0.0];
    }
  }

  Future<void> _showBusinessPreview(
    String businessId,
    String? locationId,
    BuildContext context,
  ) async {
    // Get business data from state
    final business = _mapCubit.state.allBusinessMarkers.firstWhere(
      (b) => b.businessId == businessId,
    );

    // Fetch all async data first before showing the modal
    final user = await locator.get<AuthService>().getUser();
    if (!mounted) return;

    var isFavorite = false;
    final favouriteBusinesses = user!.favouriteBusinesses;
    if (favouriteBusinesses.contains(businessId)) {
      isFavorite = true;
    }

    // Get category name if available
    String? categoryName;
    if (business.categories.isNotEmpty) {
      final categories = _mapCubit.state.businessCategories;
      if (categories.isNotEmpty) {
        final categoryId = business.categories.first;
        final category = categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => BusinessCategory(id: '', name: '', imageUrl: ''),
        );
        categoryName = category.name.isNotEmpty ? category.name : null;
      }
    }

    // Initialize with business-level data
    String displayAddress = business.address;
    String? displayPhone = business.phoneNumber;
    double displayLatitude = business.location.latitude;
    double displayLongitude = business.location.longitude;

    // If locationId is provided, fetch location-specific data
    if (locationId != null) {
      try {
        final locationDoc =
            await FirebaseFirestore.instance
                .collection('businesses')
                .doc(businessId)
                .collection('locations')
                .doc(locationId)
                .get();

        if (!mounted) return;

        if (locationDoc.exists) {
          final locationData = locationDoc.data()!;
          locationData['id'] = locationDoc.id;

          final location = BusinessLocation.fromJson(locationData, locationId);

          // Use location-specific data
          displayAddress = location.address ?? business.address;
          displayPhone = location.phone ?? business.phoneNumber;

          if (location.location != null) {
            displayLatitude = location.location!.latitude;
            displayLongitude = location.location!.longitude;
          }
        }
      } catch (e) {
        // If location fetch fails, fall back to business-level data
        // (already initialized above)
      }
    }

    // Final mounted check before showing modal
    if (!mounted) return;

    // Show modal after all async operations are complete
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => BusinessMapPreviewSheet(
            businessId: business.businessId,
            businessName: business.name,
            categoryName: categoryName,
            address: displayAddress,
            phoneNumber: displayPhone,
            latitude: displayLatitude,
            longitude: displayLongitude,
            isFavorite: isFavorite,
            onFavoriteToggle: () {
              sheetContext.read<BusinessDetailsCubit>().setBusinessAsFavourite(
                business.businessId,
              );
            },
          ),
    );
  }
}
