import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:location/location.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';

class MapInteractiveWidget extends StatefulWidget {
  final double borderRadius;
  final double? latitude;
  final double? longitude;

  const MapInteractiveWidget({
    super.key,
    required this.borderRadius,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapInteractiveWidget> createState() => _MapInteractiveWidgetState();
}

class _MapInteractiveWidgetState extends State<MapInteractiveWidget> {
  final locator = GetIt.instance;
  double? latitude;
  double? longitude;
  String? mapUrl;
  Brightness? brightness;

  @override
  void initState() {
    super.initState();

    //If the latitude and longitude are not null, use them to get the map preview
    if (widget.latitude != null && widget.longitude != null) {
      setState(() {
        latitude = widget.latitude;
        longitude = widget.longitude;
      });
    } else {
      //If not, get the user location and use it to get the map preview
      locator<AppMethods>().getUserLocation().then((value) {
        if (value == null) return;
        if (!mounted) return;

        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child:
          latitude != null
              ? mapWidget(theme.brightness)
              : const SizedBox.shrink(),
    );
  }

  GoogleMap mapWidget(Brightness appTheme) {
    return GoogleMap(
      key: UniqueKey(), // Prevents "recreating view" error
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      cameraTargetBounds: CameraTargetBounds.unbounded,
      mapToolbarEnabled: false,
      zoomGesturesEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      onTap: (LatLng latLng) {
        // Track map widget interaction
        final analyticsService = locator.get<AnalyticsService>();
        analyticsService.trackDashboardClick(
          entityType: 'business',
          entityId: 'map_widget',
          screen: 'map_interactive_widget',
        );

        LocationData userLocationData = LocationData.fromMap({
          'latitude': latitude,
          'longitude': longitude,
        });
        AutoRouter.of(
          context,
        ).push(MapView(initialCameraLocation: userLocationData));
      },
      compassEnabled: false,
      cloudMapId:
          appTheme == Brightness.light
              ? locator.get<AppConstants>().lightMapTheme
              : locator.get<AppConstants>().darkMapTheme,
      buildingsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude!, longitude!),
        zoom: 15,
      ),
    );
  }
}
