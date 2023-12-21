import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/presentation/cubits/map/map_cubit.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

@RoutePage()
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final locator = GetIt.instance;
  static const zoomFactor = 17.2746;
  static const selectedZoomFactor = 19.2746;

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().getMapInitialInformation(context);
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
          onQueryChanged: (query) {
            context.read<MapCubit>().searchBusiness(query);
          },
          builder: (context, transition) {
            return searchSuggestions(theme, texts);
          },
        )
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
          ? '7f1b54e9ff3283c0'
          : "d5b5cd4a8eefe81d",
      buildingsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          state.userLocation!.latitude!,
          state.userLocation!.longitude!,
        ),
        zoom: zoomFactor,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
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
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: state.filtredMarkers.isEmpty
                ? Center(child: Text(texts['search-error']!))
                : ListView.separated(
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
}
