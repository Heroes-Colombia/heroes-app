import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/presentation/cubits/map/map_cubit.dart';
import 'package:location/location.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

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
  static const zoomFactor = 17.2746;
  static const selectedZoomFactor = 19.2746;
  var onDragStartPosition = const LatLng(0, 0);
  var onEndDragPosition = const LatLng(0, 0);
  bool useAutomaticSearch = false;
  bool useSearchResults = false;

  @override
  void initState() {
    super.initState();
    context
        .read<MapCubit>()
        .getMapInitialInformation(context, widget.initialCameraLocation);
  }

  @override
  Widget build(BuildContext context) {
    var texts = locator.get<AppConstants>().dashBoardTexts['mapView']!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          switch (state.status) {
            case BusinessViewCubitStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case BusinessViewCubitStatus.success:
              return succesView(state);
            default:
              return Center(child: Text(texts['search-error-title']!));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: goToUserPosition,
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }

  Widget succesView(MapState state) {
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
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
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      cameraTargetBounds: CameraTargetBounds.unbounded,
      mapToolbarEnabled: true,
      compassEnabled: false,
      cloudMapId: appTheme == Brightness.light
          ? locator.get<AppConstants>().lightMapTheme
          : locator.get<AppConstants>().darkMapTheme,
      buildingsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: widget.initialCameraLocation != null
            ? LatLng(
                widget.initialCameraLocation!.latitude!,
                widget.initialCameraLocation!.longitude!,
              )
            : LatLng(
                state.userLocation!.latitude!,
                state.userLocation!.longitude!,
              ),
        zoom: zoomFactor,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onCameraMoveStarted: () async {
        final controllerInfo = await getMapControllerInfo();

        setState(() {
          useAutomaticSearch = true;
          onDragStartPosition = controllerInfo[0];
        });
      },
      onCameraIdle: () async {
        final controllerInfo = await getMapControllerInfo();
        final zoomLevel = await controllerInfo[1];

        setState(() {
          onEndDragPosition = controllerInfo[0];
        });

        handleCameraMovement(zoomLevel);
      },
      markers: state.allMarkers.toSet(),
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
                              leading: const Icon(Icons.business),
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
                              leading: const Icon(Icons.business),
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

  //Methods

  Future<void> goToUserPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (!mounted) return;

    final userLocation = context.read<MapCubit>().state.userLocation;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              userLocation!.latitude!,
              userLocation.longitude!,
            ),
            zoom: zoomFactor),
      ),
    );
  }

  Future<void> goToMarkerPosition(latitude, longitude) async {
    final GoogleMapController controller = await _controller.future;
    if (!mounted) return;

    final businessLocation = LatLng(latitude, longitude);

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: businessLocation,
          zoom: selectedZoomFactor,
        ),
      ),
    );
  }

  Future<void> handleCameraMovement(double zoomLevel) async {
    if (!useAutomaticSearch) return;

    //We check if the camera moved more than 2km from the start position
    final distance =
        await context.read<MapCubit>().getDistanceBetweenPointsInKm(
              onDragStartPosition,
              onEndDragPosition,
            );

    if (!mounted) return;
    if (distance > 0.4) {
      context.read<MapCubit>().addBusinessesInCurrentPosition(
          GeoPoint(onEndDragPosition.latitude, onEndDragPosition.longitude),
          context);
    }
  }

  Future<List<dynamic>> getMapControllerInfo() async {
    final GoogleMapController controller = await _controller.future;
    final cameraCenterLatlng = await controller.getLatLng(
      const ScreenCoordinate(x: 0, y: 0),
    );
    final zoomLevel = await controller.getZoomLevel();

    return [cameraCenterLatlng, zoomLevel];
  }
}
