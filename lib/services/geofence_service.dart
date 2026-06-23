import 'package:geolocator/geolocator.dart';

class GeolocationResult {
  final double lat;
  final double lng;
  final double accuracy;

  const GeolocationResult({
    required this.lat,
    required this.lng,
    required this.accuracy,
  });

  bool get isAccurate => accuracy <= 30.0;
}

class GeofenceService {
  const GeofenceService();

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<GeolocationResult?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return GeolocationResult(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (_) {
      return null;
    }
  }
}
