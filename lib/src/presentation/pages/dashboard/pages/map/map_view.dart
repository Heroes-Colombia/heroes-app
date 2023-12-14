import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/presentation/cubits/map/map_cubit.dart';

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

  static const CameraPosition requestedCameraPosition = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().getMapInitialInformation();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: get texts from constants
    // var texts = locator.get<AppConstants>().dashBoardTexts['mapView']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          switch (state.status) {
            case BusinessViewCubitStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case BusinessViewCubitStatus.success:
              return GoogleMap(
                cloudMapId: '7f1b54e9ff3283c0',
                buildingsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      state.userLocation!.latitude!,
                      state.userLocation!.longitude!,
                    ),
                    zoom: 15.7746),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: state.allMarkers.toSet(),
              );
            default:
              return const Center(child: Text('Error'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToMarkerPosition,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> goToMarkerPosition() async {
    //TODO: complete this function and use it to go to the searched marker
    final GoogleMapController controller = await _controller.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(requestedCameraPosition));
  }
}
