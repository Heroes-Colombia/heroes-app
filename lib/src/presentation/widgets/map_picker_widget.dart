import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';

class MapPickerWidget extends StatefulWidget {
  final double borderRadius;
  final double? latitude;
  final double? longitude;
  final Function onLocationChanged;

  const MapPickerWidget({
    super.key,
    required this.borderRadius,
    required this.latitude,
    required this.longitude,
    required this.onLocationChanged,
  });

  @override
  State<MapPickerWidget> createState() => _MapInteractiveWidgetState();
}

class _MapInteractiveWidgetState extends State<MapPickerWidget> {
  final locator = GetIt.instance;
  double? latitude;
  double? longitude;
  Brightness? brightness;

  @override
  void initState() {
    super.initState();

    setState(() {
      latitude = widget.latitude;
      longitude = widget.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: latitude != null
          ? mapWidget(theme.brightness)
          : const SizedBox.shrink(),
    );
  }

  GoogleMap mapWidget(Brightness appTheme) {
    return GoogleMap(
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        cameraTargetBounds: CameraTargetBounds.unbounded,
        mapToolbarEnabled: false,
        compassEnabled: false,
        onTap: (LatLng latLng) => setState(() {
              latitude = latLng.latitude;
              longitude = latLng.longitude;
              widget.onLocationChanged(latitude, longitude);
            }),
        cloudMapId: appTheme == Brightness.light
            ? locator.get<AppConstants>().lightMapTheme
            : locator.get<AppConstants>().darkMapTheme,
        buildingsEnabled: false,
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: const MarkerId(''),
            position: LatLng(latitude!, longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(84.62),
          )
        },
        initialCameraPosition:
            CameraPosition(target: LatLng(latitude!, longitude!), zoom: 18));
  }
}
