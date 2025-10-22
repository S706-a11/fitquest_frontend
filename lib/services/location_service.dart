import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Service for tracking user location and calculating distance
class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  final List<Position> _positions = [];
  double _totalDistance = 0.0;

  /// Check if location services are enabled and we have permission
  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  /// Start tracking location
  Future<void> startTracking(
    Function(double distance, double speed) onUpdate,
  ) async {
    _positions.clear();
    _totalDistance = 0.0;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_positions.isNotEmpty) {
        final lastPosition = _positions.last;
        final distance = Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          position.latitude,
          position.longitude,
        );
        _totalDistance += distance;
      }

      _positions.add(position);

      // Calculate speed in km/h
      final speedKmh = position.speed * 3.6;

      onUpdate(_totalDistance, speedKmh);
    });
  }

  /// Stop tracking location
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Get total distance in meters
  double get totalDistance => _totalDistance;

  /// Get total distance in kilometers
  double get totalDistanceKm => _totalDistance / 1000;

  /// Get list of positions
  List<Position> get positions => List.unmodifiable(_positions);

  /// Calculate distance between two points in meters
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Clean up resources
  void dispose() {
    stopTracking();
  }
}
