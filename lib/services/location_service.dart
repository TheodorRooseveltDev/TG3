import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Check if location services are enabled and permissions are granted
  static Future<Map<String, dynamic>> checkPermissions({
    bool requestPermission = false,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'granted': false,
        'status': 'services_disabled',
        'message':
            'Location services are disabled. Please enable location services in your device settings.',
      };
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      if (requestPermission) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'granted': false,
            'status': 'denied',
            'message':
                'Location permission denied. Please grant location access to use this feature.',
          };
        }
      } else {
        return {
          'granted': false,
          'status': 'denied',
          'message':
              'Location permission not granted. Enable it in Settings to use location features.',
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'granted': false,
        'status': 'denied_forever',
        'message':
            'Location permission permanently denied. Please enable it in Settings > Big Bass Catcher > Location.',
      };
    }

    final granted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    return {
      'granted': granted,
      'status': granted ? 'granted' : 'restricted',
      'message': granted
          ? 'Location permission granted'
          : 'Location permission is restricted on this device.',
    };
  }

  // Get current location
  static Future<Position?> getCurrentLocation({
    bool requestPermission = false,
  }) async {
    try {
      final permissionResult = await checkPermissions(
        requestPermission: requestPermission,
      );
      if (permissionResult['granted'] != true) {
        print(
          'Location permission not granted: ${permissionResult['message']}',
        );
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
            .replaceAll(
              RegExp(r'^,\s*|,\s*$'),
              '',
            ); // Remove leading/trailing commas
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Get location with address
  static Future<Map<String, dynamic>?> getLocationWithAddress({
    bool requestPermission = false,
  }) async {
    final position = await getCurrentLocation(
      requestPermission: requestPermission,
    );
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
