import 'dart:convert';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/config/router/app_router.gr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class AppMethods {
  //Validate email input field
  //Use this method in the validator property of the FormBuilderTextField widget
  String? validateEmail(String? value, Map<String, String> texts) {
    if (value == null || value.isEmpty) {
      return texts['email-validator']!;
    }
    if (!RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(value)) {
      return texts['email-validator']!;
    }
    return null;
  }

  //Validate empty input field
  String? emptyStringValidator(String? value, String message) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

  //Validate empty input
  dynamic emptyInputValidator(dynamic value, String message) {
    if (value == null) {
      return message;
    }
    return null;
  }

  //Validate empty input field and with a max length
  String? emptyStringValidatorWithMaxLength(
    String? value,
    String message,
    int maxLength,
  ) {
    if (value == null || value.isEmpty) {
      return message;
    }
    if (value.length > maxLength) {
      return message;
    }
    return null;
  }

  //Validate empty input field with double as value
  String? nullDoubleValidator(double? value, String message) {
    if (value == null) {
      return message;
    }
    return null;
  }

  //Validate password input field
  String? passwordValidator(
    String? value,
    String emptyString,
    String invalidLength,
  ) {
    if (value == null || value.isEmpty) {
      return emptyString;
    }
    if (value.length < 6) {
      return invalidLength;
    }
    return null;
  }

  //Validate month input field
  String? cardMonthValidator(String? value, String invalidMonth) {
    if (value == null || value.isEmpty) {
      return invalidMonth;
    }
    final regex = RegExp(r"^\d{2}$");
    if (int.parse(value) < 1 ||
        int.parse(value) > 12 ||
        !regex.hasMatch(value)) {
      return invalidMonth;
    }
    return null;
  }

  //Validate year input field
  String? cardYearValidator(String? value, String invalidYear) {
    if (value == null || value.isEmpty) {
      return invalidYear;
    }
    final regex = RegExp(r"^\d{2}$");
    final last2Digits = DateTime.now().year.toString().substring(2);
    if (int.parse(value) < int.parse(last2Digits) || !regex.hasMatch(value)) {
      return invalidYear;
    }
    return null;
  }

  //Validate card Holder Name input field
  String? cardHolderNameValidator(String? value, String invalidName) {
    if (value == null || value.isEmpty) {
      return invalidName;
    }
    final regex = RegExp(r"^[a-zA-Z\s]*$");
    if (!regex.hasMatch(value) || value.length < 5) {
      return invalidName;
    }
    return null;
  }

  //Validate cvv input field
  String? cvvValidator(String? value, String invalidCvv) {
    if (value == null || value.isEmpty) {
      return invalidCvv;
    }
    final regex = RegExp(r"^\d{3}$");
    if (!regex.hasMatch(value)) {
      return invalidCvv;
    }
    return null;
  }

  //Get the picture from the camera
  Future<XFile?> takePicture() async {
    final ImagePicker picker = ImagePicker();
    // Capture a photo.
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 30,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    return photo;
  }

  //Get the picture from the device gallery
  Future<XFile?> selectPicture() async {
    final ImagePicker picker = ImagePicker();
    // Capture a photo.
    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    return photo;
  }

  //Get PDF file from the device and convert it to XFile for compatibility
  Future<XFile?> selectPDFAsXFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        if (platformFile.path != null) {
          return XFile(platformFile.path!);
        }
      }
    } catch (e) {
      log('Error picking PDF file: $e');
    }
    return null;
  }

  //Show dialog alert
  Future<void> showDialogAlert(
    BuildContext context,
    String title,
    String body,
    String button,
    Function callback,
  ) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(body)]),
          ),
          actions: <Widget>[
            TextButton(child: Text(button), onPressed: () => callback()),
          ],
        );
      },
    );
  }

  //This method is used to uppercase the first letter of a string
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  //This method is used to get the user location
  Future<LocationData?> getUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  //This method is used to convert from address to coordinates
  Future<geocoding.Location?> getCoordinatesFromAddress(String address) async {
    List<geocoding.Location> locations = await geocoding.locationFromAddress(
      address,
    );
    return locations.first;
  }

  //This method is used to convert from coordinates to address
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final locationString = await reverseGeocodeCoordinates(latitude, longitude);
    return locationString;
  }

  //This method is used to open app from url
  Future<void> openAppFromUri(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Error trying to open the following url: $url');
    }
  }

  /// Navigate to a location using the user's preferred maps app
  /// Shows a dialog on iOS to choose between Apple Maps, Google Maps, or Waze
  /// On Android, uses the geo: intent which opens the default maps app
  Future<void> navigateToLocation({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String address,
    required Map<String, String> texts,
  }) async {
    try {
      if (address.isEmpty) return;

      if (Theme.of(context).platform == TargetPlatform.android) {
        // Android: Use geo: intent - opens user's default maps app
        var intent = 'geo:';
        var encodedAddress = Uri.encodeComponent(address);
        var finalUrl = '$intent$latitude,$longitude?q=$encodedAddress';
        Uri encodedUri = Uri.parse(finalUrl);
        await openAppFromUri(encodedUri);
      } else {
        // iOS: Show dialog with multiple map app options
        final locator = GetIt.instance;
        var appleIntent = locator.get<AppConstants>().appleIntent;
        var googleMapsIntent = locator.get<AppConstants>().googleMapsIntent;
        var wazeIntent = locator.get<AppConstants>().wazeIntent;

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                texts["open-with"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(texts["apple-maps"]!),
                    trailing: const Icon(Icons.map),
                    onTap: () async {
                      Navigator.of(context).pop();
                      var finalUrl = '$appleIntent$latitude,$longitude';
                      Uri encodedUri = Uri.parse(finalUrl);
                      await openAppFromUri(encodedUri);
                    },
                  ),
                  ListTile(
                    title: Text(texts["google-maps"]!),
                    trailing: const Icon(Icons.map_outlined),
                    onTap: () async {
                      Navigator.of(context).pop();
                      var encodedAddress = Uri.encodeComponent(address);
                      var finalUrl = '$googleMapsIntent$latitude,$longitude&q=$encodedAddress';
                      Uri encodedUri = Uri.parse(finalUrl);
                      await openAppFromUri(encodedUri);
                    },
                  ),
                  ListTile(
                    title: Text(texts["waze"]!),
                    trailing: const Icon(Icons.navigation),
                    onTap: () async {
                      Navigator.of(context).pop();
                      var finalUrl = '$wazeIntent$latitude,$longitude';
                      Uri encodedUri = Uri.parse(finalUrl);
                      await openAppFromUri(encodedUri);
                    },
                  ),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      log('Error navigating to location: $e');
    }
  }

  //This method is used to get a static map from coordinates
  String getStaticMapURL(
    int zoom,
    String size,
    String mapType,
    String markers,
    double? latitude,
    double? longitude,
    Brightness? brightness,
  ) {
    if (latitude == null || longitude == null) return '';
    final locator = GetIt.instance;
    final mapThemeId =
        brightness == Brightness.light
            ? locator.get<AppConstants>().lightMapTheme
            : locator.get<AppConstants>().darkMapTheme;
    final mapKey = dotenv.env["GOOGLE_MAPS_API_KEY_WEB"];
    final staticMapApi = locator.get<AppConstants>().googleMapsStaticApi;

    return '$staticMapApi?center=$latitude,$longitude&zoom=$zoom&size=$size&maptype=$mapType&markers=$markers&key=$mapKey&map_id=$mapThemeId';
  }

  //This method is used to reverse geocode coordinates
  Future<String?> reverseGeocodeCoordinates(
    double latitude,
    double longitude,
  ) async {
    final locator = GetIt.instance;
    final mapKey = dotenv.env["GOOGLE_MAPS_API_KEY_WEB"];

    final reverseGeocodeApi =
        locator.get<AppConstants>().googleMapsGeoCodingApi;

    final url = '$reverseGeocodeApi$latitude,$longitude&key=$mapKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["results"][0]["formatted_address"];
    }
    return null;
  }

  //This method is used to handle RemoteMessage
  Future<void> handleRemoteMessage(
    RemoteMessage message,
    BuildContext context,
  ) async {
    if (message.data.containsKey("promotion")) {
      AutoRouter.of(context).push(
        PromotionDetailsView(
          promotion: null,
          promotionId: message.data["promotion"],
        ),
      );
    } else if (message.data.containsKey("business")) {
      AutoRouter.of(
        context,
      ).push(BusinessDetailsView(businessId: message.data["business"]));
    } else if (message.data.containsKey("route")) {
      log("Route found for: ${message.data}");
      AutoRouter.of(context).pushNamed("/${message.data["route"]}");
    } else {
      log("No route found for: ${message.data}");
    }
  }

  /// Get city name from GPS coordinates using reverse geocoding
  ///
  /// This method uses reverse geocoding to convert GPS coordinates into a city name.
  /// It's used to automatically detect and update the user's city for analytics demographics.
  ///
  /// Returns:
  /// - The detected city name if successful (e.g., "Bogotá", "Medellín")
  /// - "Bogotá" as the default fallback if geocoding fails or no location provided
  ///
  /// Parameters:
  /// - [latitude]: GPS latitude coordinate
  /// - [longitude]: GPS longitude coordinate
  Future<String> getCityFromLocation(double? latitude, double? longitude) async {
    const String defaultCity = 'Bogotá'; // Default fallback city

    try {
      // Return default if coordinates are null
      if (latitude == null || longitude == null) {
        log('Location is null, using default city: $defaultCity');
        return defaultCity;
      }

      log('Reverse geocoding location: ($latitude, $longitude)');

      // Perform reverse geocoding
      final List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        log('No placemarks found, using default city: $defaultCity');
        return defaultCity;
      }

      // Get the first placemark
      final placemark = placemarks.first;

      // Try to get city from locality (most accurate)
      // Examples: "Bogotá", "Medellín", "Cali", "Barranquilla"
      String? city = placemark.locality;

      // Fallback to subAdministrativeArea if locality is empty
      // This handles cases where locality might not be set
      city ??= placemark.subAdministrativeArea;

      // Fallback to administrativeArea (state/department level)
      city ??= placemark.administrativeArea;

      if (city != null && city.isNotEmpty) {
        log('City detected: $city');
        return city;
      } else {
        log('City name is empty, using default: $defaultCity');
        return defaultCity;
      }
    } catch (e) {
      log('Error in reverse geocoding: $e');
      log('Using default city: $defaultCity');
      return defaultCity;
    }
  }
}
