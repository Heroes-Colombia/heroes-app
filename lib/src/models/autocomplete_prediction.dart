/// A class to hold the prediction returned from the Google Places API.
class AutocompletePrediction {
  /// The description of the place, which is the human-readable name.
  final String description;

  /// A unique identifier for the place.
  final String placeId;

  /// Creates an instance of [AutocompletePrediction].
  const AutocompletePrediction({
    required this.description,
    required this.placeId,
  });

  /// Creates an instance of [AutocompletePrediction] from a JSON object.
  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}
