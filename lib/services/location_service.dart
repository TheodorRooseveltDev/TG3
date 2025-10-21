import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled and permissions are granted
  static Future<Map<String, dynamic>> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'granted': false,
        'message': 'Location services are disabled. Please enable location services in your device settings.',
      };
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'granted': false,
          'message': 'Location permission denied. Please grant location access to use this feature.',
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'granted': false,
        'message': 'Location permission permanently denied. Please enable it in Settings > Big Bass Catcher > Location.',
      };
    }

    return {
      'granted': true,
      'message': 'Location permission granted',
    };
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      final permissionResult = await checkPermissions();
      if (permissionResult['granted'] != true) {
        print('Location permission not granted: ${permissionResult['message']}');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get address from coordinates
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^,\s*|,\s*$'), ''); // Remove leading/trailing commas
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Get location with address
  static Future<Map<String, dynamic>?> getLocationWithAddress() async {
    final position = await getCurrentLocation();
    if (position == null) return null;

    final address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': address ?? 'Unknown location',
    };
  }
}
