import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/exercise_service.dart';
import '../providers/user_provider.dart';

class QuestTrackerPage extends StatefulWidget {
  final String? titleOverride;
  final int? xpOverride;
  final int? questId;
  final String exerciseType; // 'running', 'cycling', 'swimming', 'general'

  const QuestTrackerPage({
    super.key,
    this.titleOverride,
    this.xpOverride,
    this.questId,
    this.exerciseType = 'general',
  });

  @override
  State<QuestTrackerPage> createState() => _QuestTrackerPageState();
}

class _QuestTrackerPageState extends State<QuestTrackerPage> {
  // Timer
  Duration elapsed = Duration.zero;
  Timer? _timer;
  bool running = false;

  // GPS & Location
  final LocationService _locationService = LocationService();
  List<LatLng> _routePoints = [];
  LatLng? _startPosition;
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  // Stats
  double _distance = 0.0; // meters
  double _speed = 0.0; // km/h
  String _permissionError = '';

  bool _shouldShowMap() {
    return widget.exerciseType == 'running' || widget.exerciseType == 'cycling';
  }

  @override
  void initState() {
    super.initState();
    if (_shouldShowMap()) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await LocationService.checkPermissions();
    if (!hasPermission) {
      setState(() {
        _permissionError =
            'Location permission denied. GPS tracking unavailable.';
      });
    }
  }

  void _start() async {
    if (running) return;

    setState(() {
      running = true;
      _permissionError = '';
    });

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => elapsed += const Duration(seconds: 1));
      }
    });

    // Start GPS tracking if applicable
    if (_shouldShowMap()) {
      final hasPermission = await LocationService.checkPermissions();
      if (!hasPermission) {
        setState(() {
          _permissionError = 'Location permission denied';
        });
        return;
      }

      // Get initial position
      final initialPosition = await LocationService.getCurrentPosition();
      if (initialPosition != null) {
        final latLng = LatLng(
          initialPosition.latitude,
          initialPosition.longitude,
        );
        setState(() {
          _startPosition = latLng;
          _currentPosition = latLng;
          _routePoints.add(latLng);
        });
      }

      // Start tracking
      await _locationService.startTracking((distance, speed) {
        if (!mounted) return;

        setState(() {
          _distance = distance;
          _speed = speed;

          // Update current position from the last position in the service
          final positions = _locationService.positions;
          if (positions.isNotEmpty) {
            final lastPos = positions.last;
            final latLng = LatLng(lastPos.latitude, lastPos.longitude);
            _currentPosition = latLng;
            _routePoints.add(latLng);

            // Auto-center map on current position
            if (_routePoints.length > 1) {
              _mapController.move(_currentPosition!, 16.0);
            }
          }
        });
      });
    }
  }

  void _pause() {
    _timer?.cancel();
    _locationService.stopTracking();
    setState(() => running = false);
  }

  void _finish() async {
    _pause();

    // Validation
    final minDistance = 10.0; // meters
    final minDuration = 10; // seconds

    if (_shouldShowMap() && _distance < minDistance) {
      _showErrorDialog(
        'Workout too short',
        'Please track at least ${minDistance}m distance.',
      );
      return;
    }

    if (!_shouldShowMap() && elapsed.inSeconds < minDuration) {
      _showErrorDialog(
        'Workout too short',
        'Please exercise for at least ${minDuration} seconds.',
      );
      return;
    }

    _showSaveDialog();
  }

  void _reset() {
    _timer?.cancel();
    _locationService.stopTracking();
    setState(() {
      running = false;
      elapsed = Duration.zero;
      _routePoints.clear();
      _startPosition = null;
      _currentPosition = null;
      _distance = 0.0;
      _speed = 0.0;
      _permissionError = '';
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSaveDialog() {
    final distanceKm = _distance / 1000;
    final avgSpeed = _speed;
    final pace = avgSpeed > 0 ? 60 / avgSpeed : 0; // min/km

    // XP calculation: base (duration) + distance bonus
    final baseXp = (elapsed.inMinutes * 10).toInt();
    final distanceBonus = (distanceKm * 20).toInt();
    final totalXp = widget.xpOverride ?? (baseXp + distanceBonus);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Save Workout?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Duration: ${_hhmmss(elapsed)}'),
                if (_shouldShowMap()) ...[
                  Text('Distance: ${distanceKm.toStringAsFixed(2)} km'),
                  Text('Avg Speed: ${avgSpeed.toStringAsFixed(1)} km/h'),
                  Text('Avg Pace: ${pace.toStringAsFixed(1)} min/km'),
                ],
                const SizedBox(height: 8),
                Text(
                  'XP Earned: $totalXp',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _saveWorkout(totalXp);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveWorkout(int xp) async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in')),
        );
      }
      return;
    }

    try {
      // Convert route points to the format expected by the API
      List<Map<String, double>>? route;
      if (_routePoints.isNotEmpty) {
        route =
            _routePoints.map((point) {
              return {'latitude': point.latitude, 'longitude': point.longitude};
            }).toList();
      }

      // Calculate calories (rough estimation)
      final calories = _calculateCalories(
        widget.exerciseType,
        elapsed.inMinutes,
        _distance / 1000, // Convert to km
      );

      // Log the exercise session
      await ExerciseService.logExerciseSession(
        userId: userId,
        exerciseType: widget.exerciseType,
        duration: elapsed.inSeconds,
        distance: _distance > 0 ? _distance : null,
        calories: calories,
        route: route,
        questId: widget.questId,
        metrics: {
          'xp': xp,
          'avgSpeed': _speed,
          if (_shouldShowMap() && _distance > 0)
            'avgPace': (elapsed.inSeconds / 60) / (_distance / 1000),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout saved! +$xp XP'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      print('Error saving workout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _calculateCalories(String exerciseType, int minutes, double distanceKm) {
    // Rough MET (Metabolic Equivalent) calculations
    // Formula: Calories = MET × weight(kg) × time(hours)
    // Assuming average weight of 70kg
    const avgWeight = 70;
    final hours = minutes / 60;

    double met;
    switch (exerciseType) {
      case 'running':
        // Running at ~10 km/h (6 min/km pace) = MET 10
        met = distanceKm > 0 ? (distanceKm / hours) / 1.5 : 8.0;
        break;
      case 'cycling':
        // Cycling at moderate pace = MET 8
        met = 8.0;
        break;
      case 'swimming':
        // Swimming = MET 8
        met = 8.0;
        break;
      case 'strength':
        // Weight training = MET 6
        met = 6.0;
        break;
      default:
        // General exercise = MET 5
        met = 5.0;
    }

    return (met * avgWeight * hours).round();
  }

  String _hhmmss(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color _getExerciseColor() {
    switch (widget.exerciseType) {
      case 'running':
        return Colors.orange;
      case 'cycling':
        return Colors.blue;
      case 'swimming':
        return Colors.cyan;
      default:
        return Colors.green;
    }
  }

  IconData _getExerciseIcon() {
    switch (widget.exerciseType) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike;
      case 'swimming':
        return Icons.pool;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationService.stopTracking();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.titleOverride ?? '${widget.exerciseType.toUpperCase()} WORKOUT';
    final exerciseColor = _getExerciseColor();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_getExerciseIcon(), color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'QUEST TRACKER',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Map Section (for running/cycling)
          if (_shouldShowMap()) ...[
            Expanded(
              flex: 3,
              child:
                  _permissionError.isNotEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_off,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _permissionError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : _currentPosition == null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            const Text('Waiting for GPS signal...'),
                          ],
                        ),
                      )
                      : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition!,
                          initialZoom: 16.0,
                          minZoom: 10.0,
                          maxZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.fitquest.app',
                          ),
                          // Route polyline
                          if (_routePoints.length > 1)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  strokeWidth: 4.0,
                                  color: exerciseColor,
                                ),
                              ],
                            ),
                          // Markers
                          MarkerLayer(
                            markers: [
                              // Start marker
                              if (_startPosition != null)
                                Marker(
                                  point: _startPosition!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.flag,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                ),
                              // Current position marker
                              if (_currentPosition != null)
                                Marker(
                                  point: _currentPosition!,
                                  width: 50,
                                  height: 50,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: exerciseColor.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: exerciseColor,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      _getExerciseIcon(),
                                      color: exerciseColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
            ),
          ],

          // Stats Section
          Expanded(
            flex: _shouldShowMap() ? 2 : 5,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  if (_shouldShowMap())
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatCard(
                            'Duration',
                            _hhmmss(elapsed),
                            Icons.timer,
                            exerciseColor,
                          ),
                          _buildStatCard(
                            'Distance',
                            '${(_distance / 1000).toStringAsFixed(2)} km',
                            Icons.route,
                            exerciseColor,
                          ),
                          _buildStatCard(
                            'Speed',
                            '${_speed.toStringAsFixed(1)} km/h',
                            Icons.speed,
                            exerciseColor,
                          ),
                          _buildStatCard(
                            'Pace',
                            _speed > 0
                                ? '${(60 / _speed).toStringAsFixed(1)} min/km'
                                : '--',
                            Icons.av_timer,
                            exerciseColor,
                          ),
                        ],
                      ),
                    )
                  else
                    // Timer-only view for swimming/general
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getExerciseIcon(),
                              size: 80,
                              color: exerciseColor,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _hhmmss(elapsed),
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: exerciseColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Controls
                  if (!running)
                    FilledButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START'),
                      style: FilledButton.styleFrom(
                        backgroundColor: exerciseColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _pause,
                            icon: const Icon(Icons.pause),
                            label: const Text('PAUSE'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _finish,
                            icon: const Icon(Icons.check),
                            label: const Text('FINISH'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('RESET'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
