import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_methods.dart';

class MapPreviewWidget extends StatefulWidget {
  final double borderRadius;
  final double? latitude;
  final double? longitude;

  const MapPreviewWidget({
    Key? key,
    required this.borderRadius,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
  final locator = GetIt.instance;
  double? latitude;
  double? longitude;

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

        setState(() {
          latitude = value.latitude;
          longitude = value.longitude;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var url =
        'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=18&size=600x300&maptype=roadmap&markers=color:green%7Clabel:Yo%7C$latitude,$longitude&key=AIzaSyC1Q-0MKSzN0IpvklnNc1t4yPEpzQScC9o&map_id=7f1b54e9ff3283c0';
    return latitude != null && longitude != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
