import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_methods.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:location/location.dart';

class MapPreviewWidget extends StatefulWidget {
  final double borderRadius;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onTap;

  const MapPreviewWidget({
    super.key,
    required this.borderRadius,
    required this.latitude,
    required this.longitude,
    this.onTap,
  });

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
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

      getMapInfo();
    } else {
      //If not, get the user location and use it to get the map preview
      locator<AppMethods>().getUserLocation().then((value) {
        if (value == null) return;

        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
        });

        getMapInfo();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    brightness = Theme.of(context).brightness;
    getMapInfo();
  }

  @override
  Widget build(BuildContext context) {
    return latitude != null && longitude != null
        ? InkWell(
          onTap:
              widget.onTap != null
                  ? widget.onTap
                  : () {
                    LocationData userLocationData = LocationData.fromMap({
                      'latitude': latitude,
                      'longitude': longitude,
                    });
                    AutoRouter.of(
                      context,
                    ).push(MapView(initialCameraLocation: userLocationData));
                  },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Image.network(
              mapUrl ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        )
        : const Center(child: CircularProgressIndicator());
  }

  void getMapInfo() {
    var latitude = this.latitude;
    var longitude = this.longitude;

    if (latitude == null || longitude == null) return;

    const zoom = 17;
    const size = '600x500';
    const mapType = 'roadmap';
    var markers = 'color:green%7Clabel:Yo%7C$latitude,$longitude';

    var currentTheme = brightness;

    final url = locator.get<AppMethods>().getStaticMapURL(
      zoom,
      size,
      mapType,
      markers,
      latitude,
      longitude,
      currentTheme,
    );
    setState(() {
      mapUrl = url;
    });
  }
}
