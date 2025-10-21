import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/fish_species.dart';
import '../providers/app_provider.dart';
import '../services/location_service.dart';
import '../utils/app_theme.dart';

// Class to represent a fish location on the map
class FishLocationMarker {
  final LatLng position;
  final FishSpecies fish;
  final double distanceKm;
  final String locationName;

  FishLocationMarker({
    required this.position,
    required this.fish,
    required this.distanceKm,
    required this.locationName,
  });
}

class HabitatMap extends StatefulWidget {
  final FishSpecies fish;

  const HabitatMap({super.key, required this.fish});

  @override
  State<HabitatMap> createState() => _HabitatMapState();
}

class _HabitatMapState extends State<HabitatMap> {
  final MapController _mapController = MapController();
  Position? _userPosition;
  bool _isLoadingLocation = true;
  String? _locationError;
  List<FishLocationMarker> _nearbyFishLocations = [];
  FishLocationMarker? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (!appProvider.preferences.locationServicesEnabled) {
        if (mounted) {
          _setFallbackLocation(
            'Enable location features in Settings to view nearby fishing spots.',
          );
        }
        return;
      }

      final permissionStatus = await LocationService.checkPermissions();
      if (permissionStatus['granted'] != true) {
        if (mounted) {
          _setFallbackLocation(
            permissionStatus['message'] ??
                'Location unavailable. Showing sample fishing spots.',
          );
        }
        return;
      }

      final position = await LocationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _userPosition = position;
          _isLoadingLocation = false;
          _nearbyFishLocations = _generateNearbyFishLocations(position);
        });
      } else if (mounted) {
        _setFallbackLocation(
          'Unable to determine your location. Showing sample fishing spots.',
        );
      }
    } catch (e) {
      if (mounted) {
        _setFallbackLocation('Unable to get location. Using default location.');
      }
    }
  }

  void _setFallbackLocation(String message) {
    final fallbackPosition = Position(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    setState(() {
      _userPosition = fallbackPosition;
      _isLoadingLocation = false;
      _locationError = message;
      _nearbyFishLocations = _generateNearbyFishLocations(fallbackPosition);
    });
  }

  List<FishLocationMarker> _generateNearbyFishLocations(Position userPos) {
    final random = math.Random(
      widget.fish.id.hashCode,
    ); // Consistent results per fish
    final List<FishLocationMarker> locations = [];

    // Generate 5-10 locations within 10km radius for this specific fish
    final numLocations = 5 + random.nextInt(6);

    for (int i = 0; i < numLocations; i++) {
      // Random distance between 0.5km and 10km
      final distance = 0.5 + random.nextDouble() * 9.5;

      // Random angle
      final angle = random.nextDouble() * 2 * math.pi;

      // Calculate offset (1 degree ≈ 111km)
      final latOffset = (distance / 111.0) * math.cos(angle);
      final lngOffset =
          (distance / (111.0 * math.cos(userPos.latitude * math.pi / 180))) *
          math.sin(angle);

      final lat = userPos.latitude + latOffset;
      final lng = userPos.longitude + lngOffset;

      // Generate location name based on fish habitat
      final locationNames = _getLocationNames(widget.fish);
      final locationName = locationNames[random.nextInt(locationNames.length)];

      locations.add(
        FishLocationMarker(
          position: LatLng(lat, lng),
          fish: widget.fish,
          distanceKm: distance,
          locationName: locationName,
        ),
      );
    }

    // Sort by distance
    locations.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return locations;
  }

  List<String> _getLocationNames(FishSpecies fish) {
    if (fish.type == 'freshwater') {
      return [
        '${fish.name} Lake',
        'Crystal Pond',
        'Riverside',
        'Hidden Creek',
        'Mountain Lake',
        'Quiet Waters',
        'Sunset Reservoir',
        'Eagle Point',
        'Pine Valley Lake',
        'Willow Brook',
      ];
    } else {
      return [
        'Coastal Pier',
        'Marina Bay',
        'Ocean Jetty',
        'Harbor Dock',
        'Beach Access',
        'Rocky Shore',
        'Inlet Point',
        'Surf Zone',
        'Deep Water',
        'Channel Marker',
      ];
    }
  }

  Widget _buildMap() {
    if (_userPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userLatLng = LatLng(
      _userPosition!.latitude,
      _userPosition!.longitude,
    );

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: userLatLng,
        initialZoom: 11.0,
        minZoom: 8.0,
        maxZoom: 15.0,
      ),
      children: [
        // OpenStreetMap Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bigbasscatcher.app',
          maxZoom: 19,
        ),

        // Fish location markers
        MarkerLayer(
          markers: _nearbyFishLocations.map((location) {
            final isSelected = _selectedLocation == location;
            return Marker(
              point: location.position,
              width: isSelected ? 50 : 40,
              height: isSelected ? 50 : 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLocation = isSelected ? null : location;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.colorAccent
                        : AppTheme.colorSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '🎣',
                      style: TextStyle(fontSize: isSelected ? 24 : 20),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // User location marker
        MarkerLayer(
          markers: [
            Marker(
              point: userLatLng,
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.colorPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.colorPrimary.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.my_location, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    if (_selectedLocation == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.colorSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppTheme.colorSecondary, width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 16,
              color: AppTheme.colorSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap markers to see fishing spot details • ${_nearbyFishLocations.length} spots nearby',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color.fromARGB(255, 216, 218, 221),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.colorAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.colorAccent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.colorAccent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text('🎣', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLocation!.locationName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.colorAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_selectedLocation!.distanceKm.toStringAsFixed(1)} km away',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.colorTextDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedLocation = null;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.colorBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DEPTH',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.colorTextMuted,
                        ),
                      ),
                      Text(
                        _selectedLocation!.fish.depthRange,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BEST SEASON',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.colorTextMuted,
                        ),
                      ),
                      Text(
                        _selectedLocation!.fish.season,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'HABITAT MAP - NEARBY FISHING SPOTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: AppTheme.colorTextMuted,
                ),
              ),
            ),
            if (!_isLoadingLocation && _userPosition != null)
              IconButton(
                icon: const Icon(Icons.my_location, size: 20),
                onPressed: () {
                  _mapController.move(
                    LatLng(_userPosition!.latitude, _userPosition!.longitude),
                    11.0,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Center on my location',
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (_isLoadingLocation)
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppTheme.colorSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.colorBorder, width: 2),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading your location...',
                    style: TextStyle(
                      color: AppTheme.colorTextMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.colorBorder, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                _buildMap(),

                // Legend overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(color: AppTheme.colorBorder, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.colorPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.my_location,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'You',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.colorSecondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '🎣',
                                  style: TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.fish.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),
        _buildLocationInfo(),

        if (_locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
