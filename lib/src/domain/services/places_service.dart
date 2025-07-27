import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/src/domain/models/autocomplete_prediction.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:developer';

/// A service class to interact with the Google Places API.
///
/// This service handles fetching place predictions for autocomplete functionality
/// and retrieving detailed information about a specific place.
class PlacesService {
  final locator = GetIt.instance;

  /// Generates a new session token for each autocomplete session.
  /// This is a cost-optimization measure provided by Google.
  String _sessionToken = const Uuid().v4();

  /// Fetches place autocomplete suggestions from the Google Places API,
  /// restricted to Colombia.
  ///
  /// [input] is the text entered by the user.
  /// Returns a list of [AutocompletePrediction] objects.
  Future<List<AutocompletePrediction>> getAutocomplete(String input) async {
    final apiKey = locator.get<AppConstants>().googlePlacesApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      log('Google Places API key is not configured.');
      return [];
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&sessiontoken=$_sessionToken&components=country:co';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions =
              (data['predictions'] as List)
                  .map((p) => AutocompletePrediction.fromJson(p))
                  .toList();
          return predictions;
        } else {
          log('Google Places Autocomplete API Error: ${data['status']}');
          return [];
        }
      }
    } catch (e) {
      log('Error fetching autocomplete: $e');
    }
    return [];
  }

  /// Fetches the details of a specific place using its [placeId].
  ///
  /// This provides the coordinates ([LatLng]) for the selected place.
  /// Returns a [LatLng] object or null if an error occurs.
  Future<LatLng?> getPlaceDetails(String placeId) async {
    final apiKey = locator.get<AppConstants>().googlePlacesApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      log('Google Places API key is not configured.');
      return null;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&sessiontoken=$_sessionToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          // Renew the session token after a successful details lookup.
          _sessionToken = const Uuid().v4();
          return LatLng(location['lat'], location['lng']);
        } else {
          log('Google Places Details API Error: ${data['status']}');
          return null;
        }
      }
    } catch (e) {
      log('Error fetching place details: $e');
    }
    return null;
  }
}
